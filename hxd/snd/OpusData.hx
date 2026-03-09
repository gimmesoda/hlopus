package hxd.snd;

class OpusData extends hxd.snd.Data
{
	var bytes:haxe.io.Bytes;
	var decoder:hlopus.Decoder;
	var currentSample:Int;

	public function new(bytes:haxe.io.Bytes)
	{
		this.bytes = bytes;
		decoder = new hlopus.Decoder(bytes);
		channels = decoder.channels;
		samples = decoder.samples;
		sampleFormat = I16;
		samplingRate = decoder.samplingRate;
		currentSample = 0;
	}

	override function resample(rate:Int, format:hxd.snd.Data.SampleFormat, channels:Int):hxd.snd.Data
	{
		switch (format)
		{
			case I16 if (channels == this.channels && rate == this.samplingRate):
				return new OpusData(bytes);
			case F32 if (channels == this.channels && rate == this.samplingRate):
				final g = new OpusData(bytes);
				g.sampleFormat = hxd.snd.Data.SampleFormat.F32;
				return g;
			default:
				return super.resample(rate, format, channels);
		}
	}

	override function decodeBuffer(out:haxe.io.Bytes, outPos:Int, sampleStart:Int, sampleCount:Int)
	{
		if (currentSample != sampleStart)
		{
			currentSample = sampleStart;
			if (!decoder.seek(sampleStart))
				throw "Invalid sample start";
		}

		final bpp = getBytesPerSample();
		final format = switch (sampleFormat)
		{
			case I16: hlopus.SampleFormat.I16;
			case F32: hlopus.SampleFormat.F32;
			default:
				throw "assert";
		}

		var bytesNeeded = sampleCount * bpp;
		var offset = outPos;
		while (bytesNeeded > 0)
		{
			final read = decoder.read(out, offset, bytesNeeded, format);
			if (read < 0)
				throw "Failed to decode Opus data";

			if (read == 0)
			{
				// EOF
				out.fill(offset, bytesNeeded, 0);
				break;
			}

			bytesNeeded -= read;
			offset += read;
		}

		currentSample += sampleCount;
	}
}
