class Genre {
  final String genreId;
  final String genreName;

  Genre({
    required this.genreId,
    required this.genreName,
  });

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      genreId: json['genre_id'] as String,
      genreName: json['genre_name'] as String,
    );
  }
}