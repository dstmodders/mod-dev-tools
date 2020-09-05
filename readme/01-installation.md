# Installation

## Steam Workshop

The easiest way to install this mod is by subscribing to it using the Steam
Workshop: [https://steamcommunity.com/sharedfiles/filedetails/?id=2220506640][]

This way the mod can be automatically updated upon a new version release by
using the in-game **Mods** submenu.

## Manually

If you would like to install the mod manually for example on devices where you
don't have access to the [Steam Workshop][] you can:

1. Download either the **Source code** or **Workshop** version from the [Releases][] page.
2. Unpack the archive and move it to the game mods' directory.

Keep in mind, that you will need to manually update the mod each time a new
version has been released.

### Steam (Linux)

The mods' directory path on Linux installed through [Steam][]:

```text
/home/<your username>/.steam/steam/steamapps/common/Don't Starve Together/mods/
```

### Steam (Windows)

The mods' directory path on Windows installed through [Steam][]:

```text
C:\Program Files (x86)\Steam\steamapps\common\Don't Starve Together\mods\
```

## Makefile

_Currently, only Linux is supported. However, the Windows support has also been
under consideration by incorporating a [CMake][] or [NMake][] equivalents._

Since this project uses [Makefile][] it includes the rule to install the mod for
the game installed throughout [Steam][] as well:

```shell script
$ make install
```

[cmake]: https://cmake.org/
[https://steamcommunity.com/sharedfiles/filedetails/?id=2220506640]: https://steamcommunity.com/sharedfiles/filedetails/?id=2220506640
[makefile]: https://en.wikipedia.org/wiki/Makefile
[nmake]: https://msdn.microsoft.com/en-us/library/dd9y37ha.aspx
[releases]: https://github.com/victorpopkov/dst-mod-dev-tools/releases
[steam workshop]: https://steamcommunity.com/sharedfiles/filedetails/?id=2220506640
[steam]: https://store.steampowered.com/
