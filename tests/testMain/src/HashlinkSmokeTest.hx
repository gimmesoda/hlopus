import sys.FileSystem;
import sys.io.File;
import openal.AL;
import openal.ALC;

final class HashlinkSmokeTest {
	static function checkALError(prefix:String):Void {
		final err = AL.getError();
		if (err != AL.NO_ERROR)
			throw prefix + " failed: 0x" + StringTools.hex(err, 4);
	}

	static function cleanup(tmp:haxe.io.Bytes, source:openal.AL.Source, buffer:openal.AL.Buffer, context:openal.ALC.Context, device:openal.ALC.Device):Void {
		if (source.toInt() != 0) {
			AL.sourceStop(source);
			AL.sourcei(source, AL.BUFFER, 0);
			tmp.setInt32(0, source.toInt());
			AL.deleteSources(1, tmp);
		}
		if (buffer.toInt() != 0) {
			tmp.setInt32(0, buffer.toInt());
			AL.deleteBuffers(1, tmp);
		}
		if (context != null) {
			ALC.makeContextCurrent(null);
			ALC.destroyContext(context);
		}
		if (device != null)
			ALC.closeDevice(device);
	}

	static function main() {
		var device:openal.ALC.Device = null;
		var context:openal.ALC.Context = null;
		var buffer = openal.AL.Buffer.ofInt(0);
		var source = openal.AL.Source.ofInt(0);
		final tmp = haxe.io.Bytes.alloc(4);

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

			device = ALC.openDevice(null);
			if (device == null)
				throw "could not open default OpenAL device";

			context = ALC.createContext(device, null);
			if (context == null) {
				ALC.closeDevice(device);
				device = null;
				throw "could not create OpenAL context";
			}

			if (!ALC.makeContextCurrent(context)) {
				ALC.destroyContext(context);
				ALC.closeDevice(device);
				context = null;
				device = null;
				throw "could not make OpenAL context current";
			}

			AL.genBuffers(1, tmp);
			checkALError("alGenBuffers");
			buffer = openal.AL.Buffer.ofInt(tmp.getInt32(0));

			final format = switch (decoder.channels) {
				case 1: AL.FORMAT_MONO16;
				case 2: AL.FORMAT_STEREO16;
				default: throw "unsupported channel count for OpenAL test: " + decoder.channels;
			}

			AL.bufferData(buffer, format, pcm, pcm.length, decoder.samplingRate);
			checkALError("alBufferData");

			AL.genSources(1, tmp);
			checkALError("alGenSources");
			source = openal.AL.Source.ofInt(tmp.getInt32(0));

			AL.sourcei(source, AL.BUFFER, buffer.toInt());
			checkALError("alSourcei(AL_BUFFER)");

			AL.sourcePlay(source);
			checkALError("alSourcePlay");

			final startedAt = haxe.Timer.stamp();
			var started = false;
			while (true) {
				final state = AL.getSourcei(source, AL.SOURCE_STATE);
				final offset = AL.getSourcei(source, AL.SAMPLE_OFFSET);

				if (!started && offset > 0) {
					started = true;
					Sys.println("[HL] playback started");
				}

				if (!started && haxe.Timer.stamp() - startedAt > 2.0)
					throw "playback sample offset did not advance";

				if (state != AL.PLAYING)
					break;

				Sys.sleep(0.01);
			}

			if (!started)
				throw "playback stopped before audio advanced";

			AL.sourceStop(source);

			Sys.println("[HL] PASS");
		}
		catch (e) {
			cleanup(tmp, source, buffer, context, device);
			Sys.println("[HL] FAIL: " + Std.string(e));
			Sys.exit(1);
		}

		cleanup(tmp, source, buffer, context, device);
	}
}
