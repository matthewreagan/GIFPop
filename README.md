# GIFPop!

GIFPop is a simple & free animated [.GIF](https://en.wikipedia.org/wiki/GIF) editor for Mac. Its minimal UI wraps [gifsicle](https://github.com/kohler/gifsicle) under the hood, and currently supports the following:

- Resizing GIFs
- Trimming frames
- Reducing colors
- Optimizing

## How To Use

1. Drag a .gif onto the preview pane (or hit `Cmd-O` to choose a file)
2. Adjust the size, trimming, and other options if needed _(Note: only resizing is reflected in the preview, trimming and other options will be visible in the saved GIF)_
3. Click 'Save GIF...' to export the new GIF

## Gifsicle

**GIFPop** provides a simple GUI for a few commonly-used features of [Gifsicle](https://github.com/kohler/gifsicle), however it barely scratches the surface of what Gifsicle can do. For more options, you can run Gifsicle from the  command-line.

## ToDo's

- [ ] Process GIFs in background and provide live previews (so that trimming, optimization, etc. are visible in the preview GIF)
- [ ] Support export of resized gif by drag-and-drop
- [ ] Add options for frame delay changes

## Author

**Matt Reagan** - Website: [http://sound-of-silence.com/](http://sound-of-silence.com/) - Twitter: [@hmblbee](https://twitter.com/hmblebee)


## License

**GIFPop**'s source code and related resources are Copyright (C) Matthew Reagan 2016. The source code is released under the [MIT License](https://opensource.org/licenses/MIT). **Gifsicle** is distributed under the GNU General Public License, Version 2.

## Acknowledgments

* GIFPop is just a UI wrapper for the very awesome Gifsicle tool. For more info visit the [Gifsicle Homepage](http://www.lcdf.org/gifsicle/)
