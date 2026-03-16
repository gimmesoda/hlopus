# hlopus

Native Opus decoding for HashLink, with optional Heaps integration.

The library is based on [dtwotwo's pull request](https://github.com/HeapsIO/heaps/pull/1335).

## What it does

- adds `hlopus.Decoder` for plain HashLink projects
- adds Heaps integration so `.opus` resources are treated as `hxd.res.Sound`

## Possible questions

### Why should I use Opus?

With the same quality, Opus usually takes 15-25% less space than Ogg, which is especially useful when a project has a lot of audio assets.

## Plain HashLink usage

```haxe
final pcm = hlopus.Decoder.decodeFile("music.opus");
```

`decodeAll()` returns interleaved PCM. The default format is 16-bit signed samples.

If you want explicit control, use the decoder directly:

```haxe
final decoder = hlopus.Decoder.fromFile("music.opus");
final pcm = decoder.decodeAll(hlopus.SampleFormat.F32);
```

For streaming-style reads:

```haxe
final decoder = new hlopus.Decoder(sys.io.File.getBytes("music.opus"));
final chunk = decoder.readSamples(4096, hlopus.SampleFormat.I16);
```

## Heaps usage

If Heaps is present, `.opus` files are recognized as `hxd.res.Sound`, so you can use them like other sound resources:

```haxe
final sound = hxd.Res.music;
final channel = sound.play();
```

You can also create Heaps data manually:

```haxe
final data = hlopus.Decoder.toHeapsDataFromFile("music.opus");
```

## Build

The native build uses the bundled codec sources from `extension/lib`, so you do not need to wire Opus/Vorbis/Ogg into CMake manually.

Requirements:

- CMake 3.10+
- HashLink installed
- `HASHLINK` environment variable pointing to your HashLink folder

### Local build

The project includes a single Windows preset in `CMakePresets.json`.

```sh
cmake --preset release
cmake --build out/build/release --config Release
```

If you use Visual Studio, opening the folder is enough - it uses the same CMake project and presets.

### Outputs

The native target produces:

- `opus.hdll`
- `opus.lib` on Windows

To run a HashLink app with `hlopus`, place `opus.hdll` next to your `.hl` output, or otherwise make sure it is available in the current working directory / HashLink load path.

You can build it locally with CMake or download it from the GitHub Actions artifact and copy `opus.hdll` from there.

## TODO

- Linux support
- macOS support
