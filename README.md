# putter

A cross-platform torrent search app, ported from Python to Dart with Flutter.

## Features

- 🔍 Search torrents from 1337x (and easily extendable to more sources)
- 📊 View results with title, seeders, leechers, magnet link, and detail URL
- ➕ Pagination with "Load More"
- 🔗 Open magnet and detail links in your default app/browser
- 🛠️ Designed for extensibility: add new sources by implementing `TorrentSource`
- (WIP) Premiumize.me integration for sending magnets

## Screenshots
<!-- Add screenshots here if available -->

## Installation

See the releases page for pre-built APKs.

## Usage

- Enter a search query and press `Search` to fetch torrent results from 1337x.
- Click on a magnet link to open it in your default torrent client.
- Click on the detail URL to view more info in your browser.
- Click `Load More` to paginate results.

## Extending

To add a new torrent source:
1. Implement the `TorrentSource` abstract class in `lib/torrent_sources.dart`.
2. Add your new source to the `_sources` list in `main.dart`.

## Dependencies
- flutter
- http
- html
- url_launcher
- shared_preferences

## License

This project is licensed under the MIT License.

```
MIT License

Copyright (c) 2025 700zx1

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

## Contact

Project by [700zx1](https://github.com/700zx1)
