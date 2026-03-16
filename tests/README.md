# Tests

Before running the tests, get `opus.hdll` either from a local CMake build or from the GitHub Actions artifact zip, then copy it to the repository root:

```sh
copy out\build\release\extension\Release\opus.hdll .
```

The tests load `opus.hdll` from the current working directory.

## Native HashLink smoke test

Open `test-hl.bat` to test it on Hashlink.

This native test uses `hlopus.Decoder` + raw `hlopenal` directly.

Both tests now play the file until completion and exit automatically when playback finishes.

## Heaps smoke test

Open `test-heaps.bat` to test it on Heaps.
