class MediaItem {
  final String title;
  final String posterPath;
  final String? overview; // Optional field for movie or TV show overview
  final double? rating; // Optional field for rating
  final List<Actor>? cast; // Optional field for cast members

  MediaItem({
    required this.title,
    required this.posterPath,
    this.overview,
    this.rating,
    this.cast,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    // Parse the cast if available, otherwise, initialize it as an empty list
    List<Actor> cast = [];
    if (json.containsKey('credits') && json['credits']['cast'] != null) {
      cast = List<Actor>.from(json['credits']['cast'].map((x) => Actor.fromJson(x)));
    }

    return MediaItem(
      title: json['title'] ?? json['name'], // Movies have titles, TV shows have names
      posterPath: 'https://image.tmdb.org/t/p/w500${json['poster_path']}',
      overview: json['overview'],
      rating: json.containsKey('vote_average') ? json['vote_average'].toDouble() : null,
      cast: cast,
    );
  }
}

class Actor {
  final String name;
  final String character;

  Actor({required this.name, required this.character});

  factory Actor.fromJson(Map<String, dynamic> json) {
    return Actor(
      name: json['name'],
      character: json['character'],
    );
  }
}
