import 'package:flutter/material.dart';
import 'api_service.dart'; // Adjust the import path as necessary
import 'media_item.dart'; // Adjust the import path as necessary
import 'details.dart'; // Adjust the import path as necessary
import 'watchlist_page.dart'; // Adjust the import path as necessary
import 'user_page.dart'; // Adjust the import path as necessary
import 'search_screen.dart'; // Adjust the import path as necessary

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late TabController _mainTabController;
  late TabController _contentTabController;
  Future<Map<String, int>>? _genresFuture;
  int? _selectedGenreId;
  String _selectedGenre = ''; // Variable to hold the selected genre name
  String _mediaType = 'movie'; // Start with 'movie' as the default media type
  String _sortBy = 'popularity.desc'; // Default sort by
  bool _kidsMode = false; // Indicates whether the app is in kids mode

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 2, vsync: this); // Movies and TV Shows
    _contentTabController = TabController(length: 3, vsync: this); // Trending, Top Rated, Top Grossing
    _genresFuture = _apiService.fetchGenres(_mediaType);
    _mainTabController.addListener(_handleMainTabChange);
    _contentTabController.addListener(_handleContentTabChange);
  }

  void _handleMainTabChange() {
    if (!_mainTabController.indexIsChanging) {
      setState(() {
        _mediaType = _mainTabController.index == 0 ? 'movie' : 'tv';
        _genresFuture = _apiService.fetchGenres(_mediaType);
        _selectedGenreId = null; // Reset genre when switching
        _selectedGenre = ''; // Reset selected genre name
        _sortBy = 'popularity.desc'; // Reset sort by to default when switching between tabs
      });
    }
  }

  void _handleContentTabChange() {
    if (!_contentTabController.indexIsChanging) {
      setState(() {
        switch (_contentTabController.index) {
          case 0:
            _sortBy = 'popularity.desc';
            break;
          case 1:
            _sortBy = 'vote_average.desc';
            break;
          case 2:
            _sortBy = (_mediaType == 'movie') ? 'revenue.desc' : 'popularity.desc';
            break;
          default:
            _sortBy = 'popularity.desc';
            break;
        }
      });
    }
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    _contentTabController.dispose();
    super.dispose();
  }

  void _showGenreSelector() async {
    final genres = await _genresFuture;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select a Genre"),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                // Add a toggle button for Kids mode
                ListTile(
                  title: Text(_kidsMode ? 'Turn Off Kids' : 'Turn On Kids'),
                  onTap: () {
                    setState(() {
                      // Toggle kids mode
                      _kidsMode = !_kidsMode;
                      // Get the genre ID for Family when turning on kids mode
                      if (_kidsMode) {
                        _selectedGenreId = genres!['Family'];
                      } else {
                        _selectedGenreId = null;
                      }
                      Navigator.of(context).pop();
                    });
                  },
                ),
                // List of genres including Family if not in kids mode
                ...genres!.entries.map((entry) {
                  return ListTile(
                    title: Text(entry.key),
                    onTap: () {
                      setState(() {
                        _selectedGenreId = entry.value;
                        _selectedGenre = entry.key; // Update the selected genre name
                        Navigator.of(context).pop();
                      });
                    },
                  );
                }).toList(),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Reset'),
              onPressed: () {
                setState(() {
                  _selectedGenreId = null;
                  _selectedGenre = ''; // Reset selected genre name
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildMediaList() {
    Future<List<MediaItem>> fetchFuture;

    if (_selectedGenreId != null) {
      fetchFuture = _apiService.fetchMediaByGenreAndSort(_mediaType, _selectedGenreId!, sortBy: _sortBy);
    } else {
      // Adjust here to fetch default screens for Top Rated and Top Grossing for TV shows
      fetchFuture = _fetchDefaultScreen();
    }

    return FutureBuilder<List<MediaItem>>(
      future: fetchFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16, // Added spacing between each poster
              mainAxisSpacing: 16, // Added spacing between each poster
            ),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final item = snapshot.data![index];
              return _buildMediaItem(item);
            },
          );
        } else {
          return Center(child: Text("No data available"));
        }
      },
    );
  }

  Widget _buildMediaItem(MediaItem item) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => DetailsPage(mediaItem: item),
        ));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          item.posterPath ?? '',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Future<List<MediaItem>> _fetchDefaultScreen() {
    switch (_contentTabController.index) {
      case 0: // Trending
        return _apiService.fetchTrending(_mediaType);
      case 1: // Top Rated
        return _apiService.fetchTopRated(_mediaType);
      case 2: // Top Grossing for movies, or a chosen metric for TV shows
        return (_mediaType == 'movie') ? _apiService.fetchTopGrossingMoviesByGenre(0) : _apiService.fetchTopRated(_mediaType);
      default:
        return _apiService.fetchTrending(_mediaType);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedGenre.isNotEmpty ? '$_mediaType - $_selectedGenre' : 'Movies & TV Shows'), // Display selected genre in the app bar title
        bottom: TabBar(
          controller: _mainTabController,
          tabs: [
            Tab(text: 'Movies'),
            Tab(text: 'TV Shows'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => SearchScreen())),
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showGenreSelector,
          ),
          IconButton(
            icon: Icon(Icons.view_list),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => WatchlistPage())),
          ),
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => UserPage())),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            child: TabBar(
              controller: _contentTabController,
              tabs: [
                Tab(text: 'Trending'),
                Tab(text: 'Top Rated'),
                Tab(text: 'Top Grossing'), // Kept as "Top Grossing" for simplicity, but it fetches top rated for TV
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _contentTabController,
              children: [
                _buildMediaList(), // For Trending
                _buildMediaList(), // For Top Rated
                _buildMediaList(), // For Top Grossing (or alternative metric for TV shows)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
