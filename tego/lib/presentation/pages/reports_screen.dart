import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/firestore_service.dart';
import '../widgets/bottom_navigation_widget.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Reports'),
        backgroundColor: const Color(0xFF7430EB),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _showShareDialog(context),
          ),
        ],
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
                    return _buildFinancialSummary(context, salesSnapshot, expenseSnapshot);
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

  Widget _buildFinancialSummary(BuildContext context, AsyncSnapshot<QuerySnapshot> salesSnapshot, AsyncSnapshot<QuerySnapshot> expenseSnapshot) {
    final now = DateTime.now();
    final last3Months = _getLast3Months(now);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Credit Evaluation Report',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Financial summary for loan applications',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        
        // Business Overview
        _buildSectionCard(
          'Business Overview',
          [
            _buildReportRow('Business Type', 'Small Retail Business'),
            _buildReportRow('Record Period', '${_formatDate(last3Months.first)} - ${_formatDate(now)}'),
            _buildReportRow('Transaction Count', '${_getTotalTransactions(salesSnapshot, expenseSnapshot)}'),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Monthly Performance
        _buildSectionCard(
          'Monthly Performance',
          last3Months.map((month) {
            final monthSales = _getMonthSales(salesSnapshot, month);
            final monthExpenses = _getMonthExpenses(expenseSnapshot, month);
            final monthProfit = monthSales - monthExpenses;
            
            return _buildReportRow(
              _getMonthName(month),
              'Sales: ${monthSales.toStringAsFixed(0)} RWF\nExpenses: ${monthExpenses.toStringAsFixed(0)} RWF\nProfit: ${monthProfit.toStringAsFixed(0)} RWF',
            );
          }).toList(),
        ),
        
        const SizedBox(height: 16),
        
        // Financial Health
        _buildFinancialHealthCard(salesSnapshot, expenseSnapshot),
        
        const SizedBox(height: 24),
        
        // Export Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showShareDialog(context),
            icon: const Icon(Icons.file_download, color: Colors.white),
            label: const Text('Export Report', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7430EB),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildReportRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: const TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialHealthCard(AsyncSnapshot<QuerySnapshot> salesSnapshot, AsyncSnapshot<QuerySnapshot> expenseSnapshot) {
    double totalSales = 0.0;
    double totalExpenses = 0.0;
    
    if (salesSnapshot.hasData) {
      for (final doc in salesSnapshot.data!.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final amt = (data['amount'] is num)
            ? (data['amount'] as num).toDouble()
            : double.tryParse('${data['amount']}') ?? 0.0;
        totalSales += amt;
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
    
    final profitMargin = totalSales > 0 ? ((totalSales - totalExpenses) / totalSales * 100) : 0.0;
    final creditScore = _calculateCreditScore(totalSales, totalExpenses, profitMargin);
    
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
          const Text('Credit Worthiness Score', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            '$creditScore/100',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: _getScoreColor(creditScore),
            ),
          ),
          Text(
            _getScoreDescription(creditScore),
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text('${profitMargin.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Text('Profit Margin', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              Column(
                children: [
                  Text(totalSales.toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Text('Total Revenue', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<DateTime> _getLast3Months(DateTime now) {
    return List.generate(3, (index) => DateTime(now.year, now.month - (2 - index), 1));
  }

  double _getMonthSales(AsyncSnapshot<QuerySnapshot> snapshot, DateTime month) {
    if (!snapshot.hasData) return 0.0;
    
    double total = 0.0;
    for (final doc in snapshot.data!.docs) {
      final data = doc.data() as Map<String, dynamic>;
      DateTime? ts;
      if (data['timestamp'] != null && data['timestamp'] is Timestamp) {
        ts = (data['timestamp'] as Timestamp).toDate();
      }
      
      if (ts != null && ts.year == month.year && ts.month == month.month) {
        final amt = (data['amount'] is num)
            ? (data['amount'] as num).toDouble()
            : double.tryParse('${data['amount']}') ?? 0.0;
        total += amt;
      }
    }
    return total;
  }

  double _getMonthExpenses(AsyncSnapshot<QuerySnapshot> snapshot, DateTime month) {
    if (!snapshot.hasData) return 0.0;
    
    double total = 0.0;
    for (final doc in snapshot.data!.docs) {
      final data = doc.data() as Map<String, dynamic>;
      DateTime? ts;
      if (data['timestamp'] != null && data['timestamp'] is Timestamp) {
        ts = (data['timestamp'] as Timestamp).toDate();
      }
      
      if (ts != null && ts.year == month.year && ts.month == month.month) {
        final amt = (data['amount'] is num)
            ? (data['amount'] as num).toDouble()
            : double.tryParse('${data['amount']}') ?? 0.0;
        total += amt;
      }
    }
    return total;
  }

  int _getTotalTransactions(AsyncSnapshot<QuerySnapshot> salesSnapshot, AsyncSnapshot<QuerySnapshot> expenseSnapshot) {
    int count = 0;
    if (salesSnapshot.hasData) count += salesSnapshot.data!.docs.length;
    if (expenseSnapshot.hasData) count += expenseSnapshot.data!.docs.length;
    return count;
  }

  int _calculateCreditScore(double sales, double expenses, double profitMargin) {
    int score = 50; // Base score
    
    // Revenue factor
    if (sales > 1000000) {
      score += 20;
    } else if (sales > 500000) {
      score += 15;
    } else if (sales > 100000) {
      score += 10;
    }
    
    // Profit margin factor
    if (profitMargin > 20) {
      score += 20;
    } else if (profitMargin > 10) {
      score += 15;
    } else if (profitMargin > 5) {
      score += 10;
    }
    
    // Consistency factor (simplified)
    score += 10;
    
    return score.clamp(0, 100);
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getScoreDescription(int score) {
    if (score >= 80) {
      return 'Excellent credit worthiness';
    }
    if (score >= 60) {
      return 'Good credit worthiness';
    }
    return 'Fair credit worthiness';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getMonthName(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.year}';
  }

  void _showShareDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Report'),
        content: const Text('This feature will be available soon. You can share your financial report with banks for loan applications.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}