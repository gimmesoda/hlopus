package hlopus;

typedef OpusHandle = hl.Abstract<"fmt_opus">;

class Native {
	@:hlNative("opus", "opus_open")
	public static function open(bytes:hl.Bytes, size:Int):OpusHandle {
		return null;
	}

	@:hlNative("opus", "opus_info")
	public static function info(o:OpusHandle, freq:hl.Ref<Int>, samples:hl.Ref<Int>, channels:hl.Ref<Int>):Void {}

	@:hlNative("opus", "opus_tell")
	public static function tell(o:OpusHandle):Int {
		return 0;
	}

	@:hlNative("opus", "opus_seek")
	public static function seek(o:OpusHandle, sample:Int):Bool {
		return false;
	}

	@:hlNative("opus", "opus_read")
	public static function read(o:OpusHandle, output:hl.Bytes, size:Int, format:SampleFormat):Int {
		return 0;
	}
}
