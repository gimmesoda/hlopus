package hlopus;

#if macro
import haxe.macro.Compiler;
import haxe.macro.Context;

class Boot
{
	public static function setup()
	{
		if (hasType("hxd.Res"))
			Compiler.addMetadata("@:build(hlopus.Macro.buildRes())", "hxd.Res");
		if (hasType("hxd.res.SoundFormat"))
			Compiler.addMetadata("@:build(hlopus.Macro.buildSoundFormat())", "hxd.res.SoundFormat");
		if (hasType("hxd.res.Sound"))
			Compiler.addMetadata("@:build(hlopus.Macro.buildSound())", "hxd.res.Sound");
		return null;
	}

	static function hasType(path:String):Bool
	{
		try
		{
			Context.getType(path);
			return true;
		}
		catch (_:Dynamic)
		{
			return false;
		}
	}
}
#else
class Boot {}
#end
