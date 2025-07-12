class Review {
  final String reviewId;
  final String ebookId;
  final String userId;
  final int rating;
  final String reviewText;
  final DateTime reviewDate;
  final String status;
  final String? userName; // For display purposes

  Review({
    required this.reviewId,
    required this.ebookId,
    required this.userId,
    required this.rating,
    required this.reviewText,
    required this.reviewDate,
    required this.status,
    this.userName,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewId: json['review_id'] as String,
      ebookId: json['ebook_id'] as String,
      userId: json['user_id'] as String,
      rating: json['rating'] as int,
      reviewText: json['review_text'] as String,
      reviewDate: DateTime.parse(json['review_date'] as String),
      status: json['status'] as String,
      userName: json['user_name'] as String?,
    );
  }
}