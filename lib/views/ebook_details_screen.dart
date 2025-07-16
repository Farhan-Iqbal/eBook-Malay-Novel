import 'package:ebook_malay__novel/providers/user_providers.dart';
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
  String? _currentUserId;
  bool _isFavorite = false;
  bool _hasInitializedFavoriteStatus = false;
  final TextEditingController _reviewController = TextEditingController();
  int _rating = 0;

  @override
  void initState() {
    super.initState();
    _ebookDetailsFuture = EbookRepository().getEbookDetails(widget.ebookId);
    _reviewsFuture = EbookRepository().getEbookReviews(widget.ebookId);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitializedFavoriteStatus) {
      _currentUserId = Provider.of<UserProvider>(
        context,
        listen: false,
      ).currentUserId;
      _checkFavoriteStatus();
      _hasInitializedFavoriteStatus = true;
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _checkFavoriteStatus() async {
    if (_currentUserId == null) {
      setState(() {
        _isFavorite = false;
      });
      return;
    }

    try {
      final isFavorite = await UserRepository().isEbookInFavorites(
        _currentUserId!,
        widget.ebookId,
      );
      setState(() {
        _isFavorite = isFavorite;
      });
    } catch (e) {
      print('Error checking favorite status: $e');
    }
  }

  Future<void> _toggleFavoriteStatus() async {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to add to favorites.')),
      );
      return;
    }

    try {
      if (_isFavorite) {
        await UserRepository().removeFromFavorites(
          _currentUserId!,
          widget.ebookId,
        );
      } else {
        await UserRepository().addToFavorites(_currentUserId!, widget.ebookId);
      }
      setState(() {
        _isFavorite = !_isFavorite;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update favorites: $e')));
    }
  }

  void _showReviewDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              title: const Text('Add Review'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < _rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                          ),
                          onPressed: () {
                            setState(() {
                              _rating = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                    TextField(
                      controller: _reviewController,
                      decoration: const InputDecoration(
                        labelText: 'Write your review...',
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: kSubtleTextColor),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_currentUserId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please log in to submit a review.'),
                        ),
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
                        _reviewsFuture = EbookRepository().getEbookReviews(
                          widget.ebookId,
                        );
                      });
                    } catch (e) {
                      print('Error submitting review: $e');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to submit review: $e'),
                          ),
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ebook Details'),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : null,
            ),
            onPressed: _toggleFavoriteStatus,
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
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Ebook not found.'));
          }

          final ebook = snapshot.data!;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      height: 200,
                      width: 150,
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      child: const Center(child: Icon(Icons.book, size: 80)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    ebook.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'by ${ebook.author ?? 'N/A'}',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Synopsis:',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ebook.synopsis ?? 'No synopsis available.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDetailRow(
                        context,
                        'Genre',
                        ebook.genreName ?? 'N/A',
                      ),
                      _buildDetailRow(
                        context,
                        'Pages',
                        ebook.pageNumber?.toString() ?? 'N/A',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDetailRow(
                        context,
                        'Publisher',
                        ebook.publisher ?? 'N/A',
                      ),
                      _buildDetailRow(
                        context,
                        'Published',
                        '${ebook.monthPublished ?? 'N/A'} ${ebook.yearPublished ?? 'N/A'}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Reviews',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      TextButton(
                        onPressed: _showReviewDialog,
                        child: const Text('Add a Review'),
                      ),
                    ],
                  ),
                  FutureBuilder<List<Review>>(
                    future: _reviewsFuture,
                    builder: (context, reviewSnapshot) {
                      if (reviewSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (reviewSnapshot.hasError) {
                        return Center(
                          child: Text('Error: ${reviewSnapshot.error}'),
                        );
                      } else if (!reviewSnapshot.hasData ||
                          reviewSnapshot.data!.isEmpty) {
                        return const Center(child: Text('No reviews yet.'));
                      }

                      final reviews = reviewSnapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          final review = reviews[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        review.userName ?? 'Anonymous',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleSmall,
                                      ),
                                      const Spacer(),
                                      buildStaticStarRating(review.rating),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(review.reviewText),
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }

  Widget buildInteractiveStarRating({
    required int rating,
    required ValueChanged<int> onRatingSelected,
    double size = 24,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        return InkWell(
          onTap: () => onRatingSelected(starIndex),
          child: Icon(
            rating >= starIndex ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: size,
          ),
        );
      }),
    );
  }

  Widget buildStaticStarRating(int rating, {double size = 16}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: size,
        );
      }),
    );
  }
}
