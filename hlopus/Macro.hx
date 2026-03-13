package hlopus;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Expr.Field;

using Lambda;

class Macro
{
	public static macro function buildRes():Array<Field>
	{
		final fields:Array<Field> = Context.getBuildFields();
		final opusFields = new Map<String, Bool>();

		for (field in fields)
		{
			switch (field.kind)
			{
				case FFun(f):
					final path = getLoadCachePath(f.expr);
					if (path != null && StringTools.endsWith(path.toLowerCase(), ".opus"))
					{
						opusFields.set(field.name.substr(4), true);
						f.ret = macro :hxd.res.Sound;
						f.expr = replaceLoadCacheType(f.expr);
					}
				default:
			}
		}

		for (field in fields)
		{
			if (!opusFields.exists(field.name))
				continue;

			switch (field.kind)
			{
				case FProp(get, set, _, expr):
					field.kind = FProp(get, set, macro :hxd.res.Sound, expr);
				default:
			}
		}

		return fields;
	}

	public static macro function buildSoundFormat():Array<Field>
	{
		final fields:Array<Field> = Context.getBuildFields();
		if (fields.exists(f -> f.name == 'Opus'))
			return fields;

		fields.push(
			{
				name: 'Opus',
				kind: FVar(null, null),
				pos: Context.currentPos()
			});
		return fields;
	}

	public static macro function buildSound():Array<Field>
	{
		final fields:Array<Field> = Context.getBuildFields();
		if (fields.exists(f -> f.name == 'isOpusStream'))
			return fields;

		switch fields.find(f -> f.name == 'supportedFormat').kind
		{
			case FFun(f):
				f.expr = macro return switch (fmt)
				{
					case Wav, Mp3:
						return true;
					case OggVorbis:
						#if (hl || stb_ogg_sound)
						return true;
						#else
						return false;
						#end
					default:
						return Type.enumConstructor(fmt) == 'Opus';
				}
			default:
		}

		fields.push(
			{
				name: 'isOpusStream',
				access: [APrivate, AStatic],
				kind: FFun(
					{
						args: [
							{name: 'bytes', type: macro :haxe.io.Bytes}],
						ret: macro :Bool,
						expr: macro
						{
							if (bytes.length < 36)
								return false;
							// verify OGG magic bytes "OggS"
							if (bytes.get(0) != 'O'.code || bytes.get(1) != 'g'.code || bytes.get(2) != 'g'.code || bytes.get(3) != 'S'.code)
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

		switch fields.find(f -> f.name == 'getData').kind
		{
			case FFun(f):
				f.expr = macro
					{
						if (data != null)
							return data;

						final bytes = entry.getBytes();
						switch (bytes.get(0))
						{
							case 'R'.code: // RIFF (wav)
								data = new hxd.snd.WavData(bytes);
							case 255, 'I'.code: // MP3 (or ID3)
								data = new hxd.snd.Mp3Data(bytes);
							case 'O'.code: // Ogg container (vorbis or opus)
								data = isOpusStream(bytes) ? new hxd.snd.OpusData(bytes) : new hxd.snd.OggData(bytes);
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

	static function getLoadCachePath(expr:Expr):Null<String>
	{
		return switch (expr.expr)
		{
			case EMeta(_, inner):
				getLoadCachePath(inner);
			case EReturn(inner) if (inner != null):
				getLoadCachePath(inner);
			case EBlock(exprs) if (exprs.length > 0):
				getLoadCachePath(exprs[exprs.length - 1]);
			case ECall({expr: EField(_, "loadCache")}, args) if (args.length >= 1):
				switch (args[0].expr)
				{
					case EConst(CString(path, _)):
						path;
					default:
						null;
				}
			default:
				null;
		}
	}

	static function replaceLoadCacheType(expr:Expr):Expr
	{
		return switch (expr.expr)
		{
			case EMeta(meta, inner):
				{expr: EMeta(meta, replaceLoadCacheType(inner)), pos: expr.pos};
			case EReturn(inner) if (inner != null):
				{expr: EReturn(replaceLoadCacheType(inner)), pos: expr.pos};
			case EBlock(exprs):
				{expr: EBlock([for (e in exprs) replaceLoadCacheType(e)]), pos: expr.pos};
			case ECall(target = {expr: EField(_, "loadCache")}, args) if (args.length >= 2):
				var newArgs = args.copy();
				newArgs[1] = macro hxd.res.Sound;
				{expr: ECall(target, newArgs), pos: expr.pos};
			default:
				expr;
		}
	}
}
