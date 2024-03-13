import 'package:flutter/material.dart';
import 'package:flutter_application_5/media_item.dart'; // Adjust the import path as needed
import 'package:flutter_application_5/api_service.dart'; // Adjust the import path as needed


class DetailsPage extends StatefulWidget {
  final MediaItem mediaItem;

  DetailsPage({required this.mediaItem});

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  bool _isLoading = true;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchAdditionalDetails();
  }

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

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

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
                        // Implement navigation to movie details
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
    );
  }
}
