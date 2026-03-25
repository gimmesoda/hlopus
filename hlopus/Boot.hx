package hlopus;

#if macro
import haxe.macro.Compiler;
import haxe.macro.Context;
#if heaps
import hxd.res.Config;
#end

/**
	Macro bootstrap for Heaps Opus integration.

	Call `hlopus.Boot.setup()` from your build macros to register `.opus`
	resources as `hxd.res.Sound` and install the required sound patches.
**/
class Boot {
	/**
		Installs the Heaps resource and macro hooks for Opus support.
	**/
	public static function setup() {
		#if (haxe_ver >= 5)
		Context.onAfterInitMacros(() -> apply());
		#else
		apply();
		#end

		return null;
	}

	private static function apply() {
		#if heaps
		Config.addExtension("opus", "hxd.res.Sound");
		#end
		Compiler.addMetadata("@:build(hlopus.Macro.buildSoundFormat())", "hxd.res.SoundFormat");
		Compiler.addMetadata("@:build(hlopus.Macro.buildSound())", "hxd.res.Sound");
	}
}
#else

/**
	Runtime placeholder for non-macro builds.
**/
class Boot {}
#end
