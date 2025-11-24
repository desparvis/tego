import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/expense.dart';
import '../../core/services/firestore_service.dart';
import '../../core/error/failures.dart';
import '../../core/utils/either.dart';

/// Repository implementation for expense CRUD operations
class ExpenseRepositoryImpl {
  final FirestoreService _firestoreService;
  final FirebaseAuth _auth;

  const ExpenseRepositoryImpl(this._firestoreService, this._auth);

  /// Create expense with validation
  Future<Either<Failure, void>> addExpense(Expense expense) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Left(AuthenticationFailure(
          message: 'User must be authenticated to add expenses',
        ));
      }

      final data = expense.toMap();
      data['timestamp'] = FieldValue.serverTimestamp();
      
      await _firestoreService.addDocument('users/${user.uid}/expenses', data);
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(FirebaseFailure(
        message: 'Failed to add expense: ${e.message}',
        code: int.tryParse(e.code),
      ));
    } catch (e) {
      return Left(NetworkFailure(
        message: 'Network error while adding expense: $e',
      ));
    }
  }

  /// Read expenses with pagination
  Future<Either<Failure, List<Expense>>> getExpenses() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Left(AuthenticationFailure(
          message: 'User must be authenticated to view expenses',
        ));
      }

      final snapshot = await _firestoreService.getCollection(
        'users/${user.uid}/expenses',
        orderBy: 'timestamp',
        descending: true,
      );

      final expenses = snapshot.docs
          .map((doc) {
            try {
              return Expense.fromMap(doc.data() as Map<String, dynamic>, doc.id);
            } catch (e) {
              return null;
            }
          })
          .where((expense) => expense != null)
          .cast<Expense>()
          .toList();

      return Right(expenses);
    } on FirebaseException catch (e) {
      return Left(FirebaseFailure(
        message: 'Failed to fetch expenses: ${e.message}',
        code: int.tryParse(e.code),
      ));
    } catch (e) {
      return Left(NetworkFailure(
        message: 'Network error while fetching expenses: $e',
      ));
    }
  }

  /// Update expense
  Future<Either<Failure, void>> updateExpense(Expense expense) async {
    try {
      final user = _auth.currentUser;
      if (user == null || expense.id == null) {
        return const Left(AuthenticationFailure(
          message: 'User must be authenticated and expense must have ID',
        ));
      }

      final data = expense.toMap();
      await _firestoreService.updateDocumentFields(
        'users/${user.uid}/expenses',
        expense.id!,
        data,
      );
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(FirebaseFailure(
        message: 'Failed to update expense: ${e.message}',
        code: int.tryParse(e.code),
      ));
    } catch (e) {
      return Left(NetworkFailure(
        message: 'Network error while updating expense: $e',
      ));
    }
  }

  /// Delete expense
  Future<Either<Failure, void>> deleteExpense(String expenseId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Left(AuthenticationFailure(
          message: 'User must be authenticated to delete expenses',
        ));
      }

      await _firestoreService.deleteDocument(
        'users/${user.uid}/expenses',
        expenseId,
      );
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(FirebaseFailure(
        message: 'Failed to delete expense: ${e.message}',
        code: int.tryParse(e.code),
      ));
    } catch (e) {
      return Left(NetworkFailure(
        message: 'Network error while deleting expense: $e',
      ));
    }
  }

  /// Stream expenses for real-time updates
  Stream<Either<Failure, List<Expense>>> streamExpenses() {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return Stream.value(const Left(AuthenticationFailure(
          message: 'User must be authenticated to stream expenses',
        )));
      }

      return _firestoreService
          .streamCollectionQuery(
            'users/${user.uid}/expenses',
            queryBuilder: (col) => col.orderBy('timestamp', descending: true),
          )
          .map((snapshot) {
            try {
              final expenses = snapshot.docs
                  .map((doc) {
                    try {
                      return Expense.fromMap(doc.data() as Map<String, dynamic>, doc.id);
                    } catch (e) {
                      return null;
                    }
                  })
                  .where((expense) => expense != null)
                  .cast<Expense>()
                  .toList();
              return Right(expenses);
            } catch (e) {
              return Left(NetworkFailure(
                message: 'Error processing expense stream: $e',
              ));
            }
          });
    } catch (e) {
      return Stream.value(Left(NetworkFailure(
        message: 'Failed to create expense stream: $e',
      )));
    }
  }
}