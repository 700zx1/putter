import 'package:flutter/material.dart';
import 'torrent_sources.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const PloofApp());
}

class PloofApp extends StatelessWidget {
  const PloofApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ploof Torrent Search',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TorrentSearchPage(),
    );
  }
}

class TorrentSearchPage extends StatefulWidget {
  const TorrentSearchPage({super.key});

  @override
  State<TorrentSearchPage> createState() => _TorrentSearchPageState();
}

class _TorrentSearchPageState extends State<TorrentSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _loading = false;
  List<TorrentResult> _results = [];
  int _currentPage = 1;
  String _lastQuery = '';
  final List<TorrentSource> _sources = [X1337Source()];
  late TorrentSource _selectedSource = _sources[0];

  void _performSearch() async {
    setState(() {
      _loading = true;
      _currentPage = 1;
      _results = [];
    });
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    _lastQuery = query;
    final results = await _selectedSource.searchTorrents(query, page: 1);
    setState(() {
      _results = results;
      _loading = false;
    });
  }

  void _loadMore() async {
    setState(() => _loading = true);
    final nextPage = _currentPage + 1;
    final moreResults = await _selectedSource.searchTorrents(_lastQuery, page: nextPage);
    setState(() {
      _currentPage = nextPage;
      _results.addAll(moreResults);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ploof Torrent Search')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
  children: [
    DropdownButton<TorrentSource>(
      value: _selectedSource,
      onChanged: (source) {
        if (source != null) setState(() => _selectedSource = source);
      },
      items: _sources.map((source) {
        return DropdownMenuItem<TorrentSource>(
          value: source,
          child: Text(source.name),
        );
      }).toList(),
    ),
    const SizedBox(width: 8),
    Expanded(
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          labelText: 'Search torrents...',
        ),
        onSubmitted: (_) => _performSearch(),
      ),
    ),
    const SizedBox(width: 8),
    ElevatedButton(
      onPressed: _loading ? null : _performSearch,
      child: _loading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Search'),
    ),
  ],
),
            const SizedBox(height: 24),
            Expanded(
  child: _results.isEmpty
      ? const Center(child: Text('No results'))
      : SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Title')),
                DataColumn(label: Text('Seeders')),
                DataColumn(label: Text('Leechers')),
                DataColumn(label: Text('Magnet Link')),
                DataColumn(label: Text('URL')),
              ],
              rows: _results
                  .map(
                    (r) => DataRow(cells: [
                      DataCell(Text(r.title)),
                      DataCell(Text(r.seeders.toString())),
                      DataCell(Text(r.leechers.toString())),
                      DataCell(
                        InkWell(
                          child: Text(
                            r.magnet,
                            style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          onTap: () async {
                            final url = r.magnet;
                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(Uri.parse(url));
                            }
                          },
                        ),
                      ),
                      DataCell(
                        InkWell(
                          child: Text(
                            r.url,
                            style: const TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline),
                          ),
                          onTap: () async {
                            final url = r.url;
                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(Uri.parse(url));
                            }
                          },
                        ),
                      ),
                    ]),
                  )
                  .toList(),
            ),
          ),
        ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loading ? null : _loadMore,
              child: _loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Load More'),
            ),
          ],
        ),
      ),
    );
  }
}

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
