import 'package:flutter/material.dart';
import 'package:music_try/models/track.dart';
import 'package:music_try/database_helper.dart';
import 'package:music_try/models/playlist_data.dart';
import 'package:music_try/player_page.dart';
import 'package:music_try/playlist_player_page.dart';
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
    print(widget.playlist.tracks);
  }

  void _playSong(List<Track> track,initialTraackIndex) {

    print('here');
    print(track);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaylistPlayerPage(
          playlist: track,
          initialTrackIndex: initialTraackIndex,
        ),
      ),
    );
  }
  void _deleteTrack(Track track) {
    _databaseHelper.deleteTrackFromPlaylist(track.id!, widget.playlist.id!);
    setState(() {
      _tracksFuture = _databaseHelper.getSongsByPlaylistId(widget.playlist.id!);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Track deleted from playlist'),
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
        appBar: AppBar(
          title: Text(widget.playlist.name),
          backgroundColor: Colors.blueGrey[300],
        ),
        body: FutureBuilder<List<Track>>(
          future: _tracksFuture,
          builder: (context, snapshot) {
            print(snapshot.data?.length);
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
                  return Dismissible(
                    key: Key(track.id.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 16.0),
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    onDismissed: (direction) {
                      _deleteTrack(track); // Call _deleteTrack method when dismissed
                    },
                    child: ListTile(
                      leading: Image.network(track.albumArtwork),
                      title: Text(track.name),
                      subtitle: Text(track.artist),
                      onTap: () {
                        _playSong(snapshot.data as List<Track>, index);
                      },
                    ),
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
      ),
    );
  }
}