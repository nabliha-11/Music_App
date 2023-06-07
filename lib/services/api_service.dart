import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:music_try/models/track.dart';

class ApiService {
  static const String clientId = '8031d3b5a4e14fedbe67f6a6d5822f88';
  static const String clientSecret = 'dc2a8641a663418594395f945ced92a6';

  static Future<String> getAccessToken() async {
    final String basicAuth = base64.encode(utf8.encode('$clientId:$clientSecret'));

    final response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Authorization': 'Basic $basicAuth',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: 'grant_type=client_credentials',
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final accessToken = data['access_token'];
      return accessToken;
    } else {
      throw Exception('Failed to get access token');
    }
  }

  static Future<List<Track>> fetchTracks(String query) async {
    final accessToken = await getAccessToken();

    final encodedQuery = Uri.encodeQueryComponent(query);
    final url = 'https://api.spotify.com/v1/search?q=$encodedQuery&type=track';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);
      print(data);
      List<Track> tracks = [];
      for (var trackData in data['tracks']['items']) {
        tracks.add(Track(
          id: trackData['id'],
          name: trackData['name'],
          artist: trackData['artists'][0]['name'],
          albumArtwork: trackData['album']['images'][0]['url'],
          audioUrl: trackData['preview_url'],
        ));
      }
      return tracks;
    } else {
      throw Exception('Failed to fetch tracks');
    }
  }
}