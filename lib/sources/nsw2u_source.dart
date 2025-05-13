import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import '../torrent_sources.dart';
import '../torrent_result.dart';

/// nsw2u.com implementation
class Nsw2uSource implements TorrentSource {
  @override
  String get name => 'nsw2u';

  @override
  Future<List<TorrentResult>> searchTorrents(String query, {int page = 1}) async {
    final results = <TorrentResult>[];
    final searchUrl = 'https://nsw2u.com/?s=${Uri.encodeComponent(query)}&paged=$page';
    try {
      final response = await http.get(Uri.parse(searchUrl), headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36'
      });
      if (response.statusCode != 200) return results;

      final doc = html_parser.parse(response.body);
      final posts = doc.querySelectorAll('.post');
      for (final post in posts) {
        final titleElement = post.querySelector('.entry-title a');
        final title = titleElement?.text.trim() ?? '';
        final detailsUrl = titleElement?.attributes['href'] ?? '';
        if (title.isEmpty || detailsUrl.isEmpty) continue;

        String magnet = '';
        try {
          final detailsResp = await http.get(Uri.parse(detailsUrl), headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36'
          });
          if (detailsResp.statusCode == 200) {
            final detailsDoc = html_parser.parse(detailsResp.body);
            final magnetLink = detailsDoc.querySelector('a[href^="magnet:"]');
            magnet = magnetLink?.attributes['href'] ?? '';
          }
        } catch (_) {}

        if (magnet.startsWith('magnet:')) {
          results.add(TorrentResult(
            title: title,
            seeders: 0,
            leechers: 0,
            magnet: magnet,
            url: detailsUrl,
          ));
        }
      }
    } catch (_) {}
    return results;
  }
}