import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/reminders_bloc.dart';
import '../../domain/entities/reminder.dart';
import '../widgets/bottom_navigation_widget.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RemindersBloc>().add(LoadReminders());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        backgroundColor: const Color(0xFF7430EB),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddReminderDialog(context),
          ),
        ],
      ),
      body: BlocConsumer<RemindersBloc, RemindersState>(
        listener: (context, state) {
          if (state is RemindersError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          } else if (state is RemindersOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
          }
        },
        builder: (context, state) {
          if (state is RemindersLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is RemindersLoaded) {
            if (state.reminders.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No reminders yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    SizedBox(height: 8),
                    Text('Tap + to add a reminder', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Summary
                if (state.overdueCount > 0 || state.todayCount > 0)
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: state.overdueCount > 0 ? Colors.red.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: state.overdueCount > 0 ? Colors.red.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          state.overdueCount > 0 ? Icons.warning : Icons.today,
                          color: state.overdueCount > 0 ? Colors.red : Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            state.overdueCount > 0
                                ? '${state.overdueCount} overdue reminders'
                                : '${state.todayCount} reminders due today',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Reminders List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.reminders.length,
                    itemBuilder: (context, index) {
                      final reminder = state.reminders[index];
                      return _buildReminderCard(context, reminder);
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

  Widget _buildReminderCard(BuildContext context, Reminder reminder) {
    Color cardColor = Colors.blue.withOpacity(0.1);
    Color borderColor = Colors.blue.withOpacity(0.3);
    IconData icon = Icons.notifications;

    if (reminder.isOverdue) {
      cardColor = Colors.red.withOpacity(0.1);
      borderColor = Colors.red.withOpacity(0.3);
      icon = Icons.warning;
    } else if (reminder.isDueToday) {
      cardColor = Colors.orange.withOpacity(0.1);
      borderColor = Colors.orange.withOpacity(0.3);
      icon = Icons.today;
    } else if (reminder.isCompleted) {
      cardColor = Colors.green.withOpacity(0.1);
      borderColor = Colors.green.withOpacity(0.3);
      icon = Icons.check_circle;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: ListTile(
          leading: Icon(icon, color: borderColor.withOpacity(0.8)),
          title: Text(
            reminder.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              decoration: reminder.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (reminder.description.isNotEmpty)
                Text(reminder.description),
              const SizedBox(height: 4),
              Text(
                'Due: ${_formatDate(reminder.dueDate)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'complete':
                  context.read<RemindersBloc>().add(CompleteReminder(reminder.id!));
                  break;
                case 'delete':
                  _showDeleteDialog(context, reminder);
                  break;
              }
            },
            itemBuilder: (context) => [
              if (!reminder.isCompleted)
                const PopupMenuItem(value: 'complete', child: Text('Mark Complete')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final reminderDate = DateTime(date.year, date.month, date.day);

    if (reminderDate == today) {
      return 'Today';
    } else if (reminderDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else if (reminderDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showAddReminderDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    ReminderPriority selectedPriority = ReminderPriority.medium;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Reminder'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Due Date'),
                  subtitle: Text(_formatDate(selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        selectedDate = date;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ReminderPriority>(
                  value: selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  items: ReminderPriority.values.map((priority) {
                    return DropdownMenuItem(
                      value: priority,
                      child: Text(priority.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedPriority = value ?? ReminderPriority.medium;
                    });
                  },
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
                if (titleController.text.trim().isNotEmpty) {
                  final reminder = Reminder(
                    title: titleController.text.trim(),
                    description: descriptionController.text.trim(),
                    type: ReminderType.custom,
                    priority: selectedPriority,
                    dueDate: selectedDate,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  context.read<RemindersBloc>().add(AddReminder(reminder));
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

  void _showDeleteDialog(BuildContext context, Reminder reminder) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: Text('Are you sure you want to delete "${reminder.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<RemindersBloc>().add(DeleteReminder(reminder.id!));
              Navigator.pop(dialogContext);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}