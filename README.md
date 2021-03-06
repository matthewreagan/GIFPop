![GIFPop Icon](/GIFPop/Assets.xcassets/AppIcon.appiconset/GIFPopIcon256.png?raw=true "GIFPop Icon")

# GIFPop!

GIFPop is a simple & free animated [.GIF](https://en.wikipedia.org/wiki/GIF) editor for Mac, written in [Swift](https://developer.apple.com/swift/). Its minimal UI wraps [gifsicle](https://github.com/kohler/gifsicle) under the hood, and currently supports the following:

- Resizing
- Optimizing
- Trimming frames
- Reducing colors

## How To Use

1. Drag a .gif onto the preview pane (or hit `Cmd-O` to choose a file)
2. Adjust the size, trimming, and other options if needed _(Note: only resizing is reflected in the preview, trimming and other options will be visible in the saved GIF)_
3. Click 'Save GIF...' to export the new GIF

![GIFPop Demo](/gifPopDemo.gif?raw=true "GIFPop Demo")

## Installation

- Either download and run the .xcodeproj, or you can use the precompiled app (below)
- If you have `gifsicle` installed, GIFPop will use your existing build for processing
- If you don't have `gifsicle` installed, GIFPop will use the precompiled version bundled with app

### System Requirements

- GIFPop currently targets macOS 10.9+

## Precompiled Binary

GIFPop is also available as a prebuilt (and unsigned) app here: [http://sound-of-silence.com/apps/GIFPop.zip](http://sound-of-silence.com/apps/GIFPop.zip) _(Last update: 10/16/2016)_

## Gifsicle

**GIFPop** provides a simple GUI for a few commonly-used features of [gifsicle](https://github.com/kohler/gifsicle), however it barely scratches the surface of what Gifsicle can do. For more options, you can run Gifsicle from the  command-line.

## ToDo's

GIFPop is still a work-in-progress. Current ToDo's include:

- [ ] Process GIFs in background and provide live previews (so that trimming, optimization, etc. are visible in the preview)
- [ ] Support export of resized gif by drag-and-drop
- [x] Improve constraints when very large GIFs are loaded
- [ ] Add options for frame delay changes
- [ ] Remember previously used options on launch (default optimization, etc)?
- [ ] Fix drag of new GIFs onto preview pane
- [ ] Provide a spinner or progress bar while processing large GIFs

## Author

**Matt Reagan** - Website: [http://sound-of-silence.com/](http://sound-of-silence.com/) - Twitter: [@hmblebee](https://twitter.com/hmblebee)


## License

**GIFPop**'s source code and related resources are Copyright (C) Matthew Reagan 2016. The source code is released under the [MIT License](https://opensource.org/licenses/MIT). **Gifsicle** is distributed under the GNU General Public License, Version 2.

## Acknowledgments

* GIFPop is just a UI wrapper for the very awesome Gifsicle tool. For more info visit the [gifsicle Homepage](http://www.lcdf.org/gifsicle/)
