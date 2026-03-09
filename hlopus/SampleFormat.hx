package hlopus;

enum abstract SampleFormat(Int) from Int to Int
{
	final I16 = 2;
	final F32 = 3;

	public inline function getBytesPerSample():Int
	{
		return this == I16 ? 2 : 4;
	}
}
