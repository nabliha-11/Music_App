import 'package:flutter/material.dart';
import 'package:music_try/models/track.dart';
import 'package:music_try/services/audio_player_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_try/models/playlist.dart';
import 'package:music_try/database_helper.dart';
import 'package:music_try/models/playlist_data.dart';


class PlaylistPlayerPage extends StatefulWidget {
  final List<Track> playlist;
  final int initialTrackIndex;

  const PlaylistPlayerPage({
    required this.playlist,
    required this.initialTrackIndex,
  });

  @override
  _PlaylistPlayerPageState createState() => _PlaylistPlayerPageState();
}

class _PlaylistPlayerPageState extends State<PlaylistPlayerPage> {
  late AudioPlayer audioPlayer;
  final ValueNotifier<Duration> _positionNotifier = ValueNotifier(Duration.zero);
  final ValueNotifier<Duration> _durationNotifier = ValueNotifier(Duration.zero);
  late int _currentTrackIndex;
  bool _isPlaying = false;
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<PlaylistData> playlists = [];
  PlaylistData? selectedPlaylist;

  @override
  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    if (widget.initialTrackIndex >= 0 && widget.initialTrackIndex < widget.playlist.length) {
      _currentTrackIndex = widget.initialTrackIndex;
    } else {
      _currentTrackIndex = 0;
    }
    _initAudioPlayer();
    _playPause();
  }


  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  void _initAudioPlayer() async {
    final track = widget.playlist[_currentTrackIndex];

    await audioPlayer.setUrl(track.audioUrl);
    audioPlayer.durationStream.listen((duration) {
      _durationNotifier.value = duration ?? Duration.zero;
    });
    audioPlayer.positionStream.listen((position) {
      _positionNotifier.value = position ?? Duration.zero;
    });
    audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        _skipToNextTrack();
      }
    });
    setState(() {});
  }
  void _updateAudioPlayer() async {
    final track = widget.playlist[_currentTrackIndex];

    await audioPlayer.setUrl(track.audioUrl);

    setState(() {
      // Update the initialTrackIndex to reflect the current track
    });
  }

  void _playPause() {
    if (_isPlaying) {
      audioPlayer.pause();
    } else {
      audioPlayer.play();
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _seek(Duration position) {
    audioPlayer.seek(position);
  }

  void _skipToNextTrack() {
    if (_currentTrackIndex < widget.playlist.length - 1) {
      setState(() {
        _currentTrackIndex++;
      });
      _updateAudioPlayer();
    }
  }

  void _skipToPreviousTrack() {
    if (_currentTrackIndex > 0) {
      setState(() {
        _currentTrackIndex--;
      });
      _updateAudioPlayer();
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    final track = widget.playlist[_currentTrackIndex];

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
          title: Text('Musicana'),
          backgroundColor: Colors.blueGrey[300],
        ),
        body: Center(
          child: Padding(
            padding:  EdgeInsets.only(bottom: kToolbarHeight),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Image.network(
                    track.albumArtwork,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.network(
                        'https://i.pinimg.com/originals/31/fe/56/31fe56e7053b5e9085373c666bc252e3.jpg', // Replace with your default image URL
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  track.name,
                  style: TextStyle(fontSize: 20),
                ),
                Text(
                  track.artist,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                ValueListenableBuilder<Duration>(
                  valueListenable: _positionNotifier,
                  builder: (context, position, child) {
                    final maxDuration = _durationNotifier.value;
                    return Slider(
                      min: 0,
                      max: maxDuration.inMilliseconds.toDouble(),
                      value: position.inMilliseconds.toDouble().clamp(0, maxDuration.inMilliseconds.toDouble()),
                      onChanged: (value) {
                        final duration = Duration(milliseconds: value.round());
                        _seek(duration);
                      },
                      activeColor: Colors.black54,
                    );
                  },
                ),
                ValueListenableBuilder<Duration>(
                  valueListenable: _positionNotifier,
                  builder: (context, position, child) {
                    return Text(positionToString(position));
                  },
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      iconSize: 36,
                      icon: Icon(Icons.skip_previous),
                      onPressed: _skipToPreviousTrack,
                    ),
                    SizedBox(width: 16),
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 150),
                      transitionBuilder: (child, animation) {
                        final curvedAnimation = CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOut,
                        );
                        return RotationTransition(
                          turns: curvedAnimation,
                          child: child,
                        );
                      },
                      child: _isPlaying
                          ? GestureDetector(
                        key: ValueKey(Icons.pause),
                        onTap: _playPause,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black54,
                          ),
                          child: Icon(
                            Icons.pause,
                            size: 44,
                            color: Colors.white,
                          ),
                        ),
                      )
                          : GestureDetector(
                        key: ValueKey(Icons.play_arrow),
                        onTap: _playPause,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black54,
                          ),
                          child: Icon(
                            Icons.play_arrow,
                            size: 44,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    IconButton(
                      iconSize: 36,
                      icon: Icon(Icons.skip_next),
                      onPressed: _skipToNextTrack,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  String positionToString(Duration position) {
    final minutes = position.inMinutes;
    final seconds = (position.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
