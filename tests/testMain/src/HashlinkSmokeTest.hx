import sys.FileSystem;
import sys.io.File;

final class HashlinkSmokeTest {
	static function main() {
		final dir = "res";
		if (!FileSystem.exists(dir) || !FileSystem.isDirectory(dir)) {
			Sys.println("[HL] FAIL: missing res directory");
			Sys.exit(1);
		}

		if (!FileSystem.exists(dir + "/test.opus")) {
			Sys.println("[HL] FAIL: missing res/test.opus");
			Sys.exit(1);
		}

		try {
			final bytes = File.getBytes(dir + "/test.opus");
			final decoder = new hlopus.Decoder(bytes);
			final pcm = decoder.decodeAll(hlopus.SampleFormat.I16);
			final duration = decoder.samples / decoder.samplingRate;

			Sys.println("[HL] loaded test.opus");
			Sys.println("[HL] rate=" + decoder.samplingRate + " channels=" + decoder.channels + " samples=" + decoder.samples);
			Sys.println("[HL] duration=" + duration + " sec");

			if (decoder.samples <= 0)
				throw "decoded sample count is zero";
			if (decoder.channels <= 0)
				throw "decoded channel count is zero";
			if (pcm.length == 0)
				throw "decoded PCM buffer is empty";

			Sys.println("[HL] PASS");
		} catch (e) {
			Sys.println("[HL] FAIL: " + Std.string(e));
			Sys.exit(1);
		}
	}
}
