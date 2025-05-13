import 'package:flutter/material.dart';
import 'torrent_sources.dart';
import 'package:url_launcher/url_launcher.dart';
import 'torrent_result.dart';
import 'sources/x1337_source.dart';
import 'sources/nsw2u_source.dart';

void main() {
  runApp(const PloofApp());
}

class PloofApp extends StatelessWidget {
  const PloofApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'putter torrent search',
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
  String? _errorMessage;
  final List<TorrentSource> _sources = [X1337Source(), Nsw2uSource()];
  late TorrentSource _selectedSource = _sources[0];

  void _performSearch() async {
    setState(() {
      _loading = true;
      _currentPage = 1;
      _results = [];
      _errorMessage = null;
    });
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _loading = false;
        _errorMessage = 'Search query cannot be empty.';
      });
      return;
    }
    _lastQuery = query;
    try {
      print('Searching for: "$query"');
      final results = _selectedSource is RequiresContext
    ? await (_selectedSource as dynamic).searchTorrents(query, page: 1, context: context)
    : await _selectedSource.searchTorrents(query, page: 1);
      print('Results count: \\${results.length}');
      setState(() {
        _results = results;
        _loading = false;
        _errorMessage = results.isEmpty ? 'No results found.' : null;
      });
    } catch (e, st) {
      print('Search error: $e\\n$st');
      setState(() {
        _loading = false;
        _errorMessage = 'Search failed: $e';
      });
    }
  }

  void _loadMore() async {
    setState(() => _loading = true);
    final nextPage = _currentPage + 1;
    final moreResults = _selectedSource is RequiresContext
    ? await (_selectedSource as dynamic).searchTorrents(_lastQuery, page: nextPage, context: context)
    : await _selectedSource.searchTorrents(_lastQuery, page: nextPage);
    setState(() {
      _currentPage = nextPage;
      _results.addAll(moreResults);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('putter torrent search')),
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
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            Expanded(
              child: _results.isEmpty && _errorMessage == null
                  ? const Center(child: Text('No results'))
                  : _results.isEmpty
                      ? const SizedBox.shrink()
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
                                            final uri = Uri.parse(url);
                                            print('[MAGNET] onTap for: $url');
                                            final canLaunch = await canLaunchUrl(uri);
                                            print('[MAGNET] canLaunchUrl: $canLaunch');
                                            if (canLaunch) {
                                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                                              print('[MAGNET] launchUrl called');
                                            } else {
                                              print('[MAGNET] cannot launch this magnet link');
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
                                            final uri = Uri.parse(url);
                                            print('[LINK] onTap for: $url');
                                            final canLaunch = await canLaunchUrl(uri);
                                            print('[LINK] canLaunchUrl: $canLaunch');
                                            if (canLaunch) {
                                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                                              print('[LINK] launchUrl called');
                                            } else {
                                              print('[LINK] cannot launch this link');
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
