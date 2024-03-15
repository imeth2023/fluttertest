import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'media_item.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the path for the current user's watchlist
  String get userPath => 'users/${_auth.currentUser?.uid}/watchlist';

  // Toggle the watchlist status of a media item
  Future<void> toggleWatchlistStatus(MediaItem item) async {
    DocumentReference docRef = _db.collection(userPath).doc(item.id);

    var doc = await docRef.get();
    if (doc.exists) {
      await docRef.delete();
    } else {
      await docRef.set({
        'title': item.title,
        'posterPath': item.posterPath,
        'overview': item.overview,
        'rating': item.rating,
        // Include additional fields as necessary
      });
    }
  }

  // Check if an item is in the watchlist
  Future<bool> isInWatchlist(String itemId) async {
    var doc = await _db.collection(userPath).doc(itemId).get();
    return doc.exists;
  }

  // Fetch the watchlist for the current user
  Future<QuerySnapshot> fetchWatchlist() async {
    return await _db.collection(userPath).get();
  }
}
