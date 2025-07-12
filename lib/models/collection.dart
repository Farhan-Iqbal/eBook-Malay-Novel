import 'ebook.dart';

class Collection {
  final String collectionId;
  final String userId;
  final String ebookId;
  final DateTime addedDate;
  final Ebook? ebook; // To embed the full ebook object

  Collection({
    required this.collectionId,
    required this.userId,
    required this.ebookId,
    required this.addedDate,
    this.ebook,
  });

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      collectionId: json['collection_id'] as String,
      userId: json['user_id'] as String,
      ebookId: json['ebook_id'] as String,
      addedDate: DateTime.parse(json['added_date'] as String),
      ebook: json.containsKey('ebooks') ? Ebook.fromJson(json['ebooks']) : null,
    );
  }
}