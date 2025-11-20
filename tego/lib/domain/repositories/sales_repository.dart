import '../entities/sale.dart';

/// Abstract repository interface for sales operations
/// Defines contract without implementation details
abstract class SalesRepository {
  /// Adds a new sale transaction
  Future<void> addSale(Sale sale);
  
  /// Retrieves all sales for current user
  Future<List<Sale>> getSales();
}