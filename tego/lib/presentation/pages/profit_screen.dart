import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/firestore_service.dart';
import '../widgets/bottom_navigation_widget.dart';

class ProfitScreen extends StatelessWidget {
  const ProfitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profit Analysis'),
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
                    return StreamBuilder<QuerySnapshot>(
                      stream: (() {
                        final user = FirebaseAuth.instance.currentUser;
                        return (user == null)
                            ? null
                            : FirestoreService.instance.streamCollection(
                                'users/${user.uid}/inventory',
                                limit: 1000,
                              );
                      })(),
                      builder: (context, inventorySnapshot) {
                        double totalSales = 0.0;
                        double totalExpenses = 0.0;
                        double totalStockCost = 0.0;
                        double totalIntendedProfit = 0.0;

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

                        if (inventorySnapshot.hasData) {
                          for (final doc in inventorySnapshot.data!.docs) {
                            final data = doc.data() as Map<String, dynamic>;
                            final quantity = (data['quantity'] as num?)?.toInt() ?? 0;
                            final stockCost = (data['stockCost'] as num?)?.toDouble() ?? 0.0;
                            final intendedProfit = (data['intendedProfit'] as num?)?.toDouble() ?? 0.0;
                            
                            totalStockCost += (quantity * stockCost);
                            totalIntendedProfit += (quantity * intendedProfit);
                          }
                        }

                        final actualProfit = totalSales - totalExpenses;
                        final profitLoss = actualProfit - totalIntendedProfit;

                        return Column(
                          children: [
                            // Stock Cost
                            _buildProfitCard(
                              'Total Stock Cost',
                              totalStockCost,
                              'Investment in inventory',
                              const Color(0xFF7430EB),
                            ),
                            const SizedBox(height: 16),
                            
                            // Intended vs Actual Profit
                            Row(
                              children: [
                                Expanded(
                                  child: _buildProfitCard(
                                    'Intended Profit',
                                    totalIntendedProfit,
                                    'Expected earnings',
                                    Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildProfitCard(
                                    'Actual Profit',
                                    actualProfit,
                                    'Real earnings',
                                    actualProfit >= 0 ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Profit/Loss Analysis
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: (profitLoss >= 0 ? Colors.green : Colors.red).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: (profitLoss >= 0 ? Colors.green : Colors.red).withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    profitLoss >= 0 ? 'PROFIT' : 'LOSS',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: profitLoss >= 0 ? Colors.green : Colors.red,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${profitLoss.abs().toStringAsFixed(0)} RWF',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: profitLoss >= 0 ? Colors.green : Colors.red,
                                    ),
                                  ),
                                  Text(
                                    profitLoss >= 0 
                                        ? 'Above intended profit'
                                        : 'Below intended profit',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
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

  Widget _buildProfitCard(String title, double amount, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${amount.toStringAsFixed(0)} RWF',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: amount >= 0 ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}