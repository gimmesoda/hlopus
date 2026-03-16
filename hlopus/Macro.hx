package hlopus;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Expr.Field;

using Lambda;

/**
	Build macros that extend Heaps sound classes with Opus support.
**/
class Macro {
	/**
		Adds an `Opus` entry to `hxd.res.SoundFormat` when needed.
	**/
	public static macro function buildSoundFormat():Array<Field> {
		final fields:Array<Field> = Context.getBuildFields();
		if (fields.exists(f -> f.name == "Opus"))
			return fields;

		fields.push({
			name: "Opus",
			kind: FVar(null, null),
			pos: Context.currentPos()
		});
		return fields;
	}

	/**
		Patches `hxd.res.Sound` so `.opus` resources decode through `OpusData`.
	**/
	public static macro function buildSound():Array<Field> {
		final fields:Array<Field> = Context.getBuildFields();
		if (fields.exists(f -> f.name == "isOpusStream"))
			return fields;

		final supportedFormatField = fields.find(f -> f.name == "supportedFormat");
		if (supportedFormatField != null) {
			switch supportedFormatField.kind {
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
						default:
							return Type.enumConstructor(fmt) == "Opus";
					}
				default:
			}
		}

		fields.push({
			name: "isOpusStream",
			access: [APrivate, AStatic],
			kind: FFun({
				args: [{name: "bytes", type: macro :haxe.io.Bytes}],
				ret: macro :Bool,
				expr: macro {
					if (bytes.length < 36)
						return false;
					// verify OGG magic bytes "OggS"
					if (bytes.get(0) != "O".code || bytes.get(1) != "g".code || bytes.get(2) != "g".code || bytes.get(3) != "S".code)
						return false;
					var numSegments = bytes.get(26);
					var dataOffset = 27 + numSegments;
					if (bytes.length < dataOffset + 8)
						return false;
					return bytes.get(dataOffset) == "O".code
						&& bytes.get(dataOffset + 1) == "p".code
						&& bytes.get(dataOffset + 2) == "u".code
						&& bytes.get(dataOffset + 3) == "s".code
						&& bytes.get(dataOffset + 4) == "H".code
						&& bytes.get(dataOffset + 5) == "e".code
						&& bytes.get(dataOffset + 6) == "a".code
						&& bytes.get(dataOffset + 7) == "d".code;
				}
			}),
			pos: Context.currentPos()
		});

		final getDataField = fields.find(f -> f.name == "getData");
		if (getDataField != null) {
			switch getDataField.kind {
				case FFun(f):
					final originalExpr = f.expr;
					f.expr = macro {
						if (data == null) {
							final bytes = entry.getBytes();
							if (isOpusStream(bytes))
								data = new hxd.snd.OpusData(bytes);
						}

						if (data != null)
							return data;

						return $originalExpr;
					};
				default:
			}
		}

		return fields;
	}
}
