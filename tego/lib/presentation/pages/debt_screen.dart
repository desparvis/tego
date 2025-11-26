import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/debt_bloc.dart';
import '../../domain/entities/debt.dart';
import '../widgets/bottom_navigation_widget.dart';

class DebtScreen extends StatefulWidget {
  const DebtScreen({super.key});

  @override
  State<DebtScreen> createState() => _DebtScreenState();
}

class _DebtScreenState extends State<DebtScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DebtBloc>().add(LoadDebts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debt Management'),
        backgroundColor: const Color(0xFF7430EB),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDebtDialog(context),
          ),
        ],
      ),
      body: BlocConsumer<DebtBloc, DebtState>(
        listener: (context, state) {
          if (state is DebtOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
          } else if (state is DebtError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is DebtLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DebtLoaded) {
            return Column(
              children: [
                // Summary Cards
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Money Owed to You',
                          '${state.totalReceivable.toStringAsFixed(0)} RWF',
                          const Color(0xFF7B4EFF),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          'Money You Owe',
                          '${state.totalPayable.toStringAsFixed(0)} RWF',
                          const Color(0xFF9C7EFF),
                        ),
                      ),
                    ],
                  ),
                ),

                // Debts List
                Expanded(
                  child: state.debts.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('No debts recorded', style: TextStyle(fontSize: 18, color: Colors.grey)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: state.debts.length,
                          itemBuilder: (context, index) {
                            final debt = state.debts[index];
                            return _buildDebtCard(context, debt);
                          },
                        ),
                ),
              ],
            );
          }

          return const Center(child: Text('Something went wrong'));
        },
      ),
      bottomNavigationBar: const BottomNavigationWidget(currentIndex: 0),
    );
  }

  Widget _buildSummaryCard(String title, String amount, Color color) {
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            amount,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDebtCard(BuildContext context, Debt debt) {
    final isReceivable = debt.type == DebtType.receivable;
    final color = isReceivable ? const Color(0xFF7B4EFF) : const Color(0xFF9C7EFF);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: debt.isPaid ? Colors.grey : color,
            child: Icon(
              isReceivable ? Icons.arrow_downward : Icons.arrow_upward,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  debt.customerName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: color,
                    decoration: debt.isPaid ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${debt.amount.toStringAsFixed(0)} RWF',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  debt.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  'Due: ${_formatDate(debt.dueDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          debt.isPaid
              ? Icon(Icons.check_circle, color: color)
              : IconButton(
                  icon: Icon(Icons.check, color: color),
                  onPressed: () => context.read<DebtBloc>().add(MarkDebtPaid(debt.id!)),
                ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddDebtDialog(BuildContext context) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    DebtType selectedType = DebtType.receivable;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 30));

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Debt'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Customer Name'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount (RWF)'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<DebtType>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(value: DebtType.receivable, child: Text('Money Owed to You')),
                    DropdownMenuItem(value: DebtType.payable, child: Text('Money You Owe')),
                  ],
                  onChanged: (value) => setState(() => selectedType = value!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && amountController.text.isNotEmpty) {
                  final debt = Debt(
                    customerName: nameController.text,
                    amount: double.parse(amountController.text),
                    type: selectedType,
                    description: descriptionController.text,
                    dueDate: selectedDate,
                    createdAt: DateTime.now(),
                  );
                  context.read<DebtBloc>().add(AddDebt(debt));
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}