import 'package:flutter/material.dart';
import 'media_item.dart'; // Make sure this import points to the correct file path

class DetailsPage extends StatelessWidget {
  final MediaItem mediaItem;

  DetailsPage({required this.mediaItem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(mediaItem.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(mediaItem.posterPath),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Overview:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(mediaItem.overview ?? 'No overview available.'),
            ),
            SizedBox(height: 10),
            if (mediaItem.rating != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Rating: ${mediaItem.rating}',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Cast:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: mediaItem.cast != null && mediaItem.cast!.isNotEmpty
                  ? Column(
                      children: mediaItem.cast!
                          .map((actor) => ListTile(
                                title: Text(actor.name),
                                subtitle: Text('as ${actor.character}'),
                              ))
                          .toList(),
                    )
                  : Text('No cast information available.'),
            ),
          ],
        ),
      ),
    );
  }
}
