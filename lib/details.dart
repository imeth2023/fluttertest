import 'package:flutter/material.dart';
import 'media_item.dart';
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

  @override
  void initState() {
    super.initState();
    _checkWatchlistStatus();
  }

  void _checkWatchlistStatus() async {
    try {
      bool isInWatchlist = await _firestoreService.isInWatchlist(widget.mediaItem.id);
      setState(() {
        _isInWatchlist = isInWatchlist;
      });
    } catch (e) {
      _showSnackbar('Failed to check watchlist status');
    }
  }

  void _toggleWatchlistStatus() async {
    try {
      await _firestoreService.toggleWatchlistStatus(widget.mediaItem);
      _checkWatchlistStatus(); // Refresh the button state
      _showSnackbar(_isInWatchlist ? 'Removed from Watchlist' : 'Added to Watchlist');
    } catch (e) {
      _showSnackbar('Failed to update watchlist');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mediaItem.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 20),
            Image.network(widget.mediaItem.posterPath, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.mediaItem.title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            if (widget.mediaItem.overview != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(widget.mediaItem.overview!),
              ),
            // Display the rating
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: widget.mediaItem.rating != null
                ? Text('Rating: ${widget.mediaItem.rating}/10', style: TextStyle(fontSize: 18))
                : Text('Rating: N/A', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleWatchlistStatus,
        backgroundColor: _isInWatchlist ? Colors.red : Colors.green,
        child: Icon(_isInWatchlist ? Icons.remove : Icons.add),
        tooltip: _isInWatchlist ? 'Remove from Watched List' : 'Add to Watched List',
      ),
    );
  }
}
