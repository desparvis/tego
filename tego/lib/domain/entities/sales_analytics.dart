/// Domain entity representing sales analytics data
/// 
/// This entity encapsulates all sales-related metrics and calculations
/// following clean architecture principles where entities are pure business objects
class SalesAnalytics {
  final int totalSalesCount;
  final double totalRevenue;
  final int todaySalesCount;
  final double todayRevenue;
  final double averageSaleAmount;
  final DateTime lastSaleDate;
  final Map<String, double> monthlyRevenue; // Month -> Revenue mapping
  final double growthPercentage; // Month-over-month growth

  const SalesAnalytics({
    required this.totalSalesCount,
    required this.totalRevenue,
    required this.todaySalesCount,
    required this.todayRevenue,
    required this.averageSaleAmount,
    required this.lastSaleDate,
    required this.monthlyRevenue,
    required this.growthPercentage,
  });

  /// Factory constructor for creating empty analytics
  factory SalesAnalytics.empty() {
    return SalesAnalytics(
      totalSalesCount: 0,
      totalRevenue: 0.0,
      todaySalesCount: 0,
      todayRevenue: 0.0,
      averageSaleAmount: 0.0,
      lastSaleDate: DateTime.now(),
      monthlyRevenue: {},
      growthPercentage: 0.0,
    );
  }

  /// Creates a copy with updated values
  SalesAnalytics copyWith({
    int? totalSalesCount,
    double? totalRevenue,
    int? todaySalesCount,
    double? todayRevenue,
    double? averageSaleAmount,
    DateTime? lastSaleDate,
    Map<String, double>? monthlyRevenue,
    double? growthPercentage,
  }) {
    return SalesAnalytics(
      totalSalesCount: totalSalesCount ?? this.totalSalesCount,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      todaySalesCount: todaySalesCount ?? this.todaySalesCount,
      todayRevenue: todayRevenue ?? this.todayRevenue,
      averageSaleAmount: averageSaleAmount ?? this.averageSaleAmount,
      lastSaleDate: lastSaleDate ?? this.lastSaleDate,
      monthlyRevenue: monthlyRevenue ?? this.monthlyRevenue,
      growthPercentage: growthPercentage ?? this.growthPercentage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SalesAnalytics &&
        other.totalSalesCount == totalSalesCount &&
        other.totalRevenue == totalRevenue &&
        other.todaySalesCount == todaySalesCount &&
        other.todayRevenue == todayRevenue;
  }

  @override
  int get hashCode {
    return totalSalesCount.hashCode ^
        totalRevenue.hashCode ^
        todaySalesCount.hashCode ^
        todayRevenue.hashCode;
  }
}