import 'package:flutter/material.dart';
import 'api_service.dart'; // Adjust with your actual import path
import 'media_item.dart'; // Adjust with your actual import path
import 'details.dart'; // Adjust with your actual import path
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApiService _apiService = ApiService();
  List<MediaItem> _searchResults = [];
  bool _isLoading = false;
  String _searchType = "movie"; // Default search type
  final List<String> _searchTypes = ['actor', 'movie', 'tv']; // Available search types
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeSpeechRecognizer();
  }

  void _initializeSpeechRecognizer() async {
    await _speech.initialize(
      onStatus: (val) => print('onStatus: $val'),
      onError: (val) => print('onError: $val'),
    );
  }

  void _performSearch(String query) async {
    if (query.isEmpty) return;
    setState(() {
      _isLoading = true;
      _searchResults = [];
    });

    try {
      if (_searchType == 'actor') {
        await _handleActorSearch(query);
      } else {
        List<MediaItem> mediaItems = await _apiService.searchMedia(query, _searchType);
        setState(() {
          _searchResults = mediaItems;
        });
      }
    } catch (e) {
      print("Error performing search: $e");
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
        MediaItem? film = await _apiService.fetchMediaDetailsById(id);
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

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (val) => setState(() {
          _controller.text = val.recognizedWords;
          _performSearch(val.recognizedWords);
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
            onChanged: (String? newValue) {
              setState(() {
                _searchType = newValue!;
                _searchResults = []; // Clear results on search type change
                if (_controller.text.isNotEmpty) {
                  _performSearch(_controller.text);
                }
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
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Search...',
                suffixIcon: IconButton(
                  icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                  onPressed: _listen,
                ),
              ),
              onChanged: _performSearch, // Trigger search on text change
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
