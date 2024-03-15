import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'media_item.dart'; // Your MediaItem model
import 'details.dart'; // Your DetailsPage for displaying selected media item details
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<MediaItem> _searchResults = [];
  bool _isLoading = false;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  TextEditingController _controller = TextEditingController();
  String _searchType = 'actor'; // Default search type, you can switch between 'actor', 'movie', 'tv'
  final List<String> _searchTypes = ['actor', 'movie', 'tv']; // Available search types
  final String apiKey = '8ac4b0da7612dfd2f781452f3d30719a';
  final String baseUrl = 'https://api.themoviedb.org/3';

  @override
  void initState() {
    super.initState();
    _initializeSpeechRecognizer();
  }

  // Initialize the speech recognizer
  void _initializeSpeechRecognizer() async {
    bool available = await _speech.initialize(
      onStatus: (val) => print('onStatus: $val'),
      onError: (val) => print('onError: $val'),
    );
    if (!available) {
      // Handle the case where speech recognition is not available
    }
  }

  // Perform the search based on the query
  void _performSearch(String query) async {
    if (query.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      List<MediaItem> results = [];
      if (_searchType == 'actor') {
        List<String> actorNames = query.split(',').map((name) => name.trim()).toList();
        if (actorNames.length <= 2) {
          // Handle actor search logic
          results = await _searchActors(actorNames);
        } else {
          print("Please enter one or two actor names separated by a comma.");
        }
      } else if (_searchType == 'movie') {
        results = await _fetchMoviesByTitle(query);
      } else if (_searchType == 'tv') {
        results = await _fetchTVShowsByTitle(query);
      }

      setState(() => _searchResults = results);
    } catch (e) {
      print("Error performing search: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Search for actors based on their names
  Future<List<MediaItem>> _searchActors(List<String> actorNames) async {
    List<List<MediaItem>> filmographies = [];
    for (String actorName in actorNames) {
      final actorId = await _fetchActorIdByName(actorName);
      if (actorId != null) {
        final filmography = await _fetchActorFilmographyById(actorId);
        filmographies.add(filmography);
      }
    }
    // If two actors are searched, find the intersection of their filmographies
    return filmographies.length == 2 ? _findCommonFilmography(filmographies) : filmographies.isEmpty ? [] : filmographies.first;
  }

  // Fetch the actor ID based on the actor name
  Future<String?> _fetchActorIdByName(String actorName) async {
    final response = await http.get(Uri.parse('$baseUrl/search/person?api_key=$apiKey&query=${Uri.encodeComponent(actorName)}'));
    if (response.statusCode == 200) {
      final results = json.decode(response.body)['results'];
      if (results.isNotEmpty) {
        return results[0]['id'].toString();
      }
    }
    return null;
  }

  // Fetch the filmography of an actor based on their ID
  Future<List<MediaItem>> _fetchActorFilmographyById(String actorId) async {
    final response = await http.get(Uri.parse('$baseUrl/person/$actorId/movie_credits?api_key=$apiKey'));
    if (response.statusCode == 200) {
      final results = json.decode(response.body)['cast'];
      return results.map<MediaItem>((data) => MediaItem.fromJson(data)).toList();
    }
    return [];
  }

  // Find the common filmography between two actors
  List<MediaItem> _findCommonFilmography(List<List<MediaItem>> filmographies) {
    var set1 = filmographies[0].map((e) => e.id).toSet();
    var set2 = filmographies[1].map((e) => e.id).toSet();
    var commonIds = set1.intersection(set2);
    return filmographies[0].where((item) => commonIds.contains(item.id)).toList();
  }

  // Fetch movies based on the title
  Future<List<MediaItem>> _fetchMoviesByTitle(String title) async {
    final response = await http.get(Uri.parse('$baseUrl/search/movie?api_key=$apiKey&query=${Uri.encodeComponent(title)}'));
    if (response.statusCode == 200) {
      final results = json.decode(response.body)['results'];
      return results.map<MediaItem>((data) => MediaItem.fromJson(data)).toList();
    }
    return [];
  }

  // Fetch TV shows based on the title
  Future<List<MediaItem>> _fetchTVShowsByTitle(String title) async {
    final response = await http.get(Uri.parse('$baseUrl/search/tv?api_key=$apiKey&query=${Uri.encodeComponent(title)}'));
    if (response.statusCode == 200) {
      final results = json.decode(response.body)['results'];
      return results.map<MediaItem>((data) => MediaItem.fromJson(data)).toList();
    }
    return [];
  }

  // Start or stop listening for speech input
  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (val) => setState(() {
          _controller.text = val.recognizedWords;
        }));
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
        actions: <Widget>[
          DropdownButton<String>(
            underline: Container(),
            value: _searchType,
            icon: Icon(Icons.arrow_downward, color: Colors.white),
            onChanged: (String? newValue) {
              setState(() {
                _searchType = newValue!;
                _searchResults = []; // Clear results on search type change
              });
            },
            items: _searchTypes.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value.toUpperCase(), style: TextStyle(color: Colors.white)),
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
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Search...',
                suffixIcon: IconButton(
                  icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                  onPressed: _listen,
                ),
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
                          MaterialPageRoute(
                            builder: (context) => DetailsPage(mediaItem: item),
                          ),
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
