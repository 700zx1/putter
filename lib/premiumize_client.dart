import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PremiumizeClient {
  static const _tokenKey = 'premiumize_token';
  String? _token;

  PremiumizeClient();

  Future<String?> loadOrPromptToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    // For now, just return the stored token. In a real app, prompt user if null.
    return _token;
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    _token = token;
  }

  Future<bool> sendMagnet(String magnet) async {
    if (_token == null) return false;
    final response = await http.post(
      Uri.parse('https://www.premiumize.me/api/transfer/create'),
      body: {'apikey': _token!, 'src': magnet},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['status'] == 'success';
    }
    return false;
  }
}
