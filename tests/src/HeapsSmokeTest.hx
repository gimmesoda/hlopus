import sys.FileSystem;

final class HeapsSmokeTest extends hxd.App
{
	var channel:hxd.snd.Channel;
	var startPos = 0.0;
	var started = false;
	var startupTime = 0.0;

	override function init()
	{
		if (!FileSystem.exists("res/test.opus"))
			fail("Missing test file: res/test.opus");

		final sound = hxd.Res.test;
		final data = @:privateAccess sound.getData();

		Sys.println("[Heaps] loaded test.opus");
		Sys.println("[Heaps] sound=" + Type.getClassName(Type.getClass(sound)));
		Sys.println("[Heaps] data=" + Type.getClassName(Type.getClass(data)));
		Sys.println("[Heaps] rate=" + data.samplingRate + " channels=" + data.channels + " samples=" + data.samples);

		if (data.samples <= 0)
			fail("Decoded sample count is zero");
		if (data.channels <= 0)
			fail("Decoded channel count is zero");

		channel = sound.play(false, 1);

		if (channel == null)
			fail("sound.play() returned null");

		channel.onEnd = () ->
		{
			if (!started)
				fail("Playback ended before position advanced");
			Sys.println("[Heaps] PASS");
			Sys.exit(0);
		};

		startPos = channel.position;
	}

	override function update(dt:Float)
	{
		startupTime += dt;

		if (channel == null)
			return;

		if (!started && channel.position > startPos)
		{
			started = true;
			Sys.println("[Heaps] playback started");
		}

		if (!started && startupTime > 2.0)
			fail("Playback position did not advance");

		if (started && channel.position < 0)
			fail("Playback position became invalid");

		if (started && channel.duration > 0 && channel.position >= channel.duration)
		{
			Sys.println("[Heaps] PASS");
			Sys.exit(0);
		}
	}

	private function fail(message:String):Void
	{
		Sys.println("[Heaps] FAIL: " + message);
		Sys.exit(1);
	}

	private static function main()
	{
		hxd.Res.initLocal();
		new HeapsSmokeTest();
	}
}
