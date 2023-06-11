import 'package:flutter/material.dart';
import 'package:flutter_sequence_animation/flutter_sequence_animation.dart';
import 'package:music_try/models/track.dart';
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

class _TrendingSongState extends State<TrendingSong> with SingleTickerProviderStateMixin {
  int _selectedTrackIndex = -1;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToPlayerPageFromTrending(Track track, int initialTrackIndex) {
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
    _animationController.reset();
  }

  void _animateTrackSelection(Track track) {
    setState(() {
      _selectedTrackIndex = widget.playlist.indexOf(track);
    });
    _animationController.reset();
    _animationController.forward().whenComplete(() {
      final initialTrackIndex = widget.playlist.indexOf(track);
      _navigateToPlayerPageFromTrending(track, initialTrackIndex);
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
        leading: track != null ? Image.network(track.albumArtwork) : null,
        title: track != null ? Text(track.name) : null,
        subtitle: track != null ? Text(track.artist) : null,
        onTap: () {
          setState(() {
            _selectedTrackIndex = index;
          });
          final selectedTrack = widget.playlist[index];
          _animateTrackSelection(selectedTrack);
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
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Featured Songs'),
          backgroundColor: Colors.blueGrey[300],
        ),
        body: ListView.builder(
          itemCount: widget.playlist.length,
          itemBuilder: (context, index) {
            final track = widget.playlist[index];
            return _buildListTile(index, track);
          },
        ),
      ),
    );
  }
}
