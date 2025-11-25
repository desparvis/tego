import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/firestore_service.dart';
import '../widgets/bottom_navigation_widget.dart';

class CashFlowScreen extends StatelessWidget {
  const CashFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash Flow'),
        backgroundColor: const Color(0xFF7430EB),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: (() {
                final user = FirebaseAuth.instance.currentUser;
                return (user == null)
                    ? null
                    : FirestoreService.instance.streamCollection(
                        'users/${user.uid}/sales',
                        limit: 1000,
                      );
              })(),
              builder: (context, salesSnapshot) {
                return StreamBuilder<QuerySnapshot>(
                  stream: (() {
                    final user = FirebaseAuth.instance.currentUser;
                    return (user == null)
                        ? null
                        : FirestoreService.instance.streamCollection(
                            'users/${user.uid}/expenses',
                            limit: 1000,
                          );
                  })(),
                  builder: (context, expenseSnapshot) {
                    final now = DateTime.now();
                    final last7Days = _getLast7Days(now);
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Weekly Cash Flow',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        
                        ...last7Days.map((date) {
                          final dayIncome = _getDayIncome(salesSnapshot, date);
                          final dayExpenses = _getDayExpenses(expenseSnapshot, date);
                          final netFlow = dayIncome - dayExpenses;
                          
                          return _buildDayCard(date, dayIncome, dayExpenses, netFlow);
                        }),
                        
                        const SizedBox(height: 24),
                        _buildSummaryCard(salesSnapshot, expenseSnapshot),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigationWidget(currentIndex: 0),
    );
  }

  List<DateTime> _getLast7Days(DateTime now) {
    return List.generate(7, (index) => now.subtract(Duration(days: 6 - index)));
  }

  double _getDayIncome(AsyncSnapshot<QuerySnapshot> snapshot, DateTime date) {
    if (!snapshot.hasData) return 0.0;
    
    double total = 0.0;
    for (final doc in snapshot.data!.docs) {
      final data = doc.data() as Map<String, dynamic>;
      DateTime? ts;
      if (data['timestamp'] != null && data['timestamp'] is Timestamp) {
        ts = (data['timestamp'] as Timestamp).toDate();
      }
      
      if (ts != null && _isSameDay(ts, date)) {
        final amt = (data['amount'] is num)
            ? (data['amount'] as num).toDouble()
            : double.tryParse('${data['amount']}') ?? 0.0;
        total += amt;
      }
    }
    return total;
  }

  double _getDayExpenses(AsyncSnapshot<QuerySnapshot> snapshot, DateTime date) {
    if (!snapshot.hasData) return 0.0;
    
    double total = 0.0;
    for (final doc in snapshot.data!.docs) {
      final data = doc.data() as Map<String, dynamic>;
      DateTime? ts;
      if (data['timestamp'] != null && data['timestamp'] is Timestamp) {
        ts = (data['timestamp'] as Timestamp).toDate();
      }
      
      if (ts != null && _isSameDay(ts, date)) {
        final amt = (data['amount'] is num)
            ? (data['amount'] as num).toDouble()
            : double.tryParse('${data['amount']}') ?? 0.0;
        total += amt;
      }
    }
    return total;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }

  Widget _buildDayCard(DateTime date, double income, double expenses, double netFlow) {
    final dayName = _getDayName(date.weekday);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('${date.day}/${date.month}', style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            Expanded(
              child: Text(
                income.toStringAsFixed(0),
                style: const TextStyle(color: Colors.green, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Text(
                expenses.toStringAsFixed(0),
                style: const TextStyle(color: Colors.red, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Text(
                netFlow.toStringAsFixed(0),
                style: TextStyle(
                  color: netFlow >= 0 ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(AsyncSnapshot<QuerySnapshot> salesSnapshot, AsyncSnapshot<QuerySnapshot> expenseSnapshot) {
    double totalIncome = 0.0;
    double totalExpenses = 0.0;

    if (salesSnapshot.hasData) {
      for (final doc in salesSnapshot.data!.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final amt = (data['amount'] is num)
            ? (data['amount'] as num).toDouble()
            : double.tryParse('${data['amount']}') ?? 0.0;
        totalIncome += amt;
      }
    }

    if (expenseSnapshot.hasData) {
      for (final doc in expenseSnapshot.data!.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final amt = (data['amount'] is num)
            ? (data['amount'] as num).toDouble()
            : double.tryParse('${data['amount']}') ?? 0.0;
        totalExpenses += amt;
      }
    }

    final netCashFlow = totalIncome - totalExpenses;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF7430EB).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF7430EB).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Text('Net Cash Flow', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            '${netCashFlow.toStringAsFixed(0)} RWF',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: netCashFlow >= 0 ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            netCashFlow >= 0 ? 'Positive cash flow' : 'Negative cash flow',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }
}