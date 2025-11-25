import '../entities/sale.dart';
import '../repositories/sales_repository.dart';
import '../../core/error/failures.dart';
import '../../core/utils/either.dart';

/// Use case for adding a new sale
/// 
/// Encapsulates business logic for sale creation including:
/// - Input validation
/// - Business rule enforcement  
/// - Data transformation
/// - Error handling with Either pattern
class AddSaleUseCase {
  final SalesRepository _repository;

  const AddSaleUseCase(this._repository);

  /// Executes the add sale use case with comprehensive validation
  /// 
  /// Returns [Either<Failure, void>] where:
  /// - Left contains validation or repository failures
  /// - Right indicates successful sale creation
  Future<Either<Failure, void>> execute(double amount, String date, [String item = '']) async {
    // Business rule validation
    final validationResult = _validateSaleData(amount, date, item);
    if (validationResult != null) {
      return Left(validationResult);
    }

    // Create domain entity
    final sale = Sale(
      amount: amount,
      date: date,
      item: item,
      timestamp: DateTime.now(),
    );
    
    // Delegate to repository with error propagation
    return await _repository.addSale(sale);
  }

  /// Validates sale data according to business rules
  /// 
  /// Returns null if valid, ValidationFailure if invalid
  ValidationFailure? _validateSaleData(double amount, String date, String item) {
    final errors = <String, String>{};

    // Validate amount
    if (amount <= 0) {
      errors['amount'] = 'Sale amount must be greater than zero';
    }
    if (amount > 10000000) { // 10M RWF business limit
      errors['amount'] = 'Sale amount exceeds maximum limit';
    }

    // Validate item
    if (item.trim().isEmpty) {
      errors['item'] = 'Item description is required';
    } else if (item.trim().length < 2) {
      errors['item'] = 'Item description must be at least 2 characters';
    }

    // Validate date format and range
    if (date.isEmpty) {
      errors['date'] = 'Sale date is required';
    } else {
      try {
        final parts = date.split('-');
        if (parts.length != 3) {
          errors['date'] = 'Invalid date format. Use DD-MM-YYYY';
        } else {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          final saleDate = DateTime(year, month, day);
          
          // Business rule: No future sales
          if (saleDate.isAfter(DateTime.now())) {
            errors['date'] = 'Sale date cannot be in the future';
          }
          
          // Business rule: No sales older than 1 year
          final oneYearAgo = DateTime.now().subtract(const Duration(days: 365));
          if (saleDate.isBefore(oneYearAgo)) {
            errors['date'] = 'Sale date cannot be older than one year';
          }
        }
      } catch (e) {
        errors['date'] = 'Invalid date format';
      }
    }

    return errors.isEmpty 
        ? null 
        : ValidationFailure(
            message: 'Sale validation failed',
            fieldErrors: errors,
          );
  }
}