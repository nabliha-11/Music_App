import 'package:music_try/services/api_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:music_try/models/track.dart';
import 'package:music_try/models/playlist.dart';
import 'package:music_try/models/playlist_data.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class DatabaseHelper {
  // static final DatabaseHelper _instance = DatabaseHelper._internal();
  //
  // factory DatabaseHelper() {
  //   return _instance;
  // }
  // DatabaseHelper._internal();
  //
  // late sqflite.Database _database;

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

  static const _databaseName = 'music_try.db';
  //static const _databaseVersion = 1;

  static const _playlistTable = 'playlists';
  static const _columnId = 'id';
  static const _columnName = 'name';
  static const _columnDescription = 'description';
  static const _columnCoverImageUrl = 'coverImageUrl';


  // Future<void> initializeDatabase() async {
  //   final databasePath = await sqflite.getDatabasesPath();
  //   final pathToDatabase = path.join(databasePath, 'music_try.db');
  //
  //   _database = await sqflite.openDatabase(
  //     pathToDatabase,
  //     version: 1,
  //     onCreate: (db, version) {
  //       return db.execute(
  //         '''
  //         CREATE TABLE playlists (
  //           id INTEGER PRIMARY KEY AUTOINCREMENT,
  //           name TEXT,
  //           description TEXT,
  //           coverImageUrl TEXT
  //         )
  //         ''',
  //       );
  //     },
  //   );
  // }
  //
  // Future<int> insertPlaylist(PlaylistData playlist) async {
  //   return await _database.insert(
  //     'playlists',
  //     playlist.toMap(),
  //     conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
  //   );
  // }
  //
  // Future<List<PlaylistData>> getPlaylists() async {
  //   final List<Map<String, dynamic>> playlists = await _database.query('playlists');
  //   return playlists.map((map) => PlaylistData.fromMap(map)).toList();
  // }

  late Database? _database;
  static const int _databaseVersion = 2;

  Future<void> initializeDatabase() async {
    final databasePath = await getDatabasesPath();
    final pathToDatabase = path.join(databasePath, _databaseName);
    _database = await openDatabase(
      pathToDatabase,
      version: _databaseVersion,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_playlistTable (
        $_columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $_columnName TEXT NOT NULL,
        $_columnDescription TEXT NOT NULL,
        $_columnCoverImageUrl TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertPlaylist(PlaylistData playlist) async {
    print('track inserte');
    final db = _database!;
    final id = await db.insert(_playlistTable, playlist.toMap());
    return id;
  }

  Future<List<PlaylistData>> getPlaylists() async {
    final db = _database!;
    final maps = await db.query(_playlistTable);
    return List.generate(maps.length, (index) {
      return PlaylistData.fromMap(maps[index]);
    });
  }

  Future<void> updatePlaylist(PlaylistData playlist) async {
    final db = _database!;
    await db.update(
      _playlistTable,
      playlist.toMap(),
      where: '$_columnId = ?',
      whereArgs: [playlist.id],
    );
  }





  // Future<Database> get database async {
  //   if (_database != null) {
  //     return _database!;
  //   }
  //
  //   _database = await _initDatabase();
  //   return _database!;
  // }
  //
  // Future<Database> _initDatabase() async {
  //   final String databasesPath = await getDatabasesPath();
  //   final String path = join(databasesPath, dbName);
  //
  //   return await openDatabase(
  //     path,
  //     version: dbVersion,
  //     onCreate: _createDatabase,
  //   );
  // }
  //
  // Future<void> _createDatabase(Database db, int version) async {
  //   await db.execute('''
  //     CREATE TABLE $tablePlaylists (
  //       $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
  //       $columnName TEXT NOT NULL,
  //       $columnDescription TEXT NOT NULL,
  //       $columnCoverImageUrl TEXT NOT NULL
  //     )
  //   ''');
  // }
  //
  // Future<List<Playlist>> getPlaylists() async {
  //   final db = await database;
  //   final List<Map<String, dynamic>> maps = await db.query(tablePlaylists);
  //   return List.generate(maps.length, (index) {
  //     return Playlist.fromMap(maps[index]);
  //   });
  // }
  //
  //
  // Future<int> addPlaylist(Playlist playlist) async {
  //   final db = await database;
  //   return await db.insert(tablePlaylists, playlist.toMap());
  // }
  //
  //
  // Future<List<Playlist>> getAllPlaylists() async {
  //   final db = await database;
  //   final List<Map<String, dynamic>> maps = await db.query(tablePlaylists);
  //   return List.generate(maps.length, (index) {
  //     return Playlist(
  //       id: maps[index][columnId],
  //       name: maps[index][columnName],
  //       description: maps[index][columnDescription], // Add this line
  //       coverImageUrl: maps[index][columnCoverImageUrl], // Add this line
  //     );
  //   });
  // }
  //
  // Future<void> addTrackToPlaylist(int playlistId, Track track) async {
  //   final db = await database;
  //   await db.insert(
  //     tableTracks,
  //     {
  //       columnTrackId: track.id,
  //       columnPlaylistId: playlistId,
  //     },
  //     conflictAlgorithm: ConflictAlgorithm.replace,
  //   );
  // }

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
// Future<void> removeTrackFromPlaylist(int playlistId, String trackId) async {
//   final db = await database;
//   await db.delete(
//     tableTracks,
//     where: '$columnTrackId = ? AND $columnPlaylistId = ?',
//     whereArgs: [trackId, playlistId],
//   );
// }
}