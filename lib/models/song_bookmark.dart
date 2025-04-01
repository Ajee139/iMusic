class SongBookmark {
  final String songUri;
  final Map<String, int> bookmarks; // Key is bookmark name, value is timestamp in seconds

  SongBookmark({
    required this.songUri,
    required this.bookmarks,
  });

  Map<String, dynamic> toJson() {
    return {
      'songUri': songUri,
      'bookmarks': bookmarks,
    };
  }

  factory SongBookmark.fromJson(Map<String, dynamic> json) {
    return SongBookmark(
      songUri: json['songUri'],
      bookmarks: Map<String, int>.from(json['bookmarks']),
    );
  }
} 