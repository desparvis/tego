import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/sale.dart';
import '../../domain/repositories/sales_repository.dart';
import '../../core/services/firestore_service.dart';
import '../../core/error/failures.dart';
import '../../core/utils/either.dart';

/// Concrete implementation of SalesRepository using Firestore
/// 
/// This repository implements the domain's SalesRepository interface,
/// providing concrete data access logic while maintaining separation
/// between domain and data layers. It handles:
/// - Data transformation between domain entities and Firestore documents
/// - Error handling with proper failure types
/// - Authentication state management
class SalesRepositoryImpl implements SalesRepository {
  final FirestoreService _firestoreService;
  final FirebaseAuth _auth;

  const SalesRepositoryImpl(this._firestoreService, this._auth);

  @override
  Future<Either<Failure, void>> addSale(Sale sale) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Left(AuthenticationFailure(
          message: 'User must be authenticated to add sales',
        ));
      }

      // Transform domain entity to data layer format
      final data = sale.toMap();
      data['timestamp'] = FieldValue.serverTimestamp();
      data['userId'] = user.uid; // Ensure data ownership
      
      await _firestoreService.addDocument('users/${user.uid}/sales', data);
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(FirebaseFailure(
        message: 'Failed to add sale: ${e.message}',
        code: int.tryParse(e.code),
      ));
    } catch (e) {
      return Left(NetworkFailure(
        message: 'Network error while adding sale: $e',
      ));
    }
  }

  @override
  Future<Either<Failure, List<Sale>>> getSales() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Left(AuthenticationFailure(
          message: 'User must be authenticated to view sales',
        ));
      }

      final snapshot = await _firestoreService.getCollection(
        'users/${user.uid}/sales',
        orderBy: 'timestamp',
        descending: true,
      );

      // Transform Firestore documents to domain entities
      final sales = snapshot.docs
          .map((doc) {
            try {
              return Sale.fromMap(doc.data() as Map<String, dynamic>, doc.id);
            } catch (e) {
              // Log malformed document but continue processing others
              return null;
            }
          })
          .where((sale) => sale != null)
          .cast<Sale>()
          .toList();

      return Right(sales);
    } on FirebaseException catch (e) {
      return Left(FirebaseFailure(
        message: 'Failed to fetch sales: ${e.message}',
        code: int.tryParse(e.code),
      ));
    } catch (e) {
      return Left(NetworkFailure(
        message: 'Network error while fetching sales: $e',
      ));
    }
  }
}