import 'package:cloud_firestore/cloud_firestore.dart';
import 'media_item.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String collectionPath = 'watchedlist'; // Name of the collection

  // Add or Remove item from watched list
  Future<void> toggleWatchlistStatus(MediaItem item) async {
    DocumentReference docRef = _db.collection(collectionPath).doc(item.id);

    var doc = await docRef.get();
    if (doc.exists) {
      // If exists, remove from watched list
      await docRef.delete();
    } else {
      // If not exists, add to watched list
      await docRef.set({
        'title': item.title,
        'posterPath': item.posterPath,
        // Include additional fields as necessary
      });
    }
  }

  Future<QuerySnapshot> fetchWatchlist() async {
  return await _db.collection(collectionPath).get();
}

  // Check if an item is in the watched list
  Future<bool> isInWatchlist(String itemId) async {
    var doc = await _db.collection(collectionPath).doc(itemId).get();
    return doc.exists;
  }
}
