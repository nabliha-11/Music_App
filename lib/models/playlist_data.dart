import 'package:music_try/models/track.dart';

class PlaylistData {
  final int id;
  final String name;
  final String description;
  final String coverImageUrl;
  List<Track> tracks;

  PlaylistData({
    required this.id,
    required this.name,
    required this.description,
    required this.coverImageUrl,
    required this.tracks,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'coverImageUrl': coverImageUrl,
    };
  }

  factory PlaylistData.fromMap(Map<String, dynamic> map) {
    return PlaylistData(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      coverImageUrl: map['coverImageUrl'],
      tracks: [], // Initialize an empty list for tracks
    );
  }

  PlaylistData copyWith({
    int? id,
    String? name,
    String? description,
    String? coverImageUrl,
    List<Track>? tracks,
  }) {
    return PlaylistData(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      tracks: tracks ?? this.tracks,
    );
  }

  PlaylistData addTracks(List<Track> newTracks) {
    final updatedTracks = List.of(tracks);
    updatedTracks.addAll(newTracks);
    return copyWith(tracks: updatedTracks);
  }

  PlaylistData removeTrack(Track track) {
    final updatedTracks = List.of(tracks);
    updatedTracks.remove(track);
    return copyWith(tracks: updatedTracks);
  }


}
