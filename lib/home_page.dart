import 'dart:async';
import 'package:flutter/material.dart';
import 'package:music_try/models/track.dart';
import 'package:music_try/services/api_service.dart';
import 'package:music_try/player_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Track> tracks = [];
  List<Track> filteredTracks = [];

  @override
  void initState() {
    super.initState();
    fetchTracks('');
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PlayerPage(track: track)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Music App'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (query) => fetchTracks(query),
              decoration: InputDecoration(
                labelText: 'Search',
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
      ),
    );
  }
}
