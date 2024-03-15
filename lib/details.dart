import 'package:flutter/material.dart';
import 'package:flutter_application_5/media_item.dart'; // Adjust this import path to where your MediaItem class is located
import 'package:flutter_application_5/firestore_service.dart'; // Adjust this import path to where your FirestoreService class is located
import 'package:flutter_application_5/api_service.dart'; // Adjust this import path to where your ApiService class is located

/// A page that displays the details of a media item.
class DetailsPage extends StatefulWidget {
  final MediaItem mediaItem;

  DetailsPage({required this.mediaItem});

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  bool _isLoading = true;
  bool _isInWatchlist = false;
  final ApiService _apiService = ApiService();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _fetchAdditionalDetails();
    _checkWatchlistStatus();
  }

  /// Fetches additional details for the media item, such as trailers, cast, and similar movies.
  Future<void> _fetchAdditionalDetails() async {
    try {
      final trailers = await _apiService.fetchTrailers('movie', widget.mediaItem.id);
      final cast = await _apiService.fetchCastDetails('movie', widget.mediaItem.id);
      final similarMovies = await _apiService.fetchSimilarMovies('movie', widget.mediaItem.id);
      setState(() {
        widget.mediaItem.trailers = trailers;
        widget.mediaItem.cast = cast;
        widget.mediaItem.similarMovies = similarMovies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackbar("Failed to load additional details: $e");
    }
  }

  /// Checks the watchlist status of the media item.
  Future<void> _checkWatchlistStatus() async {
    final status = await _firestoreService.isInWatchlist(widget.mediaItem.id);
    setState(() {
      _isInWatchlist = status;
    });
  }

  /// Toggles the watchlist status of the media item.
  void _toggleWatchlist() async {
    await _firestoreService.toggleWatchlistStatus(widget.mediaItem);
    _checkWatchlistStatus();
  }

  /// Shows a snackbar with the given message.
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Builds the list of cast members for the media item.
  Widget _buildCastList() {
    return widget.mediaItem.cast != null && widget.mediaItem.cast!.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: const Text('Cast', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              Container(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.mediaItem.cast!.length,
                  itemBuilder: (context, index) {
                    final actor = widget.mediaItem.cast![index];
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundImage: actor.imageUrl != null ? NetworkImage(actor.imageUrl!) : const AssetImage('assets/default_avatar.png') as ImageProvider,
                            radius: 35,
                          ),
                          SizedBox(height: 6),
                          Text(actor.name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          Text(actor.character, style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          )
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: const Text("No cast information available", style: TextStyle(fontSize: 16)),
          );
  }

  /// Builds the list of similar movies for the media item.
  Widget _buildSimilarMoviesList() {
    return widget.mediaItem.similarMovies != null && widget.mediaItem.similarMovies!.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: const Text('Similar Movies', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              Container(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.mediaItem.similarMovies!.length,
                  itemBuilder: (context, index) {
                    final similarMovie = widget.mediaItem.similarMovies![index];
                    return GestureDetector(
                      onTap: () {
                        // Implement navigation to similar movie details
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Column(
                          children: [
                            Expanded(
                              child: Image.network(similarMovie.posterPath, fit: BoxFit.cover),
                            ),
                            SizedBox(height: 4),
                            Text(similarMovie.title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          )
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: const Text("No similar movies available", style: TextStyle(fontSize: 16)),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mediaItem.title),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    widget.mediaItem.posterPath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 250,
                    errorBuilder: (context, error, stackTrace) => Center(child: Text('Image not available', style: TextStyle(fontSize: 16))),
                  ),
                  if (widget.mediaItem.overview != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        widget.mediaItem.overview!,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  if (widget.mediaItem.rating != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Rating: ${widget.mediaItem.rating}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  _buildCastList(),
                  _buildSimilarMoviesList(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleWatchlist,
        child: Icon(_isInWatchlist ? Icons.remove : Icons.add),
        tooltip: _isInWatchlist ? 'Remove from Watchlist' : 'Add to Watchlist',
      ),
    );
  }
}
