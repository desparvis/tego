import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/screen_utils.dart';
import '../widgets/bottom_navigation_widget.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/animated_card.dart';

import '../bloc/expense_bloc.dart';
import '../../domain/entities/expense.dart';

class ExpenseListScreenEnhanced extends StatefulWidget {
  const ExpenseListScreenEnhanced({super.key});

  @override
  State<ExpenseListScreenEnhanced> createState() => _ExpenseListScreenEnhancedState();
}

class _ExpenseListScreenEnhancedState extends State<ExpenseListScreenEnhanced> {
  @override
  void initState() {
    super.initState();
    context.read<ExpenseBloc>().add(StreamExpenses());
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtils.init(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocListener<ExpenseBloc, ExpenseState>(
        listener: (context, state) {
          if (state is ExpenseSuccess) {
            CustomSnackBar.show(
              context,
              message: state.message,
              type: SnackBarType.success,
            );
          } else if (state is ExpenseError) {
            CustomSnackBar.show(
              context,
              message: state.message,
              type: SnackBarType.error,
              duration: const Duration(seconds: 5),
              onAction: state.isRetryable ? () => context.read<ExpenseBloc>().add(LoadExpenses()) : null,
              actionLabel: state.isRetryable ? 'RETRY' : null,
            );
          }
        },
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: BlocBuilder<ExpenseBloc, ExpenseState>(
                builder: (context, state) {
                  if (state is ExpenseLoading) {
                    return _buildLoadingState();
                  } else if (state is ExpenseLoaded) {
                    if (state.expenses.isEmpty) {
                      return _buildEmptyState();
                    }
                    return _buildExpensesList(state.expenses, state.totalAmount);
                  } else if (state is ExpenseError) {
                    return _buildErrorState(state.message, state.isRetryable);
                  }
                  return _buildEmptyState();
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigationWidget(currentIndex: 3),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: Colors.red[400],
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenUtils.w(20),
            vertical: ScreenUtils.h(16),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: ScreenUtils.w(40),
                  height: ScreenUtils.w(40),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(ScreenUtils.w(12)),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: ScreenUtils.w(18),
                  ),
                ),
              ),
              SizedBox(width: ScreenUtils.w(16)),
              Expanded(
                child: Text(
                  'Expense History',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ScreenUtils.sp(20),
                    fontWeight: FontWeight.w600,
                    fontFamily: AppConstants.fontFamily,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Colors.red[400],
            strokeWidth: 3,
          ),
          SizedBox(height: ScreenUtils.h(16)),
          Text(
            'Loading expenses...',
            style: TextStyle(
              fontSize: ScreenUtils.sp(16),
              fontFamily: AppConstants.fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: ScreenUtils.w(80),
            height: ScreenUtils.w(80),
            decoration: BoxDecoration(
              color: Colors.red[400]!.withOpacity(0.08),
              borderRadius: BorderRadius.circular(ScreenUtils.w(40)),
            ),
            child: Icon(
              Icons.receipt_outlined,
              size: ScreenUtils.w(40),
              color: Colors.red[400],
            ),
          ),
          SizedBox(height: ScreenUtils.h(20)),
          Text(
            'No expenses recorded',
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
              'Start recording your expenses to see them here',
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

  Widget _buildExpensesList(List<Expense> expenses, double totalAmount) {
    return Column(
      children: [
        // Total Amount Card
        Container(
          margin: EdgeInsets.all(ScreenUtils.w(20)),
          child: AnimatedCard(
            color: Colors.red[400],
            padding: EdgeInsets.all(ScreenUtils.w(20)),
            child: Row(
              children: [
                Container(
                  width: ScreenUtils.w(48),
                  height: ScreenUtils.w(48),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(ScreenUtils.w(12)),
                  ),
                  child: Icon(
                    Icons.trending_down,
                    color: Colors.white,
                    size: ScreenUtils.w(24),
                  ),
                ),
                SizedBox(width: ScreenUtils.w(16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Expenses',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: ScreenUtils.sp(14),
                          fontFamily: AppConstants.fontFamily,
                        ),
                      ),
                      SizedBox(height: ScreenUtils.h(4)),
                      Text(
                        '${totalAmount.toStringAsFixed(0)} RWF',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ScreenUtils.sp(24),
                          fontWeight: FontWeight.bold,
                          fontFamily: AppConstants.fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Expenses List
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: ScreenUtils.w(20)),
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              return _buildExpenseItem(expense, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseItem(Expense expense, int index) {
    final isToday = _isToday(expense.timestamp);
    
    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtils.h(12)),
      child: AnimatedCard(
        padding: EdgeInsets.all(ScreenUtils.w(16)),
        color: isToday 
            ? Colors.red[50]
            : Theme.of(context).cardColor,
        child: Row(
          children: [
            // Category Icon
            Container(
              width: ScreenUtils.w(44),
              height: ScreenUtils.w(44),
              decoration: BoxDecoration(
                color: Colors.red[400]!.withOpacity(0.1),
                borderRadius: BorderRadius.circular(ScreenUtils.w(12)),
              ),
              child: Icon(
                _getCategoryIcon(expense.category),
                color: Colors.red[400],
                size: ScreenUtils.w(20),
              ),
            ),
            SizedBox(width: ScreenUtils.w(12)),
            
            // Expense Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        expense.category,
                        style: TextStyle(
                          fontSize: ScreenUtils.sp(16),
                          fontWeight: FontWeight.w600,
                          fontFamily: AppConstants.fontFamily,
                        ),
                      ),
                      Text(
                        '${expense.amount.toStringAsFixed(0)} RWF',
                        style: TextStyle(
                          fontSize: ScreenUtils.sp(16),
                          fontWeight: FontWeight.w600,
                          color: Colors.red[400],
                          fontFamily: AppConstants.fontFamily,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ScreenUtils.h(4)),
                  Text(
                    expense.description,
                    style: TextStyle(
                      fontSize: ScreenUtils.sp(14),
                      color: Colors.grey[600],
                      fontFamily: AppConstants.fontFamily,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: ScreenUtils.h(4)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        expense.date,
                        style: TextStyle(
                          fontSize: ScreenUtils.sp(12),
                          color: Colors.grey[500],
                          fontFamily: AppConstants.fontFamily,
                        ),
                      ),
                      if (isToday)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ScreenUtils.w(8),
                            vertical: ScreenUtils.h(2),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[400]!.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(ScreenUtils.w(8)),
                          ),
                          child: Text(
                            'Today',
                            style: TextStyle(
                              fontSize: ScreenUtils.sp(10),
                              color: Colors.red[400],
                              fontWeight: FontWeight.w500,
                              fontFamily: AppConstants.fontFamily,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Delete Button
            GestureDetector(
              onTap: () => _showDeleteDialog(expense),
              child: Container(
                width: ScreenUtils.w(32),
                height: ScreenUtils.w(32),
                decoration: BoxDecoration(
                  color: Colors.red[400]!.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(ScreenUtils.w(8)),
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.red[400],
                  size: ScreenUtils.w(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message, bool isRetryable) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: ScreenUtils.w(64),
            color: Colors.red[400]!.withOpacity(0.5),
          ),
          SizedBox(height: ScreenUtils.h(16)),
          Text(
            'Error loading expenses',
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
              onPressed: () => context.read<ExpenseBloc>().add(LoadExpenses()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }

  void _showDeleteDialog(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: Text('Are you sure you want to delete this ${expense.category.toLowerCase()} expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ExpenseBloc>().add(DeleteExpense(expense.id!));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red[400]),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'rent':
        return Icons.home_outlined;
      case 'utilities':
        return Icons.electrical_services_outlined;
      case 'supplies':
        return Icons.inventory_2_outlined;
      case 'transport':
        return Icons.directions_car_outlined;
      case 'marketing':
        return Icons.campaign_outlined;
      case 'food':
        return Icons.restaurant_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}