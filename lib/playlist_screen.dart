import 'package:flutter/material.dart';
import 'package:music_try/models/track.dart';
import 'package:music_try/database_helper.dart';
import 'package:music_try/models/playlist_data.dart';
import 'package:music_try/player_page.dart';
class PlaylistScreen extends StatefulWidget {
  final PlaylistData playlist;

  const PlaylistScreen({Key? key, required this.playlist}) : super(key: key);

  @override
  _PlaylistScreenState createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  late Future<List<Track>> _tracksFuture;
  late DatabaseHelper _databaseHelper;
  bool? _isDatabaseInitialized = false;

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper();
    _databaseHelper.initializeDatabase().then((_) {
      setState(() {
        _isDatabaseInitialized = true;
        _tracksFuture = _databaseHelper.getSongsByPlaylistId(widget.playlist.id!);
      });
    });
  }

  void _playSong(Track track) {
    // Implement your playback logic here
    // For example, navigate to the PlayerPage and pass the track
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerPage(
          playlist: widget.playlist.tracks,
          initialTrackIndex: 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isDatabaseInitialized!) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.playlist.name),
      ),
      body: FutureBuilder<List<Track>>(
        future: _tracksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final track = snapshot.data![index];
                return ListTile(
                  title: Text(track.name),
                  subtitle: Text(track.artist),
                  onTap: () {
                    _playSong(track); // Call _playSong method when tapped
                  },
                );
              },
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          return Center(
            child: Text('No tracks found.'),
          );
        },
      ),
    );
  }
}
