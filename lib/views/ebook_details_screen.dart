import 'package:flutter/material.dart';
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
  final String _currentUserId = 'YOUR_CURRENT_USER_ID'; // Replace with a real user ID
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
    _checkFavoriteStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novel Details'),
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
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Novel not found.'));
          }

          final ebook = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ... Ebook details UI ...
                Text(ebook.title, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text('by ${ebook.author}', style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 16),
                Text(
                  ebook.synopsis ?? 'No synopsis available.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Implement review submission
                    _showReviewDialog(context);
                  },
                  child: const Text('Write a Review'),
                ),
                const SizedBox(height: 24),
                Text('Reviews', style: Theme.of(context).textTheme.headlineSmall),
                FutureBuilder<List<Review>>(
                  future: _reviewsFuture,
                  builder: (context, reviewsSnapshot) {
                    if (reviewsSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (reviewsSnapshot.hasError) {
                      return Center(child: Text('Error loading reviews: ${reviewsSnapshot.error}'));
                    }
                    if (!reviewsSnapshot.hasData || reviewsSnapshot.data!.isEmpty) {
                      return const Center(child: Text('No reviews yet.'));
                    }

                    final reviews = reviewsSnapshot.data!;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        final review = reviews[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text('Rating: ${review.rating} / 5', style: const TextStyle(color: kAccentColor)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(review.reviewText, style: Theme.of(context).textTheme.bodySmall),
                                Text('by ${review.userName ?? 'Anonymous'}', style: Theme.of(context).textTheme.bodyMedium),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  void _showReviewDialog(BuildContext context) {
    int _rating = 1;
    final TextEditingController _reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: kSurfaceColor,
          title: const Text('Write a Review'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: _rating,
                  decoration: const InputDecoration(labelText: 'Rating'),
                  items: List.generate(5, (index) => index + 1)
                      .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                      .toList(),
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
                // Refresh reviews
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