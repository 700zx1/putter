import 'sources/x1337_source.dart';
import 'sources/nsw2u_source.dart';
import 'torrent_result.dart';

/// Abstract class for a torrent search source.
abstract class TorrentSource {
  String get name;
  Future<List<TorrentResult>> searchTorrents(String query, {int page});
}

/// Registry of all available torrent sources.
final List<TorrentSource> torrentSources = [
  X1337Source(),
  Nsw2uSource(),
];

// Add new sources by implementing TorrentSource and adding them to a list in the UI.
