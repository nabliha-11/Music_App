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

  static Future<List<Playlist>> fetchNewReleasedPlaylists() async {
    final accessToken = await getAccessToken();

    final url = 'https://api.spotify.com/v1/browse/categories/pop/playlists';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    print("New release here");
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
        print("here1");
      }
      print("here2");
      print(playlists.length);
      return playlists;
    } else {
      throw Exception('Failed to fetch new released playlists1');
    }
  }

  static Future<List<Track>> fetchTracksByPlaylistId() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('Failed to get access token');
    }

    String playlistId='3cEYpjA9oz9GiPac4AsH4n';
    final url = Uri.parse('$baseUrl/playlists/$playlistId/tracks');

    final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $accessToken'},
    );
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
  static Future<List<Track>> fetchNewReleasedTracks() async {
    final accessToken = await getAccessToken();

    //final url = 'https://api.spotify.com/v1/browse/new-releases?country=BD';
    // final url = Uri.https(
    //   'api.spotify.com',
    //   '/v1/browse/new-releases',
    //   {'country': 'BD'},
    // );
    final url = Uri.parse('https://api.spotify.com/v1/browse/new-releases');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    print('fetchingggg');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data != null && data.containsKey('albums') && data['albums'].containsKey('items')) {
        final albumsData = data['albums']['items'];
        List<Track> tracks = [];

        for (var albumData in albumsData) {
          // Perform null checks for required fields
          final trackId = albumData['id'] ?? '';
          final trackName = albumData['name'] ?? '';
          final trackArtist = albumData['artists']?.isEmpty == false ? albumData['artists'][0]['name'] : '';
          final trackAlbumArtwork = albumData['images']?.isEmpty == false ? albumData['images'][0]['url'] : '';
          final trackAudioUrl = albumData['preview_url'] ?? '';

          // Create a new Track object
          final track = Track(
            id: trackId,
            name: trackName,
            artist: trackArtist,
            albumArtwork: trackAlbumArtwork,
            audioUrl: trackAudioUrl,
          );

          tracks.add(track);
          print(track.audioUrl);
        }

        return tracks;
      } else {
        throw Exception('Invalid response format: albums/items not found');
      }
    } else {
      throw Exception('Failed to fetch new released tracks: ${response.statusCode}');
    }
  }

  // static Future<List<Album>> fetchNewReleasedAlbums() async {
  //   final accessToken = await getAccessToken();
  //
  //   final url = 'https://api.spotify.com/v1/browse/new-releases?country=BD';
  //
  //   final response = await http.get(
  //     Uri.parse(url),
  //     headers: {
  //       'Authorization': 'Bearer $accessToken',
  //       'Content-Type': 'application/json',
  //     },
  //   );
  //
  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //
  //     if (data != null && data.containsKey('albums') && data['albums'].containsKey('items')) {
  //       final albumsData = data['albums']['items'];
  //       List<Album> albums = [];
  //
  //       for (var albumData in albumsData) {
  //         final albumId = albumData['id'] ?? '';
  //         final albumName = albumData['name'] ?? '';
  //         final albumArtwork = albumData['images'] != null && albumData['images'].isNotEmpty
  //             ? albumData['images'][0]['url']
  //             : '';
  //
  //         final tracks = await fetchTracksByAlbumId(albumId); // Fetch tracks for the album
  //
  //         final album = Album(
  //           id: albumId,
  //           name: albumName,
  //           artwork: albumArtwork,
  //           tracks: tracks,
  //         );
  //
  //         albums.add(album);
  //       }
  //
  //       return albums;
  //     } else {
  //       throw Exception('Invalid response format: albums/items not found');
  //     }
  //   } else {
  //     throw Exception('Failed to fetch new released albums: ${response.statusCode}');
  //   }
  // }
  // static Future<List<Track>> fetchTracksByAlbumId(String albumId) async {
  //   final accessToken = await getAccessToken();
  //
  //   final url = 'https://api.spotify.com/v1/albums/$albumId/tracks';
  //
  //   final response = await http.get(
  //     Uri.parse(url),
  //     headers: {
  //       'Authorization': 'Bearer $accessToken',
  //       'Content-Type': 'application/json',
  //     },
  //   );
  //
  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //
  //     if (data != null && data.containsKey('items')) {
  //       final tracksData = data['items'];
  //       List<Track> tracks = [];
  //
  //       for (var trackData in tracksData) {
  //         final trackId = trackData['id'] ?? '';
  //         final trackName = trackData['name'] ?? '';
  //         final trackArtist = trackData['artists']?.isEmpty == false ? trackData['artists'][0]['name'] : '';
  //         final trackAlbumArtwork = trackData['album']['images']?.isEmpty == false ? trackData['album']['images'][0]['url'] : '';
  //         final trackAudioUrl = trackData['preview_url'] ?? '';
  //
  //         final track = Track(
  //           id: trackId,
  //           name: trackName,
  //           artist: trackArtist,
  //           albumArtwork: trackAlbumArtwork,
  //           audioUrl: trackAudioUrl,
  //         );
  //
  //         tracks.add(track);
  //       }
  //
  //       return tracks;
  //     } else {
  //       throw Exception('Invalid response format: items not found');
  //     }
  //   } else {
  //     throw Exception('Failed to fetch tracks for album: $albumId, ${response.statusCode}');
  //   }
  // }
  //


}