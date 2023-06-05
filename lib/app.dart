import 'package:flutter/material.dart';
import 'package:music_try/home_page.dart';
import 'package:music_try/player_page.dart';
import 'package:music_try/models/track.dart';

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
        '/player': (context){
          final track = ModalRoute.of(context)!.settings.arguments as Track;
          return PlayerPage(track: track);
        },
      },
    );
  }
}
