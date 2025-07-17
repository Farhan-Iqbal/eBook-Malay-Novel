import 'package:ebook_malay__novel/providers/user_providers.dart';
import 'package:ebook_malay__novel/views/read_ebook.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/models/ebook.dart';
import '/models/review.dart';
import '/repositories/ebook_repository.dart';
import '/repositories/review_repository.dart';
import '/repositories/user_repository.dart';
import '/theme.dart';
// adjust path if needed

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
  bool _hasInitialized = false;
  String? _readingStatus;
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
    if (!_hasInitialized) {
      _currentUserId = Provider.of<UserProvider>(
        context,
        listen: false,
      ).currentUserId;

      if (_currentUserId != null) {
        _checkFavoriteStatus();
        _loadReadingStatus();
      }
      _hasInitialized = true;
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _checkFavoriteStatus() async {
    if (_currentUserId == null) return;

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
        await UserRepository().addToFavorites(
          _currentUserId!,
          widget.ebookId,
        );
      }
      setState(() {
        _isFavorite = !_isFavorite;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update favorites: $e')),
      );
    }
  }

  Future<void> _loadReadingStatus() async {
    if (_currentUserId == null) return;

    final status = await UserRepository()
        .getReadingStatus(_currentUserId!, widget.ebookId);

    setState(() {
      _readingStatus = status ?? 'not_started';
    });
  }

  Future<void> _updateReadingStatus(String newStatus) async {
    if (_currentUserId == null) return;

    await UserRepository().updateReadingStatus(
      _currentUserId!,
      widget.ebookId,
      newStatus,
    );

    setState(() {
      _readingStatus = newStatus;
    });
  }

  void _handleReadPressed() async {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to read this ebook.')),
      );
      return;
    }

    // update status to currently_reading
    await _updateReadingStatus('currently_reading');

    // navigate to ReadEbookScreen (adjust the path if necessary)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReadEbookScreen(
          ebookId: widget.ebookId,
          onFinish: () {
            // Optionally update reading status to 'finished' or perform other actions
            _updateReadingStatus('finished');
          },
        ),
      ),
    ).then((_) {
      // after returning from reading page, optionally mark as finished
      // comment this out if you want manual control
      //_updateReadingStatus('finished');
    });
  }

  void _showChangeStatusDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Not Started'),
                onTap: () {
                  Navigator.pop(context);
                  _updateReadingStatus('not_started');
                },
              ),
              ListTile(
                title: const Text('Currently Reading'),
                onTap: () {
                  Navigator.pop(context);
                  _updateReadingStatus('currently_reading');
                },
              ),
              ListTile(
                title: const Text('Finished'),
                onTap: () {
                  Navigator.pop(context);
                  _updateReadingStatus('finished');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showReviewDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        int dialogRating = _rating;
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
                            index < dialogRating
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                          ),
                          onPressed: () {
                            setState(() {
                              dialogRating = index + 1;
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
                  onPressed: () => Navigator.of(context).pop(false),
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
                            content:
                                Text('Please log in to submit a review.')),
                      );
                      Navigator.of(context).pop(false);
                      return;
                    }

                    try {
                      await ReviewRepository().submitReview(
                        ebookId: widget.ebookId,
                        userId: _currentUserId!,
                        rating: dialogRating,
                        reviewText: _reviewController.text,
                      );
                      Navigator.of(context).pop(true);
                    } catch (e) {
                      print('Error submitting review: $e');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Failed to submit review: $e')),
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

    if (result == true) {
      setState(() {
        _reviewsFuture =
            EbookRepository().getEbookReviews(widget.ebookId);
        _reviewController.clear();
        _rating = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ebook Details'),
        actions: [
          if (_readingStatus != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _showChangeStatusDialog,
              tooltip: 'Change Reading Status',
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: (ebook.imgUrl != null &&
                                ebook.imgUrl!.isNotEmpty)
                            ? Image.network(
                                ebook.imgUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(
                                  child: Icon(Icons.book, size: 80),
                                ),
                              )
                            : Image.network(
                                'https://picsum.photos/seed/${ebook.ebookId}/150/200',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(
                                  child: Icon(Icons.book, size: 80),
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          ebook.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: _isFavorite ? Colors.red : null,
                        ),
                        onPressed: _toggleFavoriteStatus,
                        tooltip: _isFavorite
                            ? 'Remove from Favorites'
                            : 'Add to Favorites',
                      ),
                    ],
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
                  const SizedBox(height: 16),
                  if (_currentUserId != null)
                    Row(
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.menu_book),
                          label: const Text('Read'),
                          onPressed: _handleReadPressed,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Status: ${_readingStatus ?? 'N/A'}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Reviews',
                        style:
                            Theme.of(context).textTheme.headlineSmall,
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
                        return const Center(
                            child: CircularProgressIndicator());
                      } else if (reviewSnapshot.hasError) {
                        return Center(
                          child: Text('Error: ${reviewSnapshot.error}'),
                        );
                      } else if (!reviewSnapshot.hasData ||
                          reviewSnapshot.data!.isEmpty) {
                        return const Center(
                            child: Text('No reviews yet.'));
                      }

                      final reviews = reviewSnapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(),
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          final review = reviews[index];
                          return Card(
                            margin:
                                const EdgeInsets.symmetric(vertical: 8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        review.userName ??
                                            'Anonymous',
                                        style:
                                            Theme.of(context)
                                                .textTheme
                                                .titleSmall,
                                      ),
                                      const Spacer(),
                                      buildStaticStarRating(
                                          review.rating),
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

  Widget _buildDetailRow(
      BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(value,
            style: Theme.of(context).textTheme.titleSmall),
      ],
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
