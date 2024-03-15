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
  String _searchType = "movie"; // Default to 'movie'
  final List<String> _searchTypes = ['actor', 'movie', 'tv']; // Options for dropdown
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initializeSpeechRecognizer();
  }

  void _initializeSpeechRecognizer() async {
    bool available = await _speech.initialize(onStatus: (val) => print('onStatus: $val'), onError: (val) => print('onError: $val'));
    if (!available) {
      // Handle the case where speech recognition is not available
      print("The user's device does not support speech recognition.");
    }
  }

  void _performSearch(String query) async {
    if (query.isEmpty) return;
    setState(() {
      _isLoading = true;
      _searchResults = []; // Clear previous results
    });

    try {
      if (_searchType == 'actor') {
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
      // Your existing multi-actor search logic here
    } else if (actorNames.isNotEmpty) {
      // Single actor search
      // Your existing single actor search logic here
    }
  }

  void _startListening() async {
    if (!_isListening) {
      _isListening = true; // Update listening state
      _speech.listen(onResult: (result) {
        if (result.recognizedWords.isNotEmpty) {
          _performSearch(result.recognizedWords);
        }
        _isListening = false; // Reset listening state
      });
    } else {
      _speech.stop();
      setState(() {
        _isListening = false;
      });
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
                suffixIcon: IconButton(
                  icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                  onPressed: _startListening,
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
