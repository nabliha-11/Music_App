import 'package:music_try/services/api_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:music_try/models/track.dart';
import 'package:music_try/models/playlist.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class DatabaseHelper {
  static const String dbName = 'music_app.db';
  static const int dbVersion = 1;

  static const String tablePlaylists = 'playlists';
  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnDescription = 'description'; // Add this line
  static const String columnCoverImageUrl = 'cover_image_url'; // Add this line

  static const String tableTracks = 'tracks';
  static const String columnTrackId = 'id';
  static const String columnPlaylistId = 'playlist_id';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String databasesPath = await getDatabasesPath();
    final String path = join(databasesPath, dbName);

    return await openDatabase(
      path,
      version: dbVersion,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tablePlaylists (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnName TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableTracks (
        $columnTrackId TEXT PRIMARY KEY,
        $columnPlaylistId INTEGER NOT NULL,
        FOREIGN KEY ($columnPlaylistId) REFERENCES $tablePlaylists ($columnId)
      )
    ''');
  }

  Future<List<Playlist>> getPlaylists() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tablePlaylists);
    return List.generate(maps.length, (index) {
      return Playlist(
        id: maps[index][columnId],
        name: maps[index][columnName],
        description: maps[index][columnDescription], // Add this line
        coverImageUrl: maps[index][columnCoverImageUrl], // Add this line
      );
    });
  }

  Future<int> addPlaylist(Playlist playlist) async {
    final db = await database;
    return await db.insert(tablePlaylists, playlist.toMap());
  }

  Future<List<Playlist>> getAllPlaylists() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tablePlaylists);
    return List.generate(maps.length, (index) {
      return Playlist(
        id: maps[index][columnId],
        name: maps[index][columnName],
        description: maps[index][columnDescription], // Add this line
        coverImageUrl: maps[index][columnCoverImageUrl], // Add this line
      );
    });
  }

  Future<void> addTrackToPlaylist(int playlistId, Track track) async {
    final db = await database;
    await db.insert(
      tableTracks,
      {
        columnTrackId: track.id,
        columnPlaylistId: playlistId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Track>> getTracksByPlaylistId(String playlistId,String accessToken) async {
    final url = Uri.parse('https://api.spotify.com/v1/playlists/$playlistId/tracks');
    print(accessToken);
    print(playlistId);
    print('amar matha');
    //final accessToken=await ApiService.getAccessToken();
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      print('here2\n');
      print(response.body);
      final List<dynamic> tracksData = jsonData['items'];

      return List.generate(tracksData.length, (index) {
        final trackData = tracksData[index]['track'];
        print(trackData['preview_url']);
        return Track(
          id: trackData['id'],
          name: trackData['name'],
          artist: trackData['artists'][0]['name'],
          albumArtwork: trackData['album']['images'][0]['url'],
          audioUrl: trackData['preview_url']?? '',
        );
      });
    } else {
      throw Exception('Failed to fetch tracks');
    }
  }
  Future<void> removeTrackFromPlaylist(int playlistId, String trackId) async {
    final db = await database;
    await db.delete(
      tableTracks,
      where: '$columnTrackId = ? AND $columnPlaylistId = ?',
      whereArgs: [trackId, playlistId],
    );
  }
}
