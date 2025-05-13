/// Represents a torrent search result.
class TorrentResult {
  final String title;
  final int seeders;
  final int leechers;
  final String magnet;
  final String url;

  TorrentResult({
    required this.title,
    required this.seeders,
    required this.leechers,
    required this.magnet,
    required this.url,
  });
}