import 'package:flutter/material.dart';
import 'api_service.dart'; // Adjust the import path as necessary
import 'media_item.dart'; // Adjust the import path as necessary
import 'details.dart'; // Make sure this import points to your DetailsPage file

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApiService _apiService = ApiService();
  List<MediaItem> _searchResults = [];
  String _searchQuery = "";
  String _mediaType = "movie"; // Default search for movies

  void _performSearch(String query) async {
    if (query.isNotEmpty) {
      List<MediaItem> results = await _apiService.searchMedia(query, _mediaType);
      setState(() {
        _searchQuery = query;
        _searchResults = results;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
        actions: [
          IconButton(
            icon: Icon(_mediaType == "movie" ? Icons.movie : Icons.tv),
            onPressed: () => setState(() {
              _mediaType = _mediaType == "movie" ? "tv" : "movie";
              if (_searchQuery.isNotEmpty) {
                _performSearch(_searchQuery);
              }
            }),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search...',
                suffixIcon: Icon(Icons.search),
              ),
              onSubmitted: _performSearch,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final item = _searchResults[index];
                return ListTile(
                  leading: item.posterPath.isNotEmpty ? Image.network(item.posterPath) : null,
                  title: Text(item.title),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DetailsPage(mediaItem: item),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
