package hlopus;

import hlopus.Native.OpusHandle;

/**
	Convenient high-level wrapper around the native Opus decoder.

	Use this class when you want streaming reads, random access via `seek()`,
	or a single-call full decode through `decodeAll()`.
**/
class Decoder {
	public var bytes(default, null):haxe.io.Bytes;
	public var channels(default, null):Int;
	public var samples(default, null):Int;
	public var samplingRate(default, null):Int;

	final reader:OpusHandle;

	/**
		Creates a decoder from Opus bytes.
	**/
	public function new(bytes:haxe.io.Bytes) {
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

	/**
		Returns the current sample position.
	**/
	public inline function tell():Int {
		return Native.tell(reader);
	}

	/**
		Seeks to a sample position.
	**/
	public inline function seek(sample:Int):Bool {
		return Native.seek(reader, sample);
	}

	/**
		Decodes into an existing output buffer.

		Returns the number of bytes written.
	**/
	public function read(output:haxe.io.Bytes, ?outputOffset = 0, ?size = -1, ?format = SampleFormat.I16):Int {
		if (size < 0)
			size = output.length - outputOffset;
		if (outputOffset < 0 || size < 0 || outputOffset + size > output.length)
			throw "Invalid output range";
		final out:hl.Bytes = output;
		return Native.read(reader, out.offset(outputOffset), size, format);
	}

	/**
		Decodes a specific number of samples into a newly allocated buffer.
	**/
	public function readSamples(sampleCount:Int, ?format = SampleFormat.I16):haxe.io.Bytes {
		final output = haxe.io.Bytes.alloc(sampleCount * channels * format.getBytesPerSample());
		final read = read(output, 0, output.length, format);
		if (read >= 0 && read < output.length)
			output.fill(read, output.length - read, 0);
		return output;
	}

	/**
		Seeks to the start and decodes the whole stream into one buffer.
	**/
	public function decodeAll(?format = SampleFormat.I16):haxe.io.Bytes {
		if (!seek(0))
			throw "Failed to seek Opus data";
		return readSamples(samples, format);
	}

	/**
		Loads an Opus file from disk and returns a new decoder.
	**/
	public static function fromFile(path:String):Decoder {
		if (path == null || path.length == 0)
			throw "Invalid Opus path";
		if (!sys.FileSystem.exists(path))
			throw "Opus file not found: " + path;
		return new Decoder(sys.io.File.getBytes(path));
	}

	/**
		Decodes Opus bytes into a single PCM buffer.
	**/
	public static function decode(bytes:haxe.io.Bytes, ?format = SampleFormat.I16):haxe.io.Bytes {
		return new Decoder(bytes).decodeAll(format);
	}

	/**
		Loads an Opus file from disk and decodes it into a single PCM buffer.
	**/
	public static function decodeFile(path:String, ?format = SampleFormat.I16):haxe.io.Bytes {
		return fromFile(path).decodeAll(format);
	}

	#if heaps
	/**
		Creates Heaps-compatible sound data from Opus bytes.
	**/
	public static inline function toHeapsData(bytes:haxe.io.Bytes):hxd.snd.OpusData {
		return new hxd.snd.OpusData(bytes);
	}

	/**
		Loads an Opus file from disk and creates Heaps-compatible sound data.
	**/
	public static function toHeapsDataFromFile(path:String):hxd.snd.OpusData {
		if (path == null || path.length == 0)
			throw "Invalid Opus path";
		if (!sys.FileSystem.exists(path))
			throw "Opus file not found: " + path;
		return new hxd.snd.OpusData(sys.io.File.getBytes(path));
	}
	#end
}
