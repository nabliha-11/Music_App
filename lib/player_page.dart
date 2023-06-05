import 'package:flutter/material.dart';
import 'package:music_try/models/track.dart';
import 'package:music_try/services/audio_player_service.dart';
import 'package:just_audio/just_audio.dart';

class PlayerPage extends StatefulWidget {
  final Track track;

  const PlayerPage({required this.track});

  @override
  _PlayerPageState createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  final AudioPlayer audioPlayer = AudioPlayer();
  final ValueNotifier<Duration> _positionNotifier = ValueNotifier(Duration.zero);
  final ValueNotifier<Duration> _durationNotifier = ValueNotifier(Duration.zero);

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  void _initAudioPlayer() {
    audioPlayer.setUrl(widget.track.audioUrl);
    audioPlayer.durationStream.listen((duration) {
      _durationNotifier.value = duration ?? Duration.zero;
    });
    audioPlayer.positionStream.listen((position) {
      _positionNotifier.value = position ?? Duration.zero;
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  void _play() async {
    await audioPlayer.play();
  }

  void _pause() {
    audioPlayer.pause();
  }

  void _resume() {
    audioPlayer.play();
  }

  void _seek(Duration position) {
    audioPlayer.seek(position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Player'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(widget.track.albumArtwork),
            SizedBox(height: 20),
            Text(
              widget.track.name,
              style: TextStyle(fontSize: 20),
            ),
            Text(
              widget.track.artist,
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
                    _seek(Duration(milliseconds: value.toInt()));
                  },
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _play,
                  child: Text('Play'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _pause,
                  child: Text('Pause'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _resume,
                  child: Text('Resume'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

