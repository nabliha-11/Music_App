import 'package:flutter/material.dart';
import 'package:music_try/database_helper.dart';
import 'package:music_try/models/playlist_data.dart';
import 'package:music_try/player_page.dart';

class LibraryTab extends StatefulWidget {
  @override
  _LibraryTabState createState() => _LibraryTabState();
}

class _LibraryTabState extends State<LibraryTab> {
  DatabaseHelper _databaseHelper = DatabaseHelper();
  List<PlaylistData> _playlists = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _databaseHelper.initializeDatabase();
    final playlists = await _databaseHelper.getPlaylists();
    setState(() {
      _playlists = playlists;
    });
  }

  void navigateToPlayerPage(PlaylistData playlist) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerPage(
          playlist: playlist.tracks,
          initialTrackIndex: 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _playlists.length,
        itemBuilder: (context, index) {
          final playlist = _playlists[index];
          return ListTile(
            leading: Image.network(playlist.coverImageUrl),
            title: Text(playlist.name),
            subtitle: Text(playlist.description),
            onTap: () => navigateToPlayerPage(playlist),
          );
        },
      ),
    );
  }
}
