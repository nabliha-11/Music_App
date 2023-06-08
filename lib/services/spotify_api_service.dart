import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:music_try/models/playlist.dart';
import 'package:music_try/models/track.dart';

class SpotifyApiService {
  static const String clientId = '8031d3b5a4e14fedbe67f6a6d5822f88';
  static const String clientSecret = 'dc2a8641a663418594395f945ced92a6';

  static const String baseUrl = 'https://api.spotify.com/v1';

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

  static Future<List<Playlist>> fetchFeaturedPlaylists() async {
    final accessToken = await getAccessToken();

    final url = 'https://api.spotify.com/v1/browse/featured-playlists';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(response.body);
      List<Playlist> playlists = [];
      for (var playlistData in data['playlists']['items']) {
        playlists.add(Playlist(
          id: playlistData['id'],
          name: playlistData['name'],
          description: playlistData['description'],
          coverImageUrl: playlistData['images'][0]['url'],
        ));
      }
      return playlists;
    } else {
      throw Exception('Failed to fetch featured playlists');
    }
  }
  static Future<List<Track>> fetchTracksByPlaylistId(String playlistId) async {
    final url = Uri.parse('$baseUrl/playlists/$playlistId/tracks');

    final response = await http.get(url);
    if (response.statusCode == 200) {

      final jsonData = jsonDecode(response.body);
      print(response.body);
      final tracksData = jsonData['items'];

      List<Track> tracks = [];

      for (var trackData in tracksData) {
        final trackId = trackData['track']['id'];
        final trackName = trackData['track']['name'];
        final trackArtist = trackData['track']['artists'][0]['name'];
        final trackAlbumArtwork = trackData['track']['album']['images'][0]['url'];
        final trackAudioUrl = trackData['track']['preview_url'];

        final track = Track(
          id: trackId,
          name: trackName,
          artist: trackArtist,
          albumArtwork: trackAlbumArtwork,
          audioUrl: trackAudioUrl,
        );

        tracks.add(track);
      }

      return tracks;
    } else {
      throw Exception('Failed to fetch tracks for playlist: ${response.statusCode}');
    }
  }
}
