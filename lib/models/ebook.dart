class Ebook {
  final String ebookId;
  final String title;
  final String author;
  final String? synopsis; // Added based on requirements
  final String genreId;
  final String fileUrl;
  final String? coverUrl; // Added for novel details view
  final String? genreName; // Added for easier display

  Ebook({
    required this.ebookId,
    required this.title,
    required this.author,
    this.synopsis,
    required this.genreId,
    required this.fileUrl,
    this.coverUrl,
    this.genreName,
  });

  factory Ebook.fromJson(Map<String, dynamic> json) {
    return Ebook(
      ebookId: json['ebook_id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      synopsis: json['synopsis'] as String?,
      genreId: json['genre_id'] as String,
      fileUrl: json['file_url'] as String,
      coverUrl: json['cover_url'] as String?,
      genreName: json['genre_name'] as String?, // Can be null if not joined
    );
  }
}