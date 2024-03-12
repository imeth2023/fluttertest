import 'package:flutter/material.dart';
import 'api_service.dart'; // Adjust the import path as necessary
import 'media_item.dart'; // Adjust the import path as necessary
import 'details.dart'; // Adjust the import path as necessary
import 'actor_details_page.dart'; // Adjust the import path as necessary
// Removed redundant import of 'media_item.dart'

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _searchResults = []; // Dynamic to accommodate MediaItem or Actor
  String _searchQuery = "";
  String _searchType = "movie"; // Can be 'movie', 'tv', or 'actor'

  void _performSearch(String query) async {
    if (query.isNotEmpty) {
      var results;
      if (_searchType == 'actor') {
        results = await _apiService.searchActors(query); // Use your ApiService to search actors
      } else {
        results = await _apiService.searchMedia(query, _searchType);
      }

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
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.swap_vert),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return SafeArea(
                    child: Wrap(
                      children: <Widget>[
                        ListTile(
                          leading: Icon(Icons.movie),
                          title: Text('Movies'),
                          onTap: () {
                            setState(() {
                              _searchType = 'movie';
                              if (_searchQuery.isNotEmpty) _performSearch(_searchQuery);
                            });
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.tv),
                          title: Text('TV Shows'),
                          onTap: () {
                            setState(() {
                              _searchType = 'tv';
                              if (_searchQuery.isNotEmpty) _performSearch(_searchQuery);
                            });
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.person),
                          title: Text('Actors'),
                          onTap: () {
                            setState(() {
                              _searchType = 'actor';
                              if (_searchQuery.isNotEmpty) _performSearch(_searchQuery);
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
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
                // Use isInstanceOf<T>() checks for proper type checking
                if (item is MediaItem) {
                  return ListTile(
                    leading: item.posterPath.isNotEmpty
                        ? Image.network(item.posterPath, width: 50, fit: BoxFit.cover)
                        : null,
                    title: Text(item.title),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => DetailsPage(mediaItem: item))),
                  );
                } else if (item is Actor) {
                  return ListTile(
                    leading: item.imageUrl != null
                        ? Image.network(item.imageUrl!, width: 50, fit: BoxFit.cover)
                        : null,
                    title: Text(item.name),
                    subtitle: Text("Tap to view details"),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => ActorDetailsPage(actor: item))),
                  );
                }
                return Container(); // Fallback in case item doesn't match expected types
              },
            ),
          ),
        ],
      ),
    );
  }
}
