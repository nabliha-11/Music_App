import 'package:flutter/material.dart';
import 'package:music_try/models/playlist.dart';
import 'package:music_try/player_page.dart';
import 'package:music_try/services/spotify_api_service.dart';
import 'package:music_try/models/track.dart';
import 'package:music_try/database_helper.dart';
import 'package:music_try/trending.dart';

import '../new_released.dart';
import '../services/api_service.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<Playlist> featuredPlaylists = [];
  List<Playlist> newReleasedPlaylists = [];

  @override
  void initState() {
    super.initState();
    _fetchFeaturedPlaylists();
    _fetchNewReleasedPlaylists();
  }

  void _fetchFeaturedPlaylists() async {
    try {
      final playlists = await SpotifyApiService.fetchFeaturedPlaylists();
      setState(() {
        featuredPlaylists = playlists;
      });
    } catch (error) {
      print('Failed to fetch featured playlists: $error');
    }
  }

  void _openPlaylist(Playlist playlist) async {
    try {
      if (playlist == null) {
        print('Playlist is null');
        return;
      }

      final String accessToken = await ApiService.getAccessToken();
      // print('hi');
      print(accessToken);
      print(playlist.id);
      // print('why');
      final List<Track> tracks = await DatabaseHelper()
          .getTracksByPlaylistId(playlist.id, accessToken);
      print(tracks.length);
      if (tracks == null || tracks.isEmpty) {
        print('No tracks available');
        return;
      }
      final int initialTrackIndex = 0;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              TrendingSong(
                playlist: tracks ?? [], // Use empty list if tracks is null
                initialTrackIndex: initialTrackIndex,
              ),
        ),
      );
    } catch (error) {
      print('Failed to open playlist: $error');
    }
  }

  void _fetchNewReleasedPlaylists() async {
    try {
      final playlists = await SpotifyApiService.fetchNewReleasedPlaylists();
      setState(() {
        newReleasedPlaylists = playlists;
        // print(newReleasedPlaylists.length);
      });
    } catch (error) {
      print('Failed to fetch new released playlists: $error');
    }
  }

  void _openNewReleasedPlaylist(Playlist playlist) async {
    try {
      if (playlist == null) {
        print('Playlist is null');
        return;
      }

      final String accessToken = await ApiService.getAccessToken();
      // print('hi');
      // print(accessToken);
      // print(playlist.id);
      // print('why');
      final List<Track> tracks = await DatabaseHelper()
          .getTracksByPlaylistId(playlist.id, accessToken);
      print(tracks.length);
      if (tracks == null || tracks.isEmpty) {
        print('No tracks available');
        return;
      }
      final int initialTrackIndex = 0;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              NewReleasedSong(
                playlist: tracks ?? [], // Use empty list if tracks is null
                initialTrackIndex: initialTrackIndex,
              ),
        ),
      );
    } catch (error) {
      print('Failed to open playlist: $error');
    }
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
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          // Add padding to the SingleChildScrollView
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // Align items at the start
            children: [
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                // Add left padding to the heading
                child: Text(
                  'Top Hits',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[700],
                  ),
                ),
              ),
              Container(
                height: 200,
                child: ListView.builder(
                  padding: EdgeInsets.only(top: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: newReleasedPlaylists.length,
                  itemBuilder: (context, index) {
                    final playlist1 = newReleasedPlaylists[index];
                    return GestureDetector(
                      onTap: () {
                        _openNewReleasedPlaylist(playlist1);
                      },
                      child: Container(
                        width: 150,
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(playlist1.coverImageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                // Add left padding to the heading
                child: Text(
                  'Featured Playlists',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[700],
                  ),
                ),
              ),
              GridView.builder(
                padding: EdgeInsets.only(top: 16),
                // Add top padding to the GridView
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: featuredPlaylists.length,
                itemBuilder: (context, index) {
                  final playlist = featuredPlaylists[index];
                  return GestureDetector(
                    onTap: () {
                      _openPlaylist(playlist);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(playlist.coverImageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}