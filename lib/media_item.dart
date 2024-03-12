import 'package:cloud_firestore/cloud_firestore.dart';

class MediaItem {
  final String id;
  final String title;
  final String posterPath;
  final String? overview;
  final double? rating;
  final List<Actor>? cast;

  MediaItem({
    required this.id,
    required this.title,
    required this.posterPath,
    this.overview,
    this.rating,
    this.cast,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    List<Actor> cast = [];
    if (json.containsKey('credits') && json['credits']['cast'] != null) {
      cast = List<Actor>.from(json['credits']['cast'].map((x) => Actor.fromJson(x)));
    }

    return MediaItem(
      id: json['id'].toString(),
      title: json['title'] ?? json['name'],
      posterPath: 'https://image.tmdb.org/t/p/w500${json['poster_path']}',
      overview: json['overview'],
      rating: json.containsKey('vote_average') ? json['vote_average'].toDouble() : null,
      cast: cast,
    );
  }

  // Add this factory constructor
  factory MediaItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return MediaItem(
      id: doc.id,
      title: data['title'],
      posterPath: data['posterPath'],
      overview: data['overview'],
      rating: data['rating'],
      cast: [], // You'll need to adjust this if your documents include cast information
    );
  }
}

class Actor {
  final String id; // Added ID field
  final String name;
  final String character;
  final String? imageUrl;
  final String? biography; // Keep as is

  Actor({
    required this.id,
    required this.name,
    required this.character,
    this.imageUrl,
    this.biography,
  });

  factory Actor.fromJson(Map<String, dynamic> json) {
  return Actor(
    id: json['id'].toString(), // Assuming ID is always present
    name: json['name'] ?? 'Unknown', // Providing a default value in case of null
    character: json['character'] ?? 'Unknown', // Providing a default value in case of null
    imageUrl: json['profile_path'] != null ? 'https://image.tmdb.org/t/p/w500${json['profile_path']}' : null,
    biography: json['biography'], // Biography is nullable, so it's okay to be null
  );
}

}
