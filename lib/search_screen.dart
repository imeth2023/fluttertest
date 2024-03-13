import 'package:flutter/material.dart';
import 'api_service.dart'; // Adjust with your actual import path
import 'media_item.dart'; // Adjust with your actual import path
import 'details.dart'; // Adjust with your actual import path

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApiService _apiService = ApiService();
  List<MediaItem> _searchResults = [];
  bool _isLoading = false;
  String _searchType = "movie"; // Default to 'movie'
  final List<String> _searchTypes = ['actor', 'movie', 'tv']; // Options for dropdown

  void _performSearch(String query) async {
    if (query.isEmpty) return;
    setState(() {
      _isLoading = true;
      _searchResults = []; // Clear previous results
    });

    try {
      if (_searchType == 'actor') {
        // For actor searches, including the possibility of searching for common films among multiple actors
        await _handleActorSearch(query);
      } else {
        // For movie and TV show searches
        List<MediaItem> mediaItems = await _apiService.searchMedia(query, _searchType);
        setState(() {
          _searchResults = mediaItems;
        });
      }
    } catch (e) {
      print("Error performing search: $e"); // Consider showing an error message to the user
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleActorSearch(String query) async {
    List<String> actorNames = query.split(',').map((name) => name.trim()).toList();
    if (actorNames.length > 1) {
      // Handle multi-actor search
      List<Set<String>> filmographiesIds = [];
      for (String name in actorNames) {
        List<Actor> actors = await _apiService.searchActors(name);
        if (actors.isNotEmpty) {
          List<MediaItem> filmography = await _apiService.fetchActorFilmography(actors.first.id);
          Set<String> filmIds = filmography.map((item) => item.id).toSet();
          filmographiesIds.add(filmIds);
        }
      }
      Set<String> commonFilmIds = filmographiesIds.reduce((a, b) => a.intersection(b));
      List<MediaItem> commonFilms = [];
      for (String id in commonFilmIds) {
        MediaItem? film = await _apiService.fetchMediaDetailsById(id); // Ensure this method is implemented in ApiService
        if (film != null) {
          commonFilms.add(film);
        }
      }
      setState(() {
        _searchResults = commonFilms;
      });
    } else if (actorNames.isNotEmpty) {
      // Single actor search
      List<Actor> actors = await _apiService.searchActors(actorNames.first);
      if (actors.isNotEmpty) {
        List<MediaItem> filmography = await _apiService.fetchActorFilmography(actors.first.id);
        setState(() {
          _searchResults = filmography;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
        actions: <Widget>[
          DropdownButton<String>(
            underline: Container(), // Removes the underline
            value: _searchType,
            onChanged: (String? newValue) {
              setState(() {
                _searchType = newValue!;
                _searchResults = []; // Optionally clear results on search type change
              });
            },
            items: _searchTypes.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value.toUpperCase()),
              );
            }).toList(),
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
                suffixIcon: _isLoading ? CircularProgressIndicator() : Icon(Icons.search),
              ),
              onSubmitted: _performSearch,
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final item = _searchResults[index];
                      return ListTile(
                        leading: item.posterPath.isNotEmpty
                            ? Image.network(item.posterPath, width: 50, fit: BoxFit.cover)
                            : Icon(Icons.movie),
                        title: Text(item.title),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => DetailsPage(mediaItem: item)),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
