import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  static AudioPlayer audioPlayer = AudioPlayer();
  static Stream<Duration?>? _durationStream;
  static Stream<Duration>? _positionStream;

  static Future<void> play(String audioUrl) async {
    await audioPlayer.setUrl(audioUrl);
    _durationStream = audioPlayer.durationStream;
    _positionStream = audioPlayer.positionStream;
    audioPlayer.play();
  }

  static void pause() {
    audioPlayer.pause();
  }

  static void resume() {
    audioPlayer.play();
  }

  static void seekTo(Duration position) {
    audioPlayer.seek(position);
  }
}
