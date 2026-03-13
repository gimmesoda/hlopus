package hlopus;

import hlopus.Native.OpusHandle;

class Decoder
{
	public var bytes(default, null):haxe.io.Bytes;
	public var channels(default, null):Int;
	public var samples(default, null):Int;
	public var samplingRate(default, null):Int;

	final reader:OpusHandle;

	public function new(bytes:haxe.io.Bytes)
	{
		this.bytes = bytes;
		reader = Native.open(bytes, bytes.length);
		if (reader == null)
			throw "Failed to decode Opus data";

		var freq = 0, sampleCount = 0, channelCount = 0;
		Native.info(reader, freq, sampleCount, channelCount);
		samplingRate = freq;
		samples = sampleCount;
		channels = channelCount;
	}

	public inline function tell():Int
	{
		return Native.tell(reader);
	}

	public inline function seek(sample:Int):Bool
	{
		return Native.seek(reader, sample);
	}

	public function read(output:haxe.io.Bytes, ?outputOffset = 0, ?size = -1, ?format = SampleFormat.I16):Int
	{
		if (size < 0)
			size = output.length - outputOffset;
		if (outputOffset < 0 || size < 0 || outputOffset + size > output.length)
			throw "Invalid output range";
		final out:hl.Bytes = output;
		return Native.read(reader, out.offset(outputOffset), size, format);
	}

	public function readSamples(sampleCount:Int, ?format = SampleFormat.I16):haxe.io.Bytes
	{
		final output = haxe.io.Bytes.alloc(sampleCount * channels * format.getBytesPerSample());
		final read = read(output, 0, output.length, format);
		if (read >= 0 && read < output.length)
			output.fill(read, output.length - read, 0);
		return output;
	}

	public function decodeAll(?format = SampleFormat.I16):haxe.io.Bytes
	{
		if (!seek(0))
			throw "Failed to seek Opus data";
		return readSamples(samples, format);
	}
}
