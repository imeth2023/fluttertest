import 'package:cloud_firestore/cloud_firestore.dart';

class MediaItem {
  final String id;
  final String title;
  final String posterPath;
  final String? overview;
  final double? rating;
  List<Actor>? cast;
  List<String>? trailers;
  List<MediaItem>? similarMovies;

  MediaItem({
    required this.id,
    required this.title,
    required this.posterPath,
    this.overview,
    this.rating,
    this.cast,
    this.trailers,
    this.similarMovies,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    List<Actor> cast = [];
    if (json.containsKey('credits') && json['credits']['cast'] != null) {
      cast = List<Actor>.from(json['credits']['cast'].map((x) => Actor.fromJson(x)));
    }
    
    // Assuming trailers and similarMovies are part of your JSON and are lists of strings/objects
    List<String>? trailers = json['trailers']?.map<String>((item) => item.toString()).toList();
    List<MediaItem>? similarMovies;
    if (json['similarMovies'] != null) {
      similarMovies = List<MediaItem>.from(json['similarMovies'].map((item) => MediaItem.fromJson(item)));
    }

    return MediaItem(
      id: json['id'].toString(),
      title: json['title'] ?? json['name'],
      posterPath: 'https://image.tmdb.org/t/p/w500${json['poster_path']}',
      overview: json['overview'],
      rating: json.containsKey('vote_average') ? json['vote_average'].toDouble() : null,
      cast: cast,
      trailers: trailers,
      similarMovies: similarMovies,
    );
  }

  factory MediaItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> json = doc.data() as Map<String, dynamic>;
    return MediaItem(
      id: doc.id,
      title: json['title'],
      posterPath: json['posterPath'],
      overview: json['overview'],
      rating: json.containsKey('rating') ? double.tryParse(json['rating'].toString()) : null,
      // Assume cast, trailers, and similarMovies are not stored or are stored differently in Firestore
      cast: [],
      trailers: [],
      similarMovies: [],
    );
  }
}

class Actor {
  final String id;
  final String name;
  final String character;
  final String? imageUrl;
  final String? biography;

  Actor({
    required this.id,
    required this.name,
    required this.character,
    this.imageUrl,
    this.biography,
  });

  factory Actor.fromJson(Map<String, dynamic> json) {
    return Actor(
      id: json['id'].toString(),
      name: json['name'],
      character: json['character'],
      imageUrl: json['profile_path'] != null ? 'https://image.tmdb.org/t/p/w500${json['profile_path']}' : null,
      biography: json['biography'],
    );
  }
}
