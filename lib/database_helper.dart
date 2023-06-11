import 'package:music_try/services/api_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:music_try/models/track.dart';
import 'package:music_try/models/playlist.dart';
import 'package:music_try/models/playlist_data.dart';
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
  static const String columnArtist='artist';
  static const String columnAlbumArtwork='albumArt';
  static const String columnAudioUrl='audioUrl';
  static const _databaseName = 'music_try.db';
  static const _playlistTable = 'playlists';
  static const _columnId = 'id';
  static const _columnName = 'name';
  static const _columnDescription = 'description';
  static const _columnCoverImageUrl = 'coverImageUrl';

  late Database _database;

  DatabaseHelper() {
    initializeDatabase();
  }

  static const int _databaseVersion = 2;
  bool? _isDatabaseInitialized = false;

  Future<void> initializeDatabase() async {
    final databasePath = await getDatabasesPath();
    final pathToDatabase = path.join(databasePath, _databaseName);
    _database = await openDatabase(
      pathToDatabase,
      version: _databaseVersion,
      onCreate: _createDatabase,
    );
    _isDatabaseInitialized = true;
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

    await db.execute('''
    CREATE TABLE $tableTracks (
      $columnTrackId TEXT PRIMARY KEY,
      $columnName TEXT,
      $columnArtist TEXT,
      $columnAlbumArtwork TEXT,
      $columnAudioUrl TEXT,
      $columnPlaylistId INTEGER,
      FOREIGN KEY ($columnPlaylistId) REFERENCES $_playlistTable ($_columnId)
    )
  ''');
  }


  Future<int> insertPlaylist(PlaylistData playlist) async {
    print('track inserte');
    final db = _database;
    if (db != null) {
      final id = await db.insert(_playlistTable, playlist.toMap());
      return id;
    } else {
      throw Exception('Database not initialized');
    }
  }

  Future<List<PlaylistData>> getPlaylists() async {
    final db = _database;
    if (db != null) {
      final maps = await db.query(_playlistTable);
      return List.generate(maps.length, (index) {
        return PlaylistData.fromMap(maps[index]);
      });
    } else {
      throw Exception('Database not initialized');
    }
  }

  Future<void> updatePlaylist(PlaylistData playlist, Track track) async {
    print('updating');
    final db = _database;
    if (db != null) {
      await db.update(
        _playlistTable,
        playlist.toMap(),
        where: '$_columnId = ?',
        whereArgs: [playlist.id],
      );
      final int playlistId = playlist.id!;
      await insertTrack(track, playlistId);
    } else {
      throw Exception('Database not initialized');
    }
  }

  Future<void> insertTrack(Track track, int playlistId) async {
    print('track inserting');
    final db = _database;
    if (db != null) {
      final ii=
      await db.insert(tableTracks, {
        columnTrackId: track.id,
        columnName: track.name,
        columnArtist: track.artist,
        columnAlbumArtwork: track.albumArtwork,
        columnAudioUrl: track.audioUrl,
        columnPlaylistId: playlistId,
      }
      );
      print(track.name);
    } else {
      throw Exception('Database not initialized');
    }
  }

  Future<List<Track>> getSongsByPlaylistId(int playlistId) async {
    final db = _database;
    if (!_isDatabaseInitialized!) {
      throw Exception('Database not initialized');
    }
    if (db != null) {
      print('fetching songs');
      final List<Map<String, dynamic>> maps = await db.rawQuery(
        '''
    SELECT * FROM $tableTracks
    WHERE $columnPlaylistId = ?
    ''',
        [playlistId],
      );
      return List.generate(maps.length, (index) {
        return Track(
          id: maps[index][columnTrackId],
          name: maps[index][columnName],
          artist: maps[index][columnArtist],
          albumArtwork: maps[index][columnAlbumArtwork],
          audioUrl: maps[index][columnAudioUrl],
        );
      });
    } else {
      throw Exception('Database not initialized');
    }
  }

  // Future<List<Track>> getSongsByPlaylistId(int playlistId) async {
  //   final db = _database;
  //   if (!_isDatabaseInitialized!) {
  //     throw Exception('Database not initialized');
  //   }
  //   if (db != null) {
  //     print('fetching songs');
  //     final List<Map<String, dynamic>> maps = await db.rawQuery(
  //       '''
  //   SELECT * FROM $tableTracks
  //   INNER JOIN $_playlistTable ON $tableTracks.$columnPlaylistId = $_playlistTable.$_columnId
  //   WHERE $_playlistTable.$_columnId = ?
  //   ''',
  //       [playlistId],
  //     );
  //     print(maps);
  //     return List.generate(maps.length, (index) {
  //       print('hi');
  //       return Track(
  //         id: maps[index][columnTrackId].toString(),
  //         name: maps[index][columnName],
  //         artist: maps[index][columnArtist],
  //         albumArtwork: maps[index][columnAlbumArtwork],
  //         audioUrl: maps[index][columnAudioUrl],
  //       );
  //       print('gg');
  //     });
  //   } else {
  //     throw Exception('Database not initialized');
  //   }
  // }

  Future<List<Track>> getTracksByPlaylistId(
      String playlistId,
      String accessToken,
      ) async {
    final url = Uri.parse('https://api.spotify.com/v1/playlists/$playlistId/tracks');
    print(accessToken);
    print(playlistId);
    print('amar matha');
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
          audioUrl: trackData['preview_url'] ?? '',
        );
      });
    } else {
      throw Exception('Failed to fetch tracks');
    }
  }
}
