import 'package:flutter/material.dart';
import 'package:music_try/models/playlist.dart';
import 'package:music_try/player_page.dart';
import 'package:music_try/services/spotify_api_service.dart';
import 'package:music_try/models/track.dart';
import 'package:music_try/database_helper.dart';
import 'package:music_try/trending.dart';

import '../services/api_service.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<Playlist> featuredPlaylists = [];

  @override
  void initState() {
    super.initState();
    _fetchFeaturedPlaylists();
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
          builder: (context) => TrendingSong(
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
      // decoration: BoxDecoration(
      //     gradient: LinearGradient(
      //         colors: [Colors.blueGrey.shade300, Colors.black],
      //         begin: Alignment.topLeft,
      //         end: Alignment.bottomRight,
      //         stops: const [0.1, 0.3])),
      decoration: const BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          // stops: [0.1, 0.3],
          colors: [Colors.white, Colors.blueGrey])),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // appBar: AppBar(
        //   // title: Text('Home'),
        // ),
        body: GridView.builder(
          padding: EdgeInsets.all(16),
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
                    // ),
                    // child: Column(
                    //   mainAxisAlignment: MainAxisAlignment.end,
                    //   children: [
                    //     Container(
                    //       color: Colors.black.withOpacity(0.6),
                    //       padding: EdgeInsets.all(8),
                    //       child: Text(
                    //         playlist.name,
                    //         style: TextStyle(
                    //           color: Colors.white,
                    //           fontSize: 16,
                    //           fontWeight: FontWeight.bold,
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ),
                ));
          },
        ),
      ),
    );
  }
}
