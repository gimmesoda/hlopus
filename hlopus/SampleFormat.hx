package hlopus;

/**
	PCM sample formats supported by the Opus decoder.

	- `I16` returns signed 16-bit PCM.
	- `F32` returns 32-bit float PCM.
**/
enum abstract SampleFormat(Int) from Int to Int {
	final I16 = 2;
	final F32 = 3;

	/**
		Returns the byte size of a single sample in this format.
	**/
	public inline function getBytesPerSample():Int {
		return this == I16 ? 2 : 4;
	}
}
