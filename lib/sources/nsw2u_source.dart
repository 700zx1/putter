import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:html/parser.dart' as html_parser;
import '../torrent_sources.dart';
import '../torrent_result.dart';
import 'dart:developer';
import 'package:flutter/material.dart';
import '../captcha_webview.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'dart:io' as io;

class Nsw2uSource implements TorrentSource, RequiresContext {
  final Dio _dio = Dio();
  final CookieJar _cookieJar = CookieJar();
  bool _captchaSolved = false;

  Nsw2uSource() {
    // Attach the CookieJar to Dio for automatic cookie management
    _dio.interceptors.add(CookieManager(_cookieJar));
    _dio.options.headers = {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
      'Accept':
          'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
      'Accept-Language': 'en-US,en;q=0.5',
      'Referer': 'https://nsw2u.com/',
      'Connection': 'keep-alive',
      'Cache-Control': 'max-age=0',
    };
    _dio.options.validateStatus = (status) {
      return status != null && status < 500; // Allow 4xx responses
    };

    // Load cookies from file
    //_loadCookies();
  }

  /// Call this from your UI to solve CAPTCHA and store cookies in Dio's CookieJar.
  Future<void> solveCaptchaWithWebView(BuildContext context) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CaptchaWebView(
        url: WebUri('https://nsw2u.com'),
        onCaptchaSolved: (cookies) {
          for (final c in cookies) {
            final ioCookie = io.Cookie(c.name, c.value);
            if (c.domain != null) ioCookie.domain = c.domain!;
            if (c.path != null) ioCookie.path = c.path!;
            if (c.expiresDate != null)
              ioCookie.expires =
                  DateTime.fromMillisecondsSinceEpoch(c.expiresDate!);
            if (c.isHttpOnly != null) ioCookie.httpOnly = c.isHttpOnly!;
            if (c.isSecure != null) ioCookie.secure = c.isSecure!;
            _cookieJar
                .saveFromResponse(Uri.parse('https://nsw2u.com'), [ioCookie]);
          }
          _captchaSolved = true;
          log('Cookies from CAPTCHA WebView saved to Dio.');
        },
      ),
    ));
  }

  Future<void> ensureCaptchaSolved(BuildContext context) async {
    if (!_captchaSolved) {
      await solveCaptchaWithWebView(context);
    }
  }

  @override
  String get name => 'nsw2u';

  @override
  Future<List<TorrentResult>> searchTorrents(String query,
      {int page = 1, required BuildContext context}) async {
    await ensureCaptchaSolved(context);
    final results = <TorrentResult>[];
    final searchUrl =
        'https://nsw2u.com/?s=${Uri.encodeComponent(query)}&paged=$page';
    log('Search URL: $searchUrl'); // Debugging: Log the search URL

    try {
      // Perform the search request
      final response = await _dio.get(searchUrl);
      log('Search response status: ${response.statusCode}'); // Debugging: Log response status

      // Log the response body for debugging
      log('Search response body: ${response.data}'); // Debugging: Log the response body

      if (response.statusCode == 200) {
        final doc = html_parser.parse(response.data);
        final posts = doc.querySelectorAll('.post');
        log('Number of posts found: ${posts.length}'); // Debugging: Log the number of posts

        for (final post in posts) {
          final titleElement = post.querySelector('.entry-title a');
          final title = titleElement?.text.trim() ?? '';
          final detailsUrl = titleElement?.attributes['href'] ?? '';
          log('Post title: $title'); // Debugging: Log the post title
          log('Details URL: $detailsUrl'); // Debugging: Log the details URL

          if (title.isEmpty || detailsUrl.isEmpty) continue;

          String magnet = '';
          try {
            // Fetch the details page
            final detailsResp = await _dio.get(detailsUrl);
            log('Details response status: ${detailsResp.statusCode}'); // Debugging: Log details response status

            // Log the details response body for debugging
            log('Details response body: ${detailsResp.data}'); // Debugging: Log the details response body

            if (detailsResp.statusCode == 200) {
              final detailsDoc = html_parser.parse(detailsResp.data);

              // Locate the "Torrent" label and find the ouo.com link below it
              final torrentLabel =
                  detailsDoc.querySelector('p:contains("Torrent")');
              log('Torrent label found: ${torrentLabel != null}'); // Debugging: Log if the Torrent label is found

              if (torrentLabel != null) {
                final ouoLink = torrentLabel.nextElementSibling
                    ?.querySelector('a[href*="ouo.com"]');
                log('Ouo.com link found: ${ouoLink != null}'); // Debugging: Log if the ouo.com link is found

                if (ouoLink != null) {
                  final ouoUrl = ouoLink.attributes['href'] ?? '';
                  log('Ouo.com URL: $ouoUrl'); // Debugging: Log the ouo.com URL

                  // Resolve the ouo.com link to find the magnet link
                  final resolvedResp = await _dio.get(ouoUrl);
                  log('Resolved response status: ${resolvedResp.statusCode}'); // Debugging: Log resolved response status

                  // Log the resolved response body for debugging
                  log('Resolved response body: ${resolvedResp.data}'); // Debugging: Log the resolved response body

                  if (resolvedResp.statusCode == 200) {
                    final resolvedDoc = html_parser.parse(resolvedResp.data);
                    final magnetLink =
                        resolvedDoc.querySelector('a[href^="magnet:"]');
                    magnet = magnetLink?.attributes['href'] ?? '';
                    log('Magnet link: $magnet'); // Debugging: Log the magnet link
                  }
                }
              }
            }
          } catch (e, st) {
            log('Error resolving magnet link: $e\n$st'); // Debugging: Log any errors
          }

          if (magnet.startsWith('magnet:')) {
            results.add(TorrentResult(
              title: title,
              seeders: 0,
              leechers: 0,
              magnet: magnet,
              url: detailsUrl,
            ));
            log('Added result: $title'); // Debugging: Log when a result is added
          }
        }
      }
    } catch (e, st) {
      log('Error during search: $e\n$st'); // Debugging: Log any errors during the search
    }

    log('Total results found: ${results.length}'); // Debugging: Log the total number of results
    return results;
  }
}
