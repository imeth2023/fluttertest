import 'package:flutter/material.dart';
import 'api_service.dart'; // Make sure this import points to your ApiService
import 'media_item.dart'; // Ensure this points to your MediaItem model
import 'details.dart'; // Ensure this points to your DetailsPage

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
  String _mediaType = 'movie'; // Start with 'movie' as the default media type
  String _sortBy = 'popularity.desc'; // Default sort parameter

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 2, vsync: this); // Movies and TV Shows
    _contentTabController = TabController(length: 3, vsync: this); // Trending, Top Rated, and Top Grossing
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
            _sortBy = 'revenue.desc'; // For top-grossing, applicable to movies
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
              children: genres!.entries.map((entry) {
                return ListTile(
                  title: Text(entry.key),
                  onTap: () {
                    setState(() {
                      _selectedGenreId = entry.value;
                      Navigator.of(context).pop();
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Reset'),
              onPressed: () {
                setState(() {
                  _selectedGenreId = null;
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
    Future<List<MediaItem>> futureMediaItems;
    if (_selectedGenreId != null) {
      futureMediaItems = _apiService.fetchMediaByGenreAndSort(_mediaType, _selectedGenreId!, sortBy: _sortBy);
    } else {
      // Return an empty list if no genre is selected
      futureMediaItems = Future.value([]);
    }

    return FutureBuilder<List<MediaItem>>(
      future: futureMediaItems,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final item = snapshot.data![index];
              return ListTile(
                leading: Image.network(item.posterPath ?? '', width: 100, fit: BoxFit.cover),
                title: Text(item.title ?? 'No Title'),
                subtitle: Text(item.overview ?? "No description"),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => DetailsPage(mediaItem: item),
                  ));
                },
              );
            },
          );
        } else {
          return Center(child: Text("No data available"));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movies & TV Shows'),
        bottom: TabBar(
          controller: _mainTabController,
          tabs: [
            Tab(text: 'Movies'),
            Tab(text: 'TV Shows'),
          ],
        ),
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
                Tab(text: 'Top Grossing'), // Added "Top Grossing" tab
              ],
            ),
          ),
          Expanded(
            child: _buildMediaList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showGenreSelector,
        tooltip: 'Select Genre',
        child: Icon(Icons.filter_list),
      ),
    );
  }
}
