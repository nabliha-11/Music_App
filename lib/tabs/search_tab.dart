import 'dart:async';
import 'package:flutter/material.dart';
import 'package:music_try/models/track.dart';
import 'package:music_try/services/api_service.dart';
import 'package:music_try/player_page.dart';

class SearchTab extends StatefulWidget {
  @override
  _SearchTabState createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  List<Track> tracks = [];
  List<Track> filteredTracks = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> fetchTracks(String query) async {
    try {
      final tracksData = await ApiService.fetchTracks(query);
      setState(() {
        tracks = tracksData;
        filterTracks();
      });
    } catch (e) {
      print('Failed to fetch tracks: $e');
    }
  }

  void filterTracks() {
    setState(() {
      filteredTracks = tracks;
    });
  }

  void navigateToPlayerPage(Track track) {
    print(track.audioUrl);
    final playlist = [track];
    final initialTrackIndex = 0;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerPage(
          playlist: playlist,
          initialTrackIndex: initialTrackIndex,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            onChanged: (query) => fetchTracks(query),
            decoration: InputDecoration(
              labelText: 'What do you want to listen to?',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredTracks.length,
            itemBuilder: (context, index) {
              final track = filteredTracks[index];
              return ListTile(
                leading: Image.network(track.albumArtwork),
                title: Text(track.name),
                subtitle: Text(track.artist),
                onTap: () => navigateToPlayerPage(track),
              );
            },
          ),
        ),
      ],
    );
  }
}