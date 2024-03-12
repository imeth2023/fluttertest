import 'dart:convert';
import 'package:http/http.dart' as http;
import 'media_item.dart'; // Make sure this points to your MediaItem model
import 'media_item.dart'; // Adjust this import to your Actor model (if you have it)

class ApiService {
  final String apiKey = '8ac4b0da7612dfd2f781452f3d30719a';
  final String baseUrl = 'https://api.themoviedb.org/3';

  Future<List<MediaItem>> fetchTrending(String mediaType, {String timeWindow = 'day'}) async {
    final url = Uri.parse('$baseUrl/trending/$mediaType/$timeWindow?api_key=$apiKey');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> results = jsonDecode(response.body)['results'];
      return results.map<MediaItem>((data) => MediaItem.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load trending $mediaType');
    }
  }

  Future<List<MediaItem>> fetchMediaByGenre(String mediaType, int genreId, {String sortBy = 'popularity.desc'}) async {
    final url = Uri.parse('$baseUrl/discover/$mediaType?api_key=$apiKey&with_genres=$genreId&sort_by=$sortBy');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> results = jsonDecode(response.body)['results'];
      return results.map<MediaItem>((data) => MediaItem.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load $mediaType by genre $genreId sorted by $sortBy');
    }
  }

  Future<MediaItem> fetchMediaDetailsWithCast(String mediaId, String mediaType) async {
    final url = Uri.parse('$baseUrl/$mediaType/$mediaId?api_key=$apiKey&append_to_response=credits');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return MediaItem.fromJson(data);
    } else {
      throw Exception('Failed to load media details with cast');
    }
  }

  Future<List<dynamic>> searchMedia(String query, String mediaType) async {
    final url = Uri.parse('$baseUrl/search/multi?api_key=$apiKey&query=${Uri.encodeComponent(query)}');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> results = jsonDecode(response.body)['results'];
      List<dynamic> items = results.where((result) => result['media_type'] == mediaType || mediaType == 'all').map((data) => MediaItem.fromJson(data)).toList();
      return items;
    } else {
      throw Exception('Failed to search across all media types with query "$query"');
    }
  }

  Future<List<Actor>> searchActors(String query) async {
    final url = Uri.parse('$baseUrl/search/person?api_key=$apiKey&query=${Uri.encodeComponent(query)}');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> results = jsonDecode(response.body)['results'];
      return results.map<Actor>((data) => Actor.fromJson(data)).toList();
    } else {
      throw Exception('Failed to search for actors with query "$query"');
    }
  }

  Future<Actor> fetchActorDetails(String actorId) async {
    final url = Uri.parse('$baseUrl/person/$actorId?api_key=$apiKey&append_to_response=combined_credits');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Actor.fromJson(data);
    } else {
      throw Exception('Failed to load actor details for actor ID $actorId');
    }
  }

  Future<MediaItem> fetchLatestMovies(String mediaType) async {
    final url = Uri.parse('$baseUrl/$mediaType/latest?api_key=$apiKey');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return MediaItem.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load latest $mediaType');
    }
  }
}
