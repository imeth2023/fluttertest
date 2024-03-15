import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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
  String _selectedGenre = '';
  String _mediaType = 'movie';
  String _sortBy = 'popularity.desc';
  String _sortOrder = 'desc'; // Added sort order state
  bool _kidsMode = false;

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 2, vsync: this);
    _contentTabController = TabController(length: 3, vsync: this);
    _checkConnectivityAndFetchGenres();
    _mainTabController.addListener(_handleMainTabChange);
    _contentTabController.addListener(_handleContentTabChange);
  }

  Future<void> _checkConnectivityAndFetchGenres() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      _showNoInternetSnackbar();
    } else {
      _genresFuture = _apiService.fetchGenres(_mediaType);
    }
  }

  void _showNoInternetSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('No Internet Connection Available'),
    ));
  }

  void _handleMainTabChange() {
    if (!_mainTabController.indexIsChanging) {
      setState(() {
        _mediaType = _mainTabController.index == 0 ? 'movie' : 'tv';
        _checkConnectivityAndFetchGenres();
        _selectedGenreId = null;
        _selectedGenre = '';
        _sortBy = 'popularity.desc';
        _sortOrder = 'desc'; // Reset sort order on main tab change
      });
    }
  }

  void _handleContentTabChange() {
    if (!_contentTabController.indexIsChanging) {
      setState(() {
        switch (_contentTabController.index) {
          case 0:
            _sortBy = 'popularity';
            break;
          case 1:
            _sortBy = 'vote_average';
            break;
          case 2:
            _sortBy = (_mediaType == 'movie') ? 'revenue' : 'popularity';
            break;
          default:
            _sortBy = 'popularity';
            break;
        }
        // Append sort order to sortBy
        _sortBy += '.$_sortOrder';
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
    if (genres == null) {
      _showNoInternetSnackbar();
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select a Genre"),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                ListTile(
                  title: Text(_kidsMode ? 'Turn Off Kids Mode' : 'Turn On Kids Mode'),
                  onTap: () {
                    setState(() {
                      _kidsMode = !_kidsMode;
                      if (_kidsMode) {
                        _selectedGenreId = genres['Family'];
                      } else {
                        _selectedGenreId = null;
                      }
                      Navigator.of(context).pop();
                    });
                  },
                ),
                ...genres.entries.map((entry) {
                  return ListTile(
                    title: Text(entry.key),
                    onTap: () {
                      setState(() {
                        _selectedGenreId = entry.value;
                        _selectedGenre = entry.key;
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
                  _selectedGenre = '';
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
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
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
        title: Text(_selectedGenre.isNotEmpty ? '$_mediaType - $_selectedGenre' : 'Movies & TV Shows'),
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
          DropdownButton<String>(
            value: _sortOrder,
            icon: Icon(Icons.sort),
            underline: Container(height: 0),
            onChanged: (String? newValue) {
              setState(() {
                _sortOrder = newValue!;
                _handleContentTabChange(); // Update sort order in UI
              });
            },
            items: <String>['desc', 'asc']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value.toUpperCase()),
              );
            }).toList(),
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
                Tab(text: 'Top Grossing'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _contentTabController,
              children: [
                _buildMediaList(),
                _buildMediaList(),
                _buildMediaList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
