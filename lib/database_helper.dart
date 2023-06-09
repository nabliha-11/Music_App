import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:music_try/models/track.dart';
import 'package:music_try/models/playlist.dart';
import 'package:music_try/models/playlist_data.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'services/api_service.dart';
class DatabaseHelper {
  static const String dbName = 'music_app.db';
  static const int dbVersion = 1;

  static const String tablePlaylists = 'playlists';
  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnDescription = 'description';
  static const String columnCoverImageUrl = 'cover_image_url';

  static const String tableTracks = 'tracks';
  static const String columnTrackId = 'id';
  static const String columnPlaylistId = 'playlist_id';

  late Database? _database;
  static const int _databaseVersion = 2;

  Future<void> initializeDatabase() async {
    final databasePath = await getDatabasesPath();
    final pathToDatabase = path.join(databasePath, 'music_try.db');
    _database = await openDatabase(
      pathToDatabase,
      version: _databaseVersion,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tablePlaylists (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnName TEXT NOT NULL,
        $columnDescription TEXT NOT NULL,
        $columnCoverImageUrl TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableTracks (
        $columnTrackId TEXT NOT NULL,
        $columnPlaylistId INTEGER NOT NULL,
        FOREIGN KEY ($columnPlaylistId) REFERENCES $tablePlaylists ($columnId) ON DELETE CASCADE
      )
    ''');
  }

  Future<int> insertPlaylist(PlaylistData playlist) async {
    final db = _database!;
    final id = await db.insert(tablePlaylists, playlist.toMap());
    return id;
  }

  Future<List<PlaylistData>> getPlaylists() async {
    final db = _database!;
    final maps = await db.query(tablePlaylists);
    return List.generate(maps.length, (index) {
      return PlaylistData.fromMap(maps[index]);
    });
  }

  Future<void> updatePlaylist(PlaylistData playlist) async {
    final db = _database!;
    await db.update(
      tablePlaylists,
      playlist.toMap(),
      where: '$columnId = ?',
      whereArgs: [playlist.id],
    );
  }

  Future<void> addTrackToPlaylist(int playlistId, Track track) async {
    final db = _database!;
    await db.insert(
      tableTracks,
      {
        columnTrackId: track.id,
        columnPlaylistId: playlistId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Track>> getTracksByPlaylistId(String playlistId, String accessToken) async {
    final url = Uri.parse('https://api.spotify.com/v1/playlists/$playlistId/tracks');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final List<dynamic> tracksData = jsonData['items'];

      return List.generate(tracksData.length, (index) {
        final trackData = tracksData[index]['track'];
        return Track(
          id: trackData['id'],
          name: trackData['name'],
          artist: trackData['artists'][0]['name'],
          albumArtwork: trackData['album']['images'][0]['url'],
          audioUrl: trackData['preview_url'] ?? '',
        );
      });
    } else {
      throw Exception('Failed to fetch playlist tracks');
    }
  }

  Future<void> removeTrackFromPlaylist(int playlistId, String trackId) async {
    final db = _database!;
    await db.delete(
      tableTracks,
      where: '$columnTrackId = ? AND $columnPlaylistId = ?',
      whereArgs: [trackId, playlistId],
    );
  }

  Future<Track?> fetchTrackById(String trackId) async {
    final url = Uri.parse('https://api.spotify.com/v1/tracks/$trackId');
    // Replace with your access token retrieval logic
    //final accessToken = await _getAccessToken();
    final accessToken = await ApiService.getAccessToken();
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final track = Track(
        id: jsonData['id'],
        name: jsonData['name'],
        artist: jsonData['artists'][0]['name'],
        albumArtwork: jsonData['album']['images'][0]['url'],
        audioUrl: jsonData['preview_url'] ?? '',
      );
      return track;
    } else {
      return null;
    }
  }


  // Future<String> _getAccessToken() {
  //   // Implement your access token retrieval logic here
  //   // This method should return a valid access token
  //   // You can use any mechanism to retrieve the access token, such as shared preferences, keychain, or API calls
  //   // Return a valid access token or throw an exception if retrieval fails
  //   //throw UnimplementedError('_getAccessToken() method not implemented');
  // }
}
