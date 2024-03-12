import 'package:flutter/material.dart';
import 'api_service.dart'; // Adjust the import path as necessary
import 'media_item.dart'; // Adjust the import path as necessary
import 'actor_details_page.dart'; // Make sure to create and import ActorDetailsPage
import 'details.dart'; // Make sure this import points to your DetailsPage file
import 'actor_details_page.dart'; // Ensure you have an Actor model

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
                            setState(() => _searchType = 'movie');
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.tv),
                          title: Text('TV Shows'),
                          onTap: () {
                            setState(() => _searchType = 'tv');
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.person),
                          title: Text('Actors'),
                          onTap: () {
                            setState(() => _searchType = 'actor');
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
                return ListTile(
                  leading: item is MediaItem && item.posterPath.isNotEmpty
                      ? Image.network(item.posterPath)
                      : null,
                  title: Text(item is MediaItem ? item.title : (item as Actor).name),
                  subtitle: item is Actor ? Text("Tap to view details") : null,
                  onTap: () {
                    if (item is MediaItem) {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => DetailsPage(mediaItem: item)));
                    } else if (item is Actor) {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => ActorDetailsPage(actor: item)));
                    }
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
