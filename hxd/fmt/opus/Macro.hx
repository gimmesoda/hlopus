package hxd.fmt.opus;

import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr.Field;

using Lambda;

class Macro {
	public static macro function buildSoundFormat():Array<Field> {
		final fields:Array<Field> = Context.getBuildFields();
		fields.push({
			name: 'Opus',
			kind: FVar(null, null),
			pos: Context.currentPos()
		});
		return fields;
	}

	public static macro function buildSound():Array<Field> {
		final fields:Array<Field> = Context.getBuildFields();

		switch fields.find(f -> f.name == 'supportedFormat').kind {
			case FFun(f):
				f.expr = macro return switch (fmt) {
					case Wav, Mp3:
						return true;
					case OggVorbis:
						#if (hl || stb_ogg_sound)
						return true;
						#else
						return false;
						#end
					case Opus:
						return true;
				}
			default:
		}

		fields.push({
			name: 'isOpusStream',
			access: [APrivate, AStatic],
			kind: FFun({
				args: [{name: 'bytes', type: macro :haxe.io.Bytes}],
				ret: macro :Bool,
				expr: macro {
					if (bytes.length < 36)
						return false;
					var numSegments = bytes.get(26);
					var dataOffset = 27 + numSegments;
					if (bytes.length < dataOffset + 8)
						return false;
					return bytes.get(dataOffset) == 'O'.code
						&& bytes.get(dataOffset + 1) == 'p'.code
						&& bytes.get(dataOffset + 2) == 'u'.code
						&& bytes.get(dataOffset + 3) == 's'.code
						&& bytes.get(dataOffset + 4) == 'H'.code
						&& bytes.get(dataOffset + 5) == 'e'.code
						&& bytes.get(dataOffset + 6) == 'a'.code
						&& bytes.get(dataOffset + 7) == 'd'.code;
				}
			}),
			pos: Context.currentPos()
		});

		switch fields.find(f -> f.name == 'getData').kind {
			case FFun(f):
				f.expr = macro {
					if (data != null)
						return data;
					var bytes = entry.getBytes();
					switch (bytes.get(0)) {
						case 'R'.code: // RIFF (wav)
							data = new hxd.snd.WavData(bytes);
						case 255, 'I'.code: // MP3 (or ID3)
							data = new hxd.snd.Mp3Data(bytes);
						case 'O'.code: // Ogg container (vorbis or opus)
							if (isOpusStream(bytes)) {
								data = new hxd.fmt.opus.Data(bytes);
							} else {
								data = new hxd.snd.OggData(bytes);
							}
						default:
					}
					if (data == null)
						throw "Unsupported sound format " + entry.path;
					if (ENABLE_AUTO_WATCH)
						watch(watchCallb);
					return data;
				}
			default:
		}

		return fields;
	}
}
