class Ebook {
  final String ebookId;
  final String title;
  final String? author;
  final int? pageNumber;
  final int? price;
  final String? publisher;
  final int? monthPublished;
  final int? yearPublished;
  final String? genreId; // Assuming genreId can be null if not linked
  final String? genreName; // Make genreName nullable
  final String? synopsis; // <--- ADD THIS LINE
  final String? imgUrl; // Assuming img_url can be null if not provided

  Ebook({
    required this.ebookId,
    required this.title,
    required this.author,
    required this.pageNumber,
    required this.price,
    required this.publisher,
    required this.monthPublished,
    required this.yearPublished,
    this.genreId,
    this.genreName,
    this.synopsis, // <--- ADD THIS LINE TO THE CONSTRUCTOR
    this.imgUrl,
  });

  factory Ebook.fromJson(Map<String, dynamic> json) {
    return Ebook(
      ebookId: json['ebook_id'] as String,
      title: json['title'] as String,
      author: json['author'] as String?,
      pageNumber: json['page_number'] as int?,
      price: json['price'] as int?,
      publisher: json['publisher'] as String?,
      monthPublished: json['month_published'] as int?,
      yearPublished: json['year_published'] as int?,
      genreId: json['genre_id'] as String?,
      genreName: json['genre_name'] as String?,
      synopsis: json['synopsis'] as String?, // <--- ADD THIS LINE TO fromJson
      imgUrl: json['img_url'] as String?, // Assuming img_url can be null if not provided
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ebook_id': ebookId,
      'title': title,
      'author': author,
      'page_number': pageNumber,
      'price': price,
      'publisher': publisher,
      'month_published': monthPublished,
      'year_published': yearPublished,
      'genre_id': genreId,
      'genre_name': genreName,
      'synopsis': synopsis, // <--- ADD THIS LINE TO toJson (if you use it)
      'img_url': imgUrl, // Assuming img_url can be null if not provided
    };
  }
}