import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ebook.dart';
import '../models/collection.dart';
import '../repositories/ebook_repository.dart';
import '../repositories/user_repository.dart';
import 'ebook_details_screen.dart';
// import '/profile_screen.dart';
import '/settings_screen.dart';
import '/providers/user_providers.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // The _widgetOptions list is now defined inside the build method
    // to correctly access the context and providers.
    final _widgetOptions = <Widget>[
      const _NovelListWidgetWithSearch(), // This is the screen we are modifying
      const _FavoriteScreen(),
      // const ProfileScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Book Nest')),
      body: _selectedIndex == 0
          ? _widgetOptions.elementAt(0)
          : _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorite',
          ),
          // Removed Profile BottomNavigationBarItem
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Color.fromARGB(255, 2, 227, 248), // Steel Blue
        unselectedItemColor: Theme.of(context)
            .colorScheme
            .onSurface
            .withOpacity(0.9), // Use a subtle color for unselected items
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class _NovelListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Ebook>>(
      future: EbookRepository().getEbooks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No ebooks found.'));
        }

        final ebooks = snapshot.data!;

        return GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: ebooks.length,
          itemBuilder: (context, index) {
            final ebook = ebooks[index];
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EbookDetailsScreen(ebookId: ebook.ebookId),
                  ),
                );
              },
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        child: const Center(child: Icon(Icons.book, size: 50)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        ebook.title,
                        style: Theme.of(context).textTheme.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      child: Text(
                        'by ${ebook.author}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _NovelListWidgetWithSearch extends StatefulWidget {
  const _NovelListWidgetWithSearch();

  @override
  State<_NovelListWidgetWithSearch> createState() =>
      _NovelListWidgetWithSearchState();
}

class _NovelListWidgetWithSearchState
    extends State<_NovelListWidgetWithSearch> {
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Ebook>> _ebooksFuture;
  List<Ebook> _allEbooks = [];

  @override
  void initState() {
    super.initState();
    _ebooksFuture = _fetchEbooks();
  }

  Future<List<Ebook>> _fetchEbooks() async {
    _allEbooks = await EbookRepository().getEbooks();
    return _allEbooks;
  }

  void _searchEbooks(String query) {
    if (query.isEmpty) {
      setState(() {
        _ebooksFuture = Future.value(_allEbooks);
      });
    } else {
      setState(() {
        _ebooksFuture = Future.value(
          _allEbooks.where((ebook) {
            final titleLower = ebook.title.toLowerCase();
            final authorLower = (ebook.author ?? '').toLowerCase();
            final searchLower = query.toLowerCase();
            return titleLower.contains(searchLower) ||
                authorLower.contains(searchLower);
          }).toList(),
        );
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Added for text alignment
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search books...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).inputDecorationTheme.fillColor,
            ),
            onChanged: _searchEbooks,
          ),
        ),
        // New Section Header for Explore
        Padding(
          padding: const EdgeInsets.fromLTRB(
            16.0,
            0.0,
            16.0,
            8.0,
          ), // Adjust top padding to remove gap with search bar if desired
          child: Text(
            'Explore', // Your desired header text
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(
                context,
              ).colorScheme.primary, // Consistent styling
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Ebook>>(
            future: _ebooksFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No ebooks found.'));
              }

              final ebooks = snapshot.data!;

              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: ebooks.length,
                itemBuilder: (context, index) {
                  final ebook = ebooks[index];
                  final imageUrl =
                      (ebook.imgUrl != null && ebook.imgUrl!.isNotEmpty)
                      ? ebook.imgUrl!
                      : 'https://picsum.photos/seed/${ebook.ebookId}/200/300';
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EbookDetailsScreen(ebookId: ebook.ebookId),
                        ),
                      );
                    },
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                                child: Container(
                                  height: 200,
                                  width: 150,
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.1),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child:
                                        (ebook.imgUrl != null &&
                                            ebook.imgUrl!.isNotEmpty)
                                        ? Image.network(
                                            ebook.imgUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Center(
                                                      child: Icon(
                                                        Icons.book,
                                                        size: 80,
                                                      ),
                                                    ),
                                          )
                                        : Image.network(
                                            'https://picsum.photos/seed/${ebook.ebookId}/150/200',
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Center(
                                                      child: Icon(
                                                        Icons.book,
                                                        size: 80,
                                                      ),
                                                    ),
                                          ),
                                  ),
                                ),
                          ),
                          Container(
                            height: 60, // ✅ Fixed height for title + author
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 6.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  ebook.title,
                                  style: Theme.of(context).textTheme.titleSmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'by ${ebook.author}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// New class for the Favorite Screen (already modified)
class _FavoriteScreen extends StatefulWidget {
  const _FavoriteScreen({super.key});

  @override
  State<_FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<_FavoriteScreen> {
  final UserRepository _userRepository = UserRepository();
  String? _currentUserId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve the current user ID using the UserProvider
    _currentUserId = Provider.of<UserProvider>(
      context,
      listen: false,
    ).currentUserId;
  }

  @override
  Widget build(BuildContext context) {
    // Wrap the content of the FavoriteScreen in a Column to add a header
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Align header to the start
      children: [
        // Section Header for Favorite Ebooks
        Padding(
          padding: const EdgeInsets.fromLTRB(
            16.0,
            16.0,
            16.0,
            8.0,
          ), // Adjust padding as needed
          child: Text(
            'Your Favorite Ebooks', // Your desired header text
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(
                context,
              ).colorScheme.primary, // Or any color you prefer
            ),
          ),
        ),
        Expanded(
          child: Builder(
            // Use Builder to provide a new context for FutureBuilder if needed
            builder: (context) {
              // Check if the user is logged in before proceeding
              if (_currentUserId == null) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Please log in to view your favorite ebooks.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                );
              }

              return FutureBuilder<List<Collection>>(
                future: _userRepository.getFavoriteEbooks(_currentUserId!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('No favorite ebooks found.'),
                    );
                  }

                  final favoriteCollections = snapshot.data!;
                  return GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: favoriteCollections.length,
                    itemBuilder: (context, index) {
                      final ebook = favoriteCollections[index].ebook;
                      if (ebook == null) {
                        return const SizedBox.shrink();
                      }
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EbookDetailsScreen(ebookId: ebook.ebookId),
                            ),
                          );
                        },
                        child: Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: Container(
                                  height: 200,
                                  width: 150,
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.1),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child:
                                        (ebook.imgUrl != null &&
                                            ebook.imgUrl!.isNotEmpty)
                                        ? Image.network(
                                            ebook.imgUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Center(
                                                      child: Icon(
                                                        Icons.book,
                                                        size: 80,
                                                      ),
                                                    ),
                                          )
                                        : Image.network(
                                            'https://picsum.photos/seed/${ebook.ebookId}/150/200',
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Center(
                                                      child: Icon(
                                                        Icons.book,
                                                        size: 80,
                                                      ),
                                                    ),
                                          ),
                                  ),
                                ),
                              ),
                              Container(
                                height: 60, // ✅ Fixed height for title + author
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 6.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      ebook.title,
                                      style: Theme.of(context).textTheme.titleSmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'by ${ebook.author}',
                                      style: Theme.of(context).textTheme.bodySmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            final url = Uri.parse('https://appsamurai.com/blog/mobile-banner-ad-design-tips-for-better-conversion-rate/');
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          },
          child: Container(
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).primaryColor.withOpacity(0.08),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'https://appsamurai.com/wp-content/uploads/2017/07/8-Reasons-for-Why-You-Should-Try-Boost-Campaign-min-1024x427.png', // Example promo image URL
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) =>
                    const Center(child: Icon(Icons.campaign, size: 40)),
              ),
            ),
          ),
          ),  
        )
      ],
    );
  }
}
