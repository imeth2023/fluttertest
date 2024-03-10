import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_service.dart';
import 'media_item.dart';
import 'details.dart';

class WatchlistPage extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Watchlist'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _firestoreService.fetchWatchlist(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (snapshot.hasData) {
            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                MediaItem item = MediaItem.fromFirestore(document);
                return ListTile(
                  title: Text(item.title),
                  subtitle: Text(item.overview ?? 'No description'),
                  leading: Image.network(item.posterPath, width: 100, fit: BoxFit.cover),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => DetailsPage(mediaItem: item)),
                  ),
                );
              }).toList(),
            );
          } else {
            return Text('Your watchlist is empty');
          }
        },
      ),
    );
  }
}
