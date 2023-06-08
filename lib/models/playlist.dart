class Playlist {
  final String id;
  final String name;
  final String description;
  final String coverImageUrl;

  Playlist({
    required this.id,
    required this.name,
    required this.description,
    required this.coverImageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'coverImageUrl': coverImageUrl,
    };
  }
}
