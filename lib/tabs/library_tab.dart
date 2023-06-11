import 'package:flutter/material.dart';
import 'package:music_try/database_helper.dart';
import 'package:music_try/models/playlist_data.dart';
import 'package:music_try/player_page.dart';
import 'package:music_try/playlist_screen.dart';

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

  void navigateToPlayScreen(PlaylistData playlist) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaylistScreen(playlist: playlist),
      ),
    );
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

  Future<void> _deletePlaylist(int playlistId) async {
    await _databaseHelper.deletePlaylist(playlistId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Playlist deleted')),
    );
    await _initializeData();
  }

  Widget _buildPlaylistItem(PlaylistData playlist) {
    return ListTile(
      leading: Image.network(playlist.coverImageUrl),
      title: Text(playlist.name),
      subtitle: Text(playlist.description),
      onTap: () => navigateToPlayScreen(playlist),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Delete Playlist'),
                content: Text('Are you sure you want to delete this playlist?'),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                    },
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await _deletePlaylist(playlist.id);
                      Navigator.pop(context); // Close the dialog
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.red,
                      ),
                    ),
                    child: Text('Delete'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.blueGrey],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: ListView.builder(
          itemCount: _playlists.length,
          itemBuilder: (context, index) {
            final playlist = _playlists[index];
            return _buildPlaylistItem(playlist);
          },
        ),
      ),
    );
  }
}
