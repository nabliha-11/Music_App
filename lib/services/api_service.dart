import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:music_try/models/track.dart';

class ApiService {
  static Future<List<Track>> fetchTracks(String query) async {
    final encodedQuery = Uri.encodeQueryComponent(query);
    final url = 'https://api.deezer.com/search?q=$encodedQuery';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<Track> tracks = [];
      for (var trackData in data['data']) {
        tracks.add(Track(
          id: trackData['id'],
          name: trackData['title'],
          artist: trackData['artist']['name'],
          albumArtwork: trackData['album']['cover_medium'],
          audioUrl: trackData['preview'],
        ));
      }
      return tracks;
    } else {
      throw Exception('Failed to fetch tracks');
    }
  }
}
