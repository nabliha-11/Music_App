import 'dart:async';
import 'package:flutter/material.dart';
import 'package:music_try/models/track.dart';
import 'package:music_try/services/api_service.dart';
import 'package:music_try/player_page.dart';

class SearchTab extends StatefulWidget {
  @override
  _SearchTabState createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab>
    with SingleTickerProviderStateMixin {
  List<Track> tracks = [];
  List<Track> filteredTracks = [];
  TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  int _selectedTrackIndex = -1;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _scaleAnimation =
        Tween<double>(begin: 1.0, end: 0.95).animate(_animationController);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
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
    final playlist = [track];
    final initialTrackIndex = 0;
    // _animationController.reset();
    _animationController.forward().whenComplete(() {
      Navigator.push(
          context,
          PageRouteBuilder(
              transitionDuration: Duration(milliseconds: 800),
              pageBuilder: (context, animation, secondaryAnimation) {
                return SlideTransition(
                  position: animation.drive(
                    Tween(begin: Offset(1.0, 0.0), end: Offset.zero).chain(
                      CurveTween(curve: Curves.ease),
                    ),
                  ),
                  child: PlayerPage(
                    playlist: playlist,
                    initialTrackIndex: initialTrackIndex,
                  ),
                );
              })
          // MaterialPageRoute(
          //   builder: (context) => PlayerPage(
          //     playlist: playlist,
          //     initialTrackIndex: initialTrackIndex,
          //   ),
          // ),
          );
      _animationController.reset();
    });
  }

  Widget _buildListTile(int index, Track track) {
    final isSelected = index == _selectedTrackIndex;
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final scale = isSelected ? _scaleAnimation.value : 1.0;
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: ListTile(
        leading: Image.network(track.albumArtwork),
        title: Text(track.name),
        subtitle: Text(track.artist),
        onTap: () {
          setState(() {
            _selectedTrackIndex = index;
          });
          navigateToPlayerPage(track);
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
      child: Column(
        children: [
          const SizedBox(height: 16),
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
              style: const TextStyle(
                color: Colors.black45,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredTracks.length,
              itemBuilder: (context, index) {
                final track = filteredTracks[index];
                return _buildListTile(index, track);
              },
            ),
          ),
        ],
      ),
    );
  }
}
