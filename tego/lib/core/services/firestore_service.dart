import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

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
    debugPrint(
      'FirestoreService.setDocument: $collectionPath/$documentId -> $data',
    );
    try {
      return _db
          .collection(collectionPath)
          .doc(documentId)
          .set(data, SetOptions(merge: true));
    } catch (e, st) {
      debugPrint('FirestoreService.setDocument ERROR: $e\n$st');
      rethrow;
    }
  }

  // Add a new document with an auto-generated ID and return the DocumentReference.
  Future<DocumentReference> addDocument(
    String collectionPath,
    Map<String, dynamic> data,
  ) {
    debugPrint('FirestoreService.addDocument: $collectionPath -> $data');
    try {
      return _db.collection(collectionPath).add(data);
    } catch (e, st) {
      debugPrint('FirestoreService.addDocument ERROR: $e\n$st');
      rethrow;
    }
  }

  // Get a single document snapshot.
  Future<DocumentSnapshot> getDocument(
    String collectionPath,
    String documentId,
  ) {
    debugPrint('FirestoreService.getDocument: $collectionPath/$documentId');
    try {
      return _db.collection(collectionPath).doc(documentId).get();
    } catch (e, st) {
      debugPrint('FirestoreService.getDocument ERROR: $e\n$st');
      rethrow;
    }
  }

  // Stream a collection (useful for realtime lists).
  Stream<QuerySnapshot> streamCollection(
    String collectionPath, {
    int limit = 50,
  }) {
    debugPrint(
      'FirestoreService.streamCollection: $collectionPath (limit=$limit)',
    );
    return _db.collection(collectionPath).limit(limit).snapshots();
  }

  // Stream a collection with a query builder for filtering/ordering.
  Stream<QuerySnapshot> streamCollectionQuery(
    String collectionPath, {
    Query Function(CollectionReference<Map<String, dynamic>>)? queryBuilder,
    int? limit,
  }) {
    final col = _db.collection(collectionPath);
    var query = (queryBuilder != null) ? queryBuilder(col) : col;
    if (limit != null) query = query.limit(limit);
    debugPrint(
      'FirestoreService.streamCollectionQuery: $collectionPath (limit=$limit)',
    );
    return query.snapshots();
  }

  // Stream a single document.
  Stream<DocumentSnapshot> streamDocument(
    String collectionPath,
    String documentId,
  ) {
    debugPrint('FirestoreService.streamDocument: $collectionPath/$documentId');
    return _db.collection(collectionPath).doc(documentId).snapshots();
  }

  // Delete a document.
  Future<void> deleteDocument(String collectionPath, String documentId) {
    debugPrint('FirestoreService.deleteDocument: $collectionPath/$documentId');
    try {
      return _db.collection(collectionPath).doc(documentId).delete();
    } catch (e, st) {
      debugPrint('FirestoreService.deleteDocument ERROR: $e\n$st');
      rethrow;
    }
  }

  // Paginated get for a collection (one-shot, not realtime). Returns the fetched documents.
  Future<List<DocumentSnapshot>> paginateCollection(
    String collectionPath, {
    int limit = 20,
    DocumentSnapshot? startAfter,
    String orderByField = 'timestamp',
    bool descending = true,
  }) async {
    debugPrint(
      'FirestoreService.paginateCollection: $collectionPath (orderBy=$orderByField, limit=$limit)',
    );
    Query<Map<String, dynamic>> query = _db
        .collection(collectionPath)
        .orderBy(orderByField, descending: descending)
        .limit(limit);
    if (startAfter != null) query = query.startAfterDocument(startAfter);
    final snapshot = await query.get();
    return snapshot.docs;
  }

  // Update fields on a document (partial update).
  Future<void> updateDocumentFields(
    String collectionPath,
    String documentId,
    Map<String, dynamic> fields,
  ) {
    debugPrint(
      'FirestoreService.updateDocumentFields: $collectionPath/$documentId -> $fields',
    );
    try {
      return _db.collection(collectionPath).doc(documentId).update(fields);
    } catch (e, st) {
      debugPrint('FirestoreService.updateDocumentFields ERROR: $e\n$st');
      rethrow;
    }
  }

  // Example helper to create a user document after sign-up.
  Future<void> createUserDoc(String uid, Map<String, dynamic> data) {
    return setDocument('users', uid, data);
  }
}
