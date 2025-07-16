import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ebook.dart';
import '../models/collection.dart';
import '../repositories/ebook_repository.dart';
import '../repositories/user_repository.dart';
import 'ebook_details_screen.dart';
import '/profile_screen.dart';
import '/settings_screen.dart';
import '/providers/user_providers.dart';

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
      const _NovelListWidgetWithSearch(),
      const _FavoriteScreen(),
      const ProfileScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Nest'),
      ),
      body: _selectedIndex == 0
          ? _widgetOptions.elementAt(0)
          : _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorite',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
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
                    builder: (context) => EbookDetailsScreen(ebookId: ebook.ebookId),
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
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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
  State<_NovelListWidgetWithSearch> createState() => _NovelListWidgetWithSearchState();
}

class _NovelListWidgetWithSearchState extends State<_NovelListWidgetWithSearch> {
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
        _ebooksFuture = Future.value(_allEbooks.where((ebook) {
          final titleLower = ebook.title.toLowerCase();
          final authorLower = (ebook.author ?? '').toLowerCase();
          final searchLower = query.toLowerCase();
          return titleLower.contains(searchLower) || authorLower.contains(searchLower);
        }).toList());
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
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EbookDetailsScreen(ebookId: ebook.ebookId),
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
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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
          ),
        ),
      ],
    );
  }
}

// New class for the Favorite Screen
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
    _currentUserId = Provider.of<UserProvider>(context, listen: false).currentUserId;
  }

  @override
  Widget build(BuildContext context) {
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
          return const Center(child: Text('No favorite ebooks found.'));
        }

        final favoriteCollections = snapshot.data!;
        return GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                    builder: (context) => EbookDetailsScreen(ebookId: ebook.ebookId),
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
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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