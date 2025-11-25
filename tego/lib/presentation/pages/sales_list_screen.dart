import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/bottom_navigation_widget.dart';
import '../widgets/animated_card.dart';
import '../widgets/optimized_list_view.dart';
import '../bloc/sales_list_bloc.dart';
import '../../core/utils/responsive_layout.dart';
import '../../core/utils/screen_utils.dart';
import '../../core/constants/app_constants.dart';

/// Sales List Screen with advanced BLoC state management
/// 
/// This screen demonstrates exemplary clean architecture implementation:
/// - Separation of presentation logic from business logic
/// - BLoC pattern for predictable state management
/// - Real-time data updates with proper error handling
/// - Responsive design with pixel-perfect implementation
class SalesListScreen extends StatefulWidget {
  const SalesListScreen({super.key});

  @override
  State<SalesListScreen> createState() => _SalesListScreenState();
}

class _SalesListScreenState extends State<SalesListScreen> {

  /// Helper method to check if a date is today
  /// 
  /// Extracted as a pure function for better testability
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  @override
  void initState() {
    super.initState();
    // Initialize sales list when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SalesListBloc>().add(const LoadSalesListEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtils.init(context);
    
    return Scaffold(
      // Pixel-perfect App Bar matching Figma
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(ScreenUtils.h(70)),
        child: AppBar(
          automaticallyImplyLeading: false,
          title: Padding(
            padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(8)),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.15),
                  radius: ScreenUtils.w(20),
                  child: Text(
                    (FirebaseAuth.instance.currentUser?.displayName ?? 'U')
                        .substring(0, 1)
                        .toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: ScreenUtils.sp(16),
                      fontFamily: AppConstants.fontFamily,
                    ),
                  ),
                ),
                SizedBox(width: ScreenUtils.w(12)),
                Expanded(
                  child: Text(
                    FirebaseAuth.instance.currentUser?.displayName ?? 'User',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: ScreenUtils.sp(18),
                      color: Colors.white,
                      fontFamily: AppConstants.fontFamily,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(right: ScreenUtils.w(16)),
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtils.w(12),
                vertical: ScreenUtils.h(6),
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(ScreenUtils.w(20)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time,
                    size: ScreenUtils.w(16),
                    color: Colors.white,
                  ),
                  SizedBox(width: ScreenUtils.w(6)),
                  Text(
                    '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: ScreenUtils.sp(14),
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      fontFamily: AppConstants.fontFamily,
                    ),
                  ),
                ],
              ),
            ),
          ],
          backgroundColor: AppConstants.primaryPurple,
          elevation: 0,
        ),
      ),

      // Main Body
      body: Column(
        children: [
          // Pixel-perfect header matching Figma design
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              ScreenUtils.w(20),
              ScreenUtils.h(24),
              ScreenUtils.w(20),
              ScreenUtils.h(28),
            ),
            decoration: BoxDecoration(
              color: AppConstants.primaryPurple,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(ScreenUtils.w(24)),
                bottomRight: Radius.circular(ScreenUtils.w(24)),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppConstants.primaryPurple.withOpacity(0.25),
                  blurRadius: ScreenUtils.w(12),
                  offset: Offset(0, ScreenUtils.h(4)),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: ScreenUtils.w(32),
                      height: ScreenUtils.w(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(ScreenUtils.w(8)),
                      ),
                      child: Icon(
                        Icons.receipt_long,
                        color: Colors.white,
                        size: ScreenUtils.w(20),
                      ),
                    ),
                    SizedBox(width: ScreenUtils.w(12)),
                    Text(
                      'Sales List',
                      style: TextStyle(
                        fontSize: ScreenUtils.sp(24),
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontFamily: AppConstants.fontFamily,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ScreenUtils.h(8)),
                BlocBuilder<SalesListBloc, SalesListState>(
                  builder: (context, state) {
                    return state.when(
                      initial: () => Text(
                        'Loading sales...',
                        style: TextStyle(
                          fontSize: ScreenUtils.sp(14),
                          color: Colors.white.withOpacity(0.75),
                          fontFamily: AppConstants.fontFamily,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      loading: () => Text(
                        'Loading sales...',
                        style: TextStyle(
                          fontSize: ScreenUtils.sp(14),
                          color: Colors.white.withOpacity(0.75),
                          fontFamily: AppConstants.fontFamily,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      loaded: (sales, analytics, hasMore, isLoadingMore) => Text(
                        '${sales.length} sales recorded',
                        style: TextStyle(
                          fontSize: ScreenUtils.sp(14),
                          color: Colors.white.withOpacity(0.75),
                          fontFamily: AppConstants.fontFamily,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      error: (message, isRetryable) => Text(
                        'Error loading sales',
                        style: TextStyle(
                          fontSize: ScreenUtils.sp(14),
                          color: Colors.white.withOpacity(0.75),
                          fontFamily: AppConstants.fontFamily,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Enhanced table header
          Container(
            padding: ResponsiveLayout.getResponsivePadding(context),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.grey[50],
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Icon(
                        Icons.monetization_on,
                        size: 18,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Amount',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: ResponsiveLayout.getResponsiveFontSize(context, 16),
                          fontFamily: AppConstants.fontFamily,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.date_range,
                        size: 18,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Date',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: ResponsiveLayout.getResponsiveFontSize(context, 16),
                          fontFamily: AppConstants.fontFamily,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // BLoC-managed sales list with comprehensive state handling
          Expanded(
            child: BlocBuilder<SalesListBloc, SalesListState>(
              builder: (context, state) {
                return state.when(
                  initial: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  loaded: (sales, analytics, hasMore, isLoadingMore) {
                    if (sales.isEmpty) {
                      return _buildEmptyState();
                    }
                    return _buildSalesList(sales, hasMore, isLoadingMore, context);
                  },
                  error: (message, isRetryable) => _buildErrorState(
                    message, 
                    isRetryable, 
                    context,
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // Bottom Navigation
      bottomNavigationBar: const BottomNavigationWidget(currentIndex: 1),
    );
  }

  /// Builds the empty state when no sales are available
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: ScreenUtils.w(80),
            height: ScreenUtils.w(80),
            decoration: BoxDecoration(
              color: AppConstants.primaryPurple.withOpacity(0.08),
              borderRadius: BorderRadius.circular(ScreenUtils.w(40)),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: ScreenUtils.w(40),
              color: AppConstants.primaryPurple,
            ),
          ),
          SizedBox(height: ScreenUtils.h(20)),
          Text(
            'No sales recorded',
            style: TextStyle(
              fontSize: ScreenUtils.sp(18),
              fontWeight: FontWeight.w600,
              fontFamily: AppConstants.fontFamily,
            ),
          ),
          SizedBox(height: ScreenUtils.h(8)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(40)),
            child: Text(
              'Start recording your sales to see them here',
              style: TextStyle(
                fontSize: ScreenUtils.sp(14),
                fontFamily: AppConstants.fontFamily,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds optimized sales list with performance enhancements
  Widget _buildSalesList(
    List<DocumentSnapshot> sales,
    bool hasMore,
    bool isLoadingMore,
    BuildContext context,
  ) {
    return OptimizedListView(
      items: sales,
      hasMore: hasMore,
      isLoading: isLoadingMore,
      padding: EdgeInsets.only(
        top: ScreenUtils.h(16),
        bottom: ScreenUtils.h(20),
      ),
      onLoadMore: () => context.read<SalesListBloc>().add(
        const LoadMoreSalesEvent(),
      ),
      itemBuilder: (context, doc, index) {
        final data = doc.data() as Map<String, dynamic>;
        final amount = data['amount']?.toString() ?? '';
        final date = data['date']?.toString() ?? '';
        final item = data['item']?.toString() ?? 'Item not specified';
        final timestamp = data['timestamp'] as Timestamp?;
        final isToday = timestamp != null && _isToday(timestamp.toDate());
        
        return Container(
          margin: EdgeInsets.only(
            left: ScreenUtils.w(20),
            right: ScreenUtils.w(20),
            bottom: ScreenUtils.h(12),
          ),
          child: AnimatedCard(
            padding: EdgeInsets.all(ScreenUtils.w(16)),
            color: isToday 
                ? AppConstants.accentPink.withOpacity(0.8)
                : Theme.of(context).cardColor,
            child: Row(
              children: [
                // Amount section with icon
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Container(
                        width: ScreenUtils.w(44),
                        height: ScreenUtils.w(44),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(ScreenUtils.w(12)),
                        ),
                        child: Icon(
                          Icons.monetization_on_outlined,
                          color: AppConstants.primaryPurple,
                          size: ScreenUtils.w(24),
                        ),
                      ),
                      SizedBox(width: ScreenUtils.w(12)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$amount RWF',
                              style: TextStyle(
                                fontSize: ScreenUtils.sp(16),
                                fontWeight: FontWeight.w600,
                                fontFamily: AppConstants.fontFamily,
                                letterSpacing: -0.2,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: ScreenUtils.h(2)),
                            Text(
                              item,
                              style: TextStyle(
                                fontSize: ScreenUtils.sp(12),
                                color: Colors.grey[600],
                                fontFamily: AppConstants.fontFamily,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (isToday) ...[
                              SizedBox(height: ScreenUtils.h(2)),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: ScreenUtils.w(8),
                                  vertical: ScreenUtils.h(2),
                                ),
                                decoration: BoxDecoration(
                                  color: AppConstants.primaryPurple.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(ScreenUtils.w(8)),
                                ),
                                child: Text(
                                  'Today',
                                  style: TextStyle(
                                    fontSize: ScreenUtils.sp(10),
                                    color: AppConstants.primaryPurple,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: AppConstants.fontFamily,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Date section
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: ScreenUtils.w(16),
                      ),
                      SizedBox(width: ScreenUtils.w(6)),
                      Flexible(
                        child: Text(
                          date,
                          style: TextStyle(
                            fontSize: ScreenUtils.sp(14),
                            fontFamily: AppConstants.fontFamily,
                            fontWeight: FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds error state with retry functionality
  Widget _buildErrorState(
    String message,
    bool isRetryable,
    BuildContext context,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: ScreenUtils.w(64),
            color: AppConstants.primaryPurple.withOpacity(0.5),
          ),
          SizedBox(height: ScreenUtils.h(16)),
          Text(
            'Error loading sales',
            style: TextStyle(
              fontSize: ScreenUtils.sp(18),
              fontWeight: FontWeight.w600,
              fontFamily: AppConstants.fontFamily,
            ),
          ),
          SizedBox(height: ScreenUtils.h(8)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(40)),
            child: Text(
              message,
              style: TextStyle(
                fontSize: ScreenUtils.sp(14),
                fontFamily: AppConstants.fontFamily,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (isRetryable) ...[
            SizedBox(height: ScreenUtils.h(24)),
            ElevatedButton(
              onPressed: () => context.read<SalesListBloc>().add(
                const LoadSalesListEvent(),
              ),
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}
