import 'dart:async';
import 'package:flutter/material.dart';
import 'package:music_try/models/track.dart';
import 'package:music_try/services/api_service.dart';
import 'package:music_try/player_page.dart';

class NewReleasedSong extends StatefulWidget {
  final List<Track> playlist;
  final int initialTrackIndex;

  const NewReleasedSong({
    required this.playlist,
    required this.initialTrackIndex,
  });

  @override
  _NewReleasedSongState createState() => _NewReleasedSongState();
}

class _NewReleasedSongState extends State<NewReleasedSong> {
  @override
  void initState() {
    super.initState();
  }

  void navigateToPlayerPageFromNewReleased(Track track) {
    final initialTrackIndex = widget.playlist.indexOf(track);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Material(
          child: PlayerPage(
            playlist: widget.playlist,
            initialTrackIndex: initialTrackIndex,
          ),
        ),
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
              // stops: [0.1, 0.3],
              colors: [Colors.white, Colors.blueGrey])),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('New Released Songs'),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.playlist.length,
                itemBuilder: (context, index) {
                  final track = widget.playlist[index];
                  return ListTile(
                    leading: track != null ? Image.network(track.albumArtwork) : null,
                    title: track != null ? Text(track.name) : null,
                    subtitle: track != null ? Text(track.artist) : null,
                    onTap: () => track != null ? navigateToPlayerPageFromNewReleased(track) : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
