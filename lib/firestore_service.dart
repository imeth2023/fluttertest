import 'package:cloud_firestore/cloud_firestore.dart';
import 'media_item.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String collectionPath = 'watchedlist';

  Future<void> toggleWatchlistStatus(MediaItem item) async {
    DocumentReference docRef = _db.collection(collectionPath).doc(item.id);

    var doc = await docRef.get();
    if (doc.exists) {
      await docRef.delete();
    } else {
      await docRef.set({
        'title': item.title,
        'posterPath': item.posterPath,
        // Map other fields as necessary
        'overview': item.overview,
        'rating': item.rating,
        // 'cast' handling could be more complex due to nested objects
      });
    }
  }

  Future<bool> isInWatchlist(String itemId) async {
    var doc = await _db.collection(collectionPath).doc(itemId).get();
    return doc.exists;
  }

  Future<QuerySnapshot> fetchWatchlist() async {
    return await _db.collection(collectionPath).get();
  }
}
