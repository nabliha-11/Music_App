import 'package:flutter/material.dart';
import 'package:music_try/home_page.dart';
import 'package:music_try/player_page.dart';
import 'package:music_try/models/track.dart';
import 'package:music_try/models/playlist.dart';

class MusicApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/player': (context) {
          final Map<String, dynamic> arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          final Track track = arguments['track'];
          final List<Track> playlist = arguments['playlist'];
          final int initialTrackIndex = arguments['initialTrackIndex'];
          return PlayerPage(
            playlist: playlist,
            initialTrackIndex: initialTrackIndex,
          );
        },
      },
    );
  }
}
