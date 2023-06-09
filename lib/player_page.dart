import 'package:flutter/material.dart';
import 'package:music_try/models/track.dart';
import 'package:music_try/services/audio_player_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_try/models/playlist.dart';

class PlayerPage extends StatefulWidget {
  final List<Track> playlist;
  //final Playlist playlist;
  final int initialTrackIndex;

  const PlayerPage({
    required this.playlist,
    required this.initialTrackIndex,
  });

  @override
  _PlayerPageState createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late AudioPlayer audioPlayer;
  final ValueNotifier<Duration> _positionNotifier = ValueNotifier(Duration.zero);
  final ValueNotifier<Duration> _durationNotifier = ValueNotifier(Duration.zero);
  late int _currentTrackIndex;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    _currentTrackIndex = widget.initialTrackIndex;
    _initAudioPlayer();
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
      _currentTrackIndex++;
      final track = widget.playlist[_currentTrackIndex];
      audioPlayer.setUrl(track.audioUrl);
      audioPlayer.play();

      setState(() {});
    }
  }

  void _skipToPreviousTrack() {
    if (_currentTrackIndex > 0) {
      _currentTrackIndex--;
      final track = widget.playlist[_currentTrackIndex];
      audioPlayer.setUrl(track.audioUrl);
      audioPlayer.play();

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final track = widget.playlist[_currentTrackIndex];

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
          title: Text('Player'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(track.albumArtwork),
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
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.skip_previous),
                    onPressed: _skipToPreviousTrack,
                  ),
                  IconButton(
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                    onPressed: _playPause,
                  ),
                  IconButton(
                    icon: Icon(Icons.skip_next),
                    onPressed: _skipToNextTrack,
                  ),
                ],
              ),
            ],
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
