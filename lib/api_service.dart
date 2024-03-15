import 'dart:convert';
import 'package:http/http.dart' as http;
import 'media_item.dart'; 

class ApiService {
  final String apiKey = '8ac4b0da7612dfd2f781452f3d30719a';
  final String baseUrl = 'https://api.themoviedb.org/3';

  // Fetch trending media items
  Future<List<MediaItem>> fetchTrending(String mediaType, {String timeWindow = 'day'}) async {
    final url = Uri.parse('$baseUrl/trending/$mediaType/$timeWindow?api_key=$apiKey');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List results = jsonDecode(response.body)['results'];
      return results.map<MediaItem>((data) => MediaItem.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load trending $mediaType');
    }
  }

  // Fetch top rated media items
  Future<List<MediaItem>> fetchTopRated(String mediaType) async {
    final Uri url = Uri.parse('$baseUrl/$mediaType/top_rated?api_key=$apiKey');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> results = json.decode(response.body)['results'];
      return results.map<MediaItem>((data) => MediaItem.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load top rated $mediaType');
    }
  }

  // Fetch media items by genre
  Future<List<MediaItem>> fetchMediaByGenre(String mediaType, int genreId, {String sortBy = 'popularity.desc'}) async {
    final url = Uri.parse('$baseUrl/discover/$mediaType?api_key=$apiKey&with_genres=$genreId&sort_by=$sortBy');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List results = jsonDecode(response.body)['results'];
      return results.map<MediaItem>((data) => MediaItem.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load $mediaType by genre $genreId sorted by $sortBy');
    }
  }

  // Fetch media items by genre and sort
  Future<List<MediaItem>> fetchMediaByGenreAndSort(String mediaType, int genreId, {String sortBy = 'popularity.desc'}) async {
    final url = Uri.parse('$baseUrl/discover/$mediaType?api_key=$apiKey&with_genres=$genreId&sort_by=$sortBy');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List results = jsonDecode(response.body)['results'];
      return results.map<MediaItem>((data) => MediaItem.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load $mediaType by genre $genreId sorted by $sortBy');
    }
  }

  // Fetch top grossing movies by genre
  Future<List<MediaItem>> fetchTopGrossingMoviesByGenre(int genreId) async {
    // This assumes that sorting by 'revenue.desc' is a valid and supported sort method for movies
    return fetchMediaByGenreAndSort('movie', genreId, sortBy: 'revenue.desc');
  }

  // Fetch media details by ID
  Future<MediaItem?> fetchMediaDetailsById(String mediaId) async {
    final url = Uri.parse('$baseUrl/movie/$mediaId?api_key=$apiKey');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return MediaItem.fromJson(data);
    } else {
      // Log or handle the error
      print('Failed to load media details for ID $mediaId');
      return null;
    }
  }

  // Fetch media details with cast
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

  // Search media items
  Future<List<MediaItem>> searchMedia(String query, String mediaType) async {
    final url = Uri.parse('$baseUrl/search/multi?api_key=$apiKey&query=${Uri.encodeComponent(query)}');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List results = jsonDecode(response.body)['results'];
      // Filter by media type if not searching across all media types
      List<MediaItem> items = results.where((result) => result['media_type'] == mediaType || mediaType == 'all')
                                      .map<MediaItem>((data) => MediaItem.fromJson(data)).toList();
      return items;
    } else {
      throw Exception('Failed to search across all media types with query "$query"');
    }
  }

  // Fetch actor details
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

  // Fetch genres
  Future<Map<String, int>> fetchGenres(String mediaType) async {
    final url = Uri.parse('$baseUrl/genre/$mediaType/list?api_key=$apiKey');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final Map<String, int> genres = {};
      for (var genre in jsonResponse['genres']) {
        genres[genre['name']] = genre['id'];
      }
      return genres;
    } else {
      throw Exception('Failed to load genres');
    }
  }

  // Search actors
  Future<List<Actor>> searchActors(String query) async {
    final url = Uri.parse('$baseUrl/search/person?api_key=$apiKey&query=${Uri.encodeComponent(query)}');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List results = jsonDecode(response.body)['results'];
      return results.map<Actor>((data) => Actor.fromJson(data)).toList();
    } else {
      throw Exception('Failed to search for actors with query "$query"');
    }
  }

  // Fetch actor filmography
  Future<List<MediaItem>> fetchActorFilmography(String actorId) async {
    final url = Uri.parse('$baseUrl/person/$actorId/combined_credits?api_key=$apiKey');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final results = jsonDecode(response.body)['cast'];
      return results.map<MediaItem>((data) => MediaItem.fromJson(data)).toList();
    } else {
      throw Exception('Failed to fetch filmography for actor ID $actorId');
    }
  }

  // Fetch trailers
  Future<List<String>> fetchTrailers(String mediaType, String mediaId) async {
    final response = await http.get(Uri.parse('$baseUrl/$mediaType/$mediaId/videos?api_key=$apiKey'));
    if (response.statusCode == 200) {
      final List<dynamic> trailers = jsonDecode(response.body)['results'];
      return trailers.map((trailer) => "https://www.youtube.com/watch?v=${trailer['key']}").toList();
    } else {
      throw Exception('Failed to load trailers');
    }
  }

  // Fetch cast details
  Future<List<Actor>> fetchCastDetails(String mediaType, String mediaId) async {
    final response = await http.get(Uri.parse('$baseUrl/$mediaType/$mediaId/credits?api_key=$apiKey'));
    if (response.statusCode == 200) {
      final List<dynamic> cast = jsonDecode(response.body)['cast'];
      return cast.map((actor) => Actor.fromJson(actor)).toList();
    } else {
      throw Exception('Failed to load cast details');
    }
  }

  // Fetch similar movies
  Future<List<MediaItem>> fetchSimilarMovies(String mediaType, String mediaId) async {
    final response = await http.get(Uri.parse('$baseUrl/$mediaType/$mediaId/similar?api_key=$apiKey'));
    if (response.statusCode == 200) {
      final List<dynamic> movies = jsonDecode(response.body)['results'];
      return movies.map((movie) => MediaItem.fromJson(movie)).toList();
    } else {
      throw Exception('Failed to load similar movies');
    }
  }
}
