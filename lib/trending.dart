import 'dart:async';
import 'package:flutter/material.dart';
import 'package:music_try/models/track.dart';
import 'package:music_try/services/api_service.dart';
import 'package:music_try/player_page.dart';

class TrendingSong extends StatefulWidget {
  final List<Track> playlist;
  final int initialTrackIndex;

  const TrendingSong({
    required this.playlist,
    required this.initialTrackIndex,
  });

  @override
  _TrendingSongState createState() => _TrendingSongState();
}

class _TrendingSongState extends State<TrendingSong> {
  @override
  void initState() {
    super.initState();
  }

  void navigateToPlayerPageFromTrending(Track track) {
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Trending Songs'),
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
                  onTap: () => track != null ? navigateToPlayerPageFromTrending(track) : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
