import '../entities/sales_analytics.dart';
import '../repositories/sales_repository.dart';

/// Use case for retrieving sales analytics data
/// 
/// This use case encapsulates the business logic for calculating and retrieving
/// sales analytics. It follows the single responsibility principle and separates
/// business logic from presentation and data layers.
class GetSalesAnalyticsUseCase {
  final SalesRepository _repository;

  const GetSalesAnalyticsUseCase(this._repository);

  /// Executes the use case to get comprehensive sales analytics
  /// 
  /// Returns [SalesAnalytics] with calculated metrics
  /// Throws exception if data retrieval fails
  Future<SalesAnalytics> execute() async {
    try {
      // Fetch all sales data from repository using Either pattern
      final salesResult = await _repository.getSales();
      
      return salesResult.fold(
        (failure) => throw Exception(failure.message), // Convert failure to exception
        (sales) => _calculateAnalytics(sales),
      );
    } catch (e) {
      // Return empty analytics on error to prevent crashes
      return SalesAnalytics.empty();
    }
  }

  /// Calculates analytics from sales data
  /// 
  /// Separated into its own method for better testability and
  /// single responsibility principle
  SalesAnalytics _calculateAnalytics(List<dynamic> sales) {
    if (sales.isEmpty) {
      return SalesAnalytics.empty();
    }

    // Calculate total metrics
    final totalSalesCount = sales.length;
    final totalRevenue = sales.fold<double>(
      0.0, 
      (sum, sale) => sum + sale.amount,
    );

    // Calculate today's metrics
    final today = DateTime.now();
    final todaySales = sales.where((sale) => _isSameDay(sale.timestamp, today));
    final todaySalesCount = todaySales.length;
    final todayRevenue = todaySales.fold<double>(
      0.0, 
      (sum, sale) => sum + sale.amount,
    );

    // Calculate average sale amount
    final averageSaleAmount = totalRevenue / totalSalesCount;

    // Get last sale date
    final sortedSales = List.from(sales)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final lastSaleDate = sortedSales.first.timestamp;

    // Calculate monthly revenue (last 12 months)
    final monthlyRevenue = _calculateMonthlyRevenue(sales);

    // Calculate growth percentage (current month vs previous month)
    final growthPercentage = _calculateGrowthPercentage(monthlyRevenue);

    return SalesAnalytics(
      totalSalesCount: totalSalesCount,
      totalRevenue: totalRevenue,
      todaySalesCount: todaySalesCount,
      todayRevenue: todayRevenue,
      averageSaleAmount: averageSaleAmount,
      lastSaleDate: lastSaleDate,
      monthlyRevenue: monthlyRevenue,
      growthPercentage: growthPercentage,
    );
  }

  /// Helper method to check if two dates are on the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  /// Calculates monthly revenue for the last 12 months
  Map<String, double> _calculateMonthlyRevenue(List<dynamic> sales) {
    final monthlyRevenue = <String, double>{};
    final now = DateTime.now();

    // Initialize last 12 months with 0 revenue
    for (int i = 11; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthKey = '${month.year}-${month.month.toString().padLeft(2, '0')}';
      monthlyRevenue[monthKey] = 0.0;
    }

    // Calculate actual revenue for each month
    for (final sale in sales) {
      final saleDate = sale.timestamp as DateTime;
      final monthKey = '${saleDate.year}-${saleDate.month.toString().padLeft(2, '0')}';
      
      if (monthlyRevenue.containsKey(monthKey)) {
        monthlyRevenue[monthKey] = (monthlyRevenue[monthKey] ?? 0.0) + sale.amount;
      }
    }

    return monthlyRevenue;
  }

  /// Calculates month-over-month growth percentage
  double _calculateGrowthPercentage(Map<String, double> monthlyRevenue) {
    final sortedMonths = monthlyRevenue.keys.toList()..sort();
    
    if (sortedMonths.length < 2) return 0.0;

    final currentMonth = sortedMonths.last;
    final previousMonth = sortedMonths[sortedMonths.length - 2];
    
    final currentRevenue = monthlyRevenue[currentMonth] ?? 0.0;
    final previousRevenue = monthlyRevenue[previousMonth] ?? 0.0;

    if (previousRevenue == 0.0) return 0.0;

    return ((currentRevenue - previousRevenue) / previousRevenue) * 100;
  }
}