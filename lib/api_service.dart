import 'dart:convert';
import 'package:http/http.dart' as http;
import 'media_item.dart'; // Ensure this points to your MediaItem model

class ApiService {
  final String apiKey = '8ac4b0da7612dfd2f781452f3d30719a';
  final String baseUrl = 'https://api.themoviedb.org/3';

  Future<List<MediaItem>> fetchTrending(String mediaType) async {
    final response = await http.get(Uri.parse('$baseUrl/trending/$mediaType/day?api_key=$apiKey'));
    if (response.statusCode == 200) {
      final List<dynamic> results = jsonDecode(response.body)['results'];
      return results.map((data) => MediaItem.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load trending $mediaType');
    }
  }

  Future<List<MediaItem>> fetchMediaByGenre(String mediaType, int genreId, {String sortBy = 'popularity.desc'}) async {
    final url = Uri.parse('$baseUrl/discover/$mediaType?api_key=$apiKey&with_genres=$genreId&sort_by=$sortBy');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> results = jsonDecode(response.body)['results'];
      return results.map((data) => MediaItem.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load $mediaType by genre $genreId sorted by $sortBy');
    }
  }

  // Updated method to use the multi search feature of TMDB API
  Future<List<MediaItem>> searchMedia(String query, String mediaType) async {
    // Change the URL to use the 'search/multi' endpoint
    final response = await http.get(Uri.parse('$baseUrl/search/multi?api_key=$apiKey&query=${Uri.encodeComponent(query)}'));
    if (response.statusCode == 200) {
      final List<dynamic> results = jsonDecode(response.body)['results'];
      // Filter results based on the 'media_type' field if you still want to differentiate between movies and tv shows
      // Or you can modify your MediaItem model and UI to handle different media types
      List<MediaItem> mediaItems = [];
      for (var result in results) {
        // Optionally, filter results by media type if necessary
        if (mediaType == 'all' || result['media_type'] == mediaType) {
          mediaItems.add(MediaItem.fromJson(result));
        }
      }
      return mediaItems;
    } else {
      throw Exception('Failed to search across all media types with query "$query"');
    }
  }
}
