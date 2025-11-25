import '../entities/sale.dart';
import '../../core/error/failures.dart';
import '../../core/utils/either.dart';

/// Abstract repository interface for sales data operations
/// 
/// This interface defines the contract for sales data access following
/// clean architecture principles. It uses Either<Failure, T> for explicit
/// error handling without exceptions, making the API more predictable.
abstract class SalesRepository {
  /// Adds a new sale to the repository
  /// 
  /// Returns [Either<Failure, void>] where:
  /// - Left contains a [Failure] if the operation fails
  /// - Right contains void if the operation succeeds
  Future<Either<Failure, void>> addSale(Sale sale);
  
  /// Retrieves all sales from the repository
  /// 
  /// Returns [Either<Failure, List<Sale>>] where:
  /// - Left contains a [Failure] if the operation fails  
  /// - Right contains the list of sales if successful
  Future<Either<Failure, List<Sale>>> getSales();
}