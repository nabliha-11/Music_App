import 'dart:async';
import 'package:flutter/material.dart';
import 'package:music_try/models/track.dart';
import 'package:music_try/services/api_service.dart';
import 'package:music_try/player_page.dart';

import 'package:music_try/tabs/home_tab.dart';
import 'package:music_try/tabs/search_tab.dart';
import 'package:music_try/tabs/library_tab.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Widget> _tabs = [
    HomeTab(),
    SearchTab(),
    LibraryTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(left: 10.0), // Add left padding to the app bar title
          child: Text('Musicana'),
        ),
      ),
      body: _tabs[_currentIndex],
      // backgroundColor: Colors.black,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedLabelStyle: const TextStyle(color: Colors.white),
        selectedItemColor: Colors.white,
        backgroundColor: Colors.blueGrey[200],
        items:  [
          BottomNavigationBarItem(
              icon: Icon(Icons.home, color: Colors.blueGrey[700]), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, color: Colors.blueGrey[700]),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books, color: Colors.blueGrey[700]),
            label: 'Your Library',
          ),
        ],
      ),
    );
  }
}
