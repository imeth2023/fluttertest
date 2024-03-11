import 'package:flutter/material.dart';
import 'media_item.dart'; // Ensure this includes the updated model definitions
import 'firestore_service.dart';

class DetailsPage extends StatefulWidget {
  final MediaItem mediaItem;

  DetailsPage({required this.mediaItem});

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  bool _isInWatchlist = false;
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    _checkWatchlistStatus();
  }

  Future<void> _checkWatchlistStatus() async {
    try {
      bool isInWatchlist = await _firestoreService.isInWatchlist(widget.mediaItem.id);
      setState(() {
        _isInWatchlist = isInWatchlist;
        _isLoading = false; // Update loading state
      });
    } catch (e) {
      setState(() {
        _isLoading = false; // Ensure loading state is updated even on error
      });
      _showSnackbar('Failed to check watchlist status');
    }
  }

  void _toggleWatchlistStatus() async {
    setState(() {
      _isLoading = true; // Set loading state
    });
    try {
      await _firestoreService.toggleWatchlistStatus(widget.mediaItem);
      await _checkWatchlistStatus(); // Refresh the button state after toggling
    } catch (e) {
      _showSnackbar('Failed to update watchlist');
      setState(() {
        _isLoading = false; // Reset loading state in case of error
      });
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  Widget _buildActionButton() {
    if (_isLoading) {
      return FloatingActionButton(
        onPressed: null, // Disable the button while loading
        backgroundColor: Colors.grey,
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    return FloatingActionButton(
      onPressed: _toggleWatchlistStatus,
      backgroundColor: _isInWatchlist ? Colors.red : Colors.green,
      child: Icon(_isInWatchlist ? Icons.remove : Icons.add),
      tooltip: _isInWatchlist ? 'Remove from Watchlist' : 'Add to Watchlist',
    );
  }

  Widget _buildCastList() {
    return widget.mediaItem.cast != null && widget.mediaItem.cast!.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Cast', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              Container(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.mediaItem.cast!.length,
                  itemBuilder: (context, index) {
                    final actor = widget.mediaItem.cast![index];
                    return Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundImage: actor.imageUrl != null ? NetworkImage(actor.imageUrl!) : AssetImage('assets/default_avatar.png') as ImageProvider,
                            radius: 35,
                            backgroundColor: Colors.grey.shade200, // Fallback color
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
            padding: EdgeInsets.all(8.0),
            child: Text("No cast information available", style: TextStyle(fontSize: 16)),
          );
  }

  Widget _buildMediaDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Image.network(
          widget.mediaItem.posterPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(child: Text('Image not available', style: TextStyle(fontSize: 16)));
          },
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            widget.mediaItem.overview ?? 'No description available.',
            style: TextStyle(fontSize: 16),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Rating: ${widget.mediaItem.rating ?? 'N/A'}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        _buildCastList(), // Include the cast list in the media details
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mediaItem.title),
      ),
      body: SingleChildScrollView(
        child: _buildMediaDetails(), // Call the method to build media details
      ),
      floatingActionButton: _buildActionButton(),
    );
  }
}
