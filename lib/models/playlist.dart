class Playlist {
  final String name;
  final List<String> songIds;
  final DateTime createdAt;

  Playlist({
    required this.name,
    required this.songIds,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'songIds': songIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      name: json['name'],
      songIds: List<String>.from(json['songIds']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
} 