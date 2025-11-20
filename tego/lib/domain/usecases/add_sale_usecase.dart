import '../entities/sale.dart';
import '../repositories/sales_repository.dart';

/// Use case for adding a sale transaction
/// Encapsulates business logic for sale creation
class AddSaleUseCase {
  final SalesRepository _repository;

  const AddSaleUseCase(this._repository);

  /// Executes the add sale operation with business validation
  Future<void> execute(double amount, String date) async {
    // Business validation
    if (amount <= 0) {
      throw ArgumentError('Sale amount must be positive');
    }
    
    if (date.isEmpty) {
      throw ArgumentError('Sale date is required');
    }

    final sale = Sale(
      amount: amount,
      date: date,
      timestamp: DateTime.now(),
    );

    await _repository.addSale(sale);
  }
}