import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add or update a document at `collectionPath/documentId`.
  Future<void> setDocument(
    String collectionPath,
    String documentId,
    Map<String, dynamic> data,
  ) {
    return _db
        .collection(collectionPath)
        .doc(documentId)
        .set(data, SetOptions(merge: true));
  }

  // Add a new document with an auto-generated ID and return the DocumentReference.
  Future<DocumentReference> addDocument(
    String collectionPath,
    Map<String, dynamic> data,
  ) {
    return _db.collection(collectionPath).add(data);
  }

  // Get a single document snapshot.
  Future<DocumentSnapshot> getDocument(
    String collectionPath,
    String documentId,
  ) {
    return _db.collection(collectionPath).doc(documentId).get();
  }

  // Stream a collection (useful for realtime lists).
  Stream<QuerySnapshot> streamCollection(
    String collectionPath, {
    int limit = 50,
  }) {
    return _db.collection(collectionPath).limit(limit).snapshots();
  }

  // Stream a single document.
  Stream<DocumentSnapshot> streamDocument(
    String collectionPath,
    String documentId,
  ) {
    return _db.collection(collectionPath).doc(documentId).snapshots();
  }

  // Delete a document.
  Future<void> deleteDocument(String collectionPath, String documentId) {
    return _db.collection(collectionPath).doc(documentId).delete();
  }

  // Example helper to create a user document after sign-up.
  Future<void> createUserDoc(String uid, Map<String, dynamic> data) {
    return setDocument('users', uid, data);
  }
}
