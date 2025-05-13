import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import '../torrent_sources.dart';
import '../torrent_result.dart';

/// 1337x.to implementation
class X1337Source implements TorrentSource {
  @override
  String get name => '1337x';

  @override
  Future<List<TorrentResult>> searchTorrents(String query, {int page = 1}) async {
    final results = <TorrentResult>[];
    final searchUrl = 'https://www.1337x.to/search/${Uri.encodeComponent(query)}/$page/';
    print('[X1337Source] Search URL: $searchUrl');
    try {
      final response = await http.get(Uri.parse(searchUrl), headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36'
      });
      if (response.statusCode != 200) return results;

      final doc = html_parser.parse(response.body);
      final table = doc.querySelector('.table-list');
      if (table == null) return results;

      final rows = table.querySelectorAll('tr');
      for (final row in rows.skip(1).take(10)) {
        final cells = row.querySelectorAll('td');
        if (cells.length < 5) continue;

        final titleLink = cells[0].querySelector('a[href^="/torrent/"]');
        final title = titleLink?.text.trim() ?? '';
        final detailsPath = titleLink?.attributes['href'] ?? '';
        final detailsUrl = 'https://www.1337x.to$detailsPath';
        final seeders = int.tryParse(cells[1].text.trim()) ?? 0;
        final leechers = int.tryParse(cells[2].text.trim()) ?? 0;

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

        if (title.isNotEmpty && magnet.startsWith('magnet:')) {
          results.add(TorrentResult(
            title: title,
            seeders: seeders,
            leechers: leechers,
            magnet: magnet,
            url: detailsUrl,
          ));
        }
      }
    } catch (_) {}
    return results;
  }
}