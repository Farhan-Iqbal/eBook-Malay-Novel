import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/models/ebook.dart';
import '/models/review.dart';
import '/repositories/ebook_repository.dart';
import '/repositories/review_repository.dart';
import '/repositories/user_repository.dart';
import '/theme.dart';

class EbookDetailsScreen extends StatefulWidget {
  final String ebookId;

  const EbookDetailsScreen({super.key, required this.ebookId});

  @override
  State<EbookDetailsScreen> createState() => _EbookDetailsScreenState();
}

class _EbookDetailsScreenState extends State<EbookDetailsScreen> {
  late Future<Ebook?> _ebookDetailsFuture;
  late Future<List<Review>> _reviewsFuture;
  final String _currentUserId = 'YOUR_CURRENT_USER_ID';
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _ebookDetailsFuture = EbookRepository().getEbookDetails(widget.ebookId);
    _reviewsFuture = EbookRepository().getEbookReviews(widget.ebookId);
    _checkFavoriteStatus();
  }

  void _checkFavoriteStatus() async {
    final status = await UserRepository().isEbookInFavorites(_currentUserId, widget.ebookId);
    setState(() {
      _isFavorite = status;
    });
  }

  void _toggleFavorite() async {
    if (_isFavorite) {
      await UserRepository().removeFromFavorites(_currentUserId, widget.ebookId);
    } else {
      await UserRepository().addToFavorites(_currentUserId, widget.ebookId);
    }
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  final TextEditingController _reviewController = TextEditingController();
  int _rating = 5;

  @override
  Widget build(BuildContext context) {
    // Get the current theme from the provider
    final appTheme = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ebook Details'),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : null,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: FutureBuilder<Ebook?>(
        future: _ebookDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Ebook not found.'));
          }

          final ebook = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 200,
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: const Center(child: Icon(Icons.book, size: 100)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  ebook.title,
                  style: TextStyle(
                    fontSize: appTheme.fontSize + 8, // Use dynamic font size
                    fontWeight: appTheme.isBold ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'by ${ebook.author}',
                  style: TextStyle(
                    fontSize: appTheme.fontSize, // Use dynamic font size
                    fontWeight: appTheme.isBold ? FontWeight.bold : FontWeight.normal,
                    color: kSubtleTextColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  ebook.synopsis ?? 'No synopsis available.',
                  style: TextStyle(
                    fontSize: appTheme.fontSize, // Use dynamic font size
                    fontWeight: appTheme.isBold ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Reviews',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () => _showReviewDialog(context),
                  child: const Text('Add Review'),
                ),
                const SizedBox(height: 16),
                _buildReviewsList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildReviewsList() {
    return FutureBuilder<List<Review>>(
      future: _reviewsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No reviews yet. Be the first to review!'));
        }

        final reviews = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(
                  '${review.userName ?? 'Anonymous'} - Rating: ${review.rating}/5',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                subtitle: Text(
                  review.reviewText,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showReviewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add a Review'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: _rating,
                  decoration: const InputDecoration(labelText: 'Rating'),
                  items: List.generate(5, (index) => index + 1)
                      .map((e) => DropdownMenuItem(value: e, child: Text('$e'))).toList(),
                  onChanged: (value) {
                    setState(() {
                      _rating = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _reviewController,
                  decoration: const InputDecoration(labelText: 'Your Review'),
                  maxLines: 4,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: kSubtleTextColor)),
            ),
            ElevatedButton(
              onPressed: () async {
                await ReviewRepository().submitReview(
                  ebookId: widget.ebookId,
                  userId: _currentUserId,
                  rating: _rating,
                  reviewText: _reviewController.text,
                );
                Navigator.of(context).pop();
                setState(() {
                  _reviewsFuture = EbookRepository().getEbookReviews(widget.ebookId);
                });
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}