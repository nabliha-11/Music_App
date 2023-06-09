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
  TextEditingController _searchController = TextEditingController();

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      child: Column(
        children: [
          const SizedBox(height: 16,),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (query) => fetchTracks(query),
              decoration: const InputDecoration(
                hintText: 'What do you want to listen to?',
                hintStyle: TextStyle(color: Colors.black45),
                prefixIcon: Icon(Icons.search, color: Colors.black45),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black45),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black45),
                ),
              ),
              style:
                  const TextStyle(color: Colors.black45, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredTracks.length,
              itemBuilder: (context, index) {
                final track = filteredTracks[index];
                return ListTile(
                  leading: Image.network(track.albumArtwork),
                  title:
                      Text(track.name,),
                  subtitle:
                      Text(track.artist,),
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
