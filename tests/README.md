# Tests

Before running the tests, get `opus.hdll` either from a local CMake build or from the GitHub Actions artifact zip, then copy it to the repository root:

```sh
copy out\build\release\extension\Release\opus.hdll .
```

The tests load `opus.hdll` from the current working directory.

## Native HashLink smoke test

```sh
haxe hl.hxml
hl hl_smoke.hl
```

This native test uses `hlopus.Decoder` + raw `hlopenal` directly.

Both tests now play the file until completion and exit automatically when playback finishes.

## Heaps smoke test

```sh
haxe heaps.hxml
hl heaps_smoke.hl
```
