import 'package:ebook_malay__novel/providers/user_providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/models/ebook.dart';
import '/models/review.dart';
import '/repositories/ebook_repository.dart';
import '/repositories/review_repository.dart';
import '/repositories/user_repository.dart';
import '/services/supabase_service.dart';
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
  String? _currentUserId; // This will be updated via didChangeDependencies
  bool _isFavorite = false;
  bool _hasInitializedFavoriteStatus = false; // New flag to track initial favorite status check

  @override
  void initState() {
    super.initState();
    _ebookDetailsFuture = EbookRepository().getEbookDetails(widget.ebookId);
    _reviewsFuture = EbookRepository().getEbookReviews(widget.ebookId);
    // Initial favorite status check will now be handled more robustly in didChangeDependencies.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get the current user ID from the UserProvider.
    final newUserid = Provider.of<UserProvider>(context).currentUserId;

    // Only update and trigger favorite status check if the user ID has changed
    // OR if it's the first time we're getting a non-null user ID.
    if (newUserid != _currentUserId || (newUserid != null && !_hasInitializedFavoriteStatus)) {
      _currentUserId = newUserid;
      if (_currentUserId != null) {
        _checkFavoriteStatus();
        _hasInitializedFavoriteStatus = true; // Mark as initialized
      } else {
        // If the user logs out or there's no user, reset favorite status and flag.
        setState(() {
          _isFavorite = false;
        });
        _hasInitializedFavoriteStatus = false;
      }
    }
  }

  void _checkFavoriteStatus() async {
    // Ensure _currentUserId is not null before proceeding
    if (_currentUserId == null) return;

    try {
      final status = await UserRepository().isEbookInFavorites(_currentUserId!, widget.ebookId);
      setState(() {
        _isFavorite = status;
      });
    } catch (e) {
      // Log error if checking favorite status fails
      print('Error checking favorite status: $e');
      // Optionally, show a snackbar to the user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to check favorite status: $e')),
        );
      }
    }
  }

  void _toggleFavorite() async {
    // Ensure _currentUserId is not null before proceeding
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to add to favorites.')),
      );
      return;
    }

    try {
      if (_isFavorite) {
        await UserRepository().removeFromFavorites(_currentUserId!, widget.ebookId);
      } else {
        await UserRepository().addToFavorites(_currentUserId!, widget.ebookId);
      }
      // After the operation, explicitly re-check the favorite status from the database
      _checkFavoriteStatus();
      // No need to manually toggle _isFavorite here, as _checkFavoriteStatus will update it.
    } catch (e) {
      // Log error if toggling favorite status fails
      print('Error toggling favorite status: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update favorite status: $e')),
        );
      }
    }
  }

  final TextEditingController _reviewController = TextEditingController();
  int _rating = 5;

  @override
  Widget build(BuildContext context) {
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
                    fontSize: appTheme.fontSize + 8,
                    fontWeight: appTheme.isBold ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'by ${ebook.author}',
                  style: TextStyle(
                    fontSize: appTheme.fontSize,
                    fontWeight: appTheme.isBold ? FontWeight.bold : FontWeight.normal,
                    color: kSubtleTextColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  ebook.synopsis ?? 'No synopsis available.',
                  style: TextStyle(
                    fontSize: appTheme.fontSize,
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
                if (_currentUserId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please log in to submit a review.')),
                  );
                  Navigator.of(context).pop();
                  return;
                }

                try {
                  await ReviewRepository().submitReview(
                    ebookId: widget.ebookId,
                    userId: _currentUserId!,
                    rating: _rating,
                    reviewText: _reviewController.text,
                  );
                  Navigator.of(context).pop();
                  setState(() {
                    _reviewsFuture = EbookRepository().getEbookReviews(widget.ebookId);
                  });
                } catch (e) {
                  print('Error submitting review: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to submit review: $e')),
                    );
                  }
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}
