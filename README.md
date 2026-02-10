# hlopus

Native support for the Opus audio codec for Heaps.io

The library is based on [dtwotwo's pull request](https://github.com/HeapsIO/heaps/pull/1335).

> [!WARNING]
To use the library, you need to [compile](#compilation) opus.hdll

## Possible questions

### Why should I use Opus?

With the same quality, Opus takes up 15-25% less space than Ogg, which is especially important if there are a lot of sounds in the game

### How will this change the way sounds are managed?

After installation, hxd.Res recognizes .opus files as `hxd.res.Sound`, so working with them is no different from other formats!

## Compilation

The library can be compiled in two ways

### Using Visual Studio

Just open the folder in Visual Studio and run the build

### Direct CMake build

If you use Linux or do not have Visual Studio, you can go this way

Make sure you have CMake 3.10+ installed, then run the following commands:

```sh
mkdir build
cd build
cmake build ..
```