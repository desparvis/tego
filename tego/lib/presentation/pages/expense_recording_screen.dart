import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/expense.dart';
import '../bloc/expense_bloc.dart';
import 'landing_screen.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/app_localizations_helper.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/bottom_navigation_widget.dart';
import '../widgets/custom_snackbar.dart';
import '../../core/navigation/app_router.dart';

class ExpenseRecordingScreen extends StatefulWidget {
  const ExpenseRecordingScreen({super.key});

  @override
  State<ExpenseRecordingScreen> createState() => _ExpenseRecordingScreenState();
}

class _ExpenseRecordingScreenState extends State<ExpenseRecordingScreen> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedCategory = 'Business - Rent';
  final List<String> _categories = [
    'Business - Rent',
    'Business - Utilities', 
    'Business - Supplies',
    'Business - Marketing',
    'Personal - Food',
    'Personal - Transport',
    'Personal - Other',
  ];

  @override
  void initState() {
    super.initState();
    _dateController.text = _formatDate(DateTime.now());
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  void _addExpense() {
    if (_formKey.currentState!.validate()) {
      try {
        final cleanAmount = _amountController.text.replaceAll(',', '').trim();
        final amount = double.parse(cleanAmount);
        
        final expense = Expense(
          amount: amount,
          category: _selectedCategory,
          description: _descriptionController.text.trim(),
          date: _dateController.text,
          timestamp: DateTime.now(),
        );

        context.read<ExpenseBloc>().add(AddExpense(expense));

        // Clear form immediately for better UX (optimistic update)
        _amountController.clear();
        _descriptionController.clear();
        _dateController.text = _formatDate(DateTime.now());
        setState(() {
          _selectedCategory = 'Business - Rent';
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid amount'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppConstants.primaryPurple,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateController.text = _formatDate(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppConstants.backgroundWhite,
        body: BlocListener<ExpenseBloc, ExpenseState>(
          listener: (context, state) {
            if (state is ExpenseSuccess) {
              CustomSnackBar.show(
                context,
                message: state.message,
                type: SnackBarType.success,
              );
              AppRouter.pop(context);
            } else if (state is ExpenseError) {
              CustomSnackBar.show(
                context,
                message: state.message,
                type: SnackBarType.error,
                duration: const Duration(seconds: 5),
              );
            }
          },
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding,
                    vertical: 20,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 24,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7430EB),
                            borderRadius: BorderRadius.circular(
                              AppConstants.cardRadius,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              AppLocalizationsHelper.of(context).expenses,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: AppConstants.fontFamily,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                            Text(
                              AppLocalizationsHelper.of(context).amount,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppConstants.primaryPurple,
                                fontFamily: AppConstants.fontFamily,
                              ),
                            ),
                            const SizedBox(height: 8),
                            CustomTextField(
                              placeholder: 'Enter amount in RWF',
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter expense amount';
                                }
                                final cleanValue = value.replaceAll(',', '').trim();
                                if (double.tryParse(cleanValue) == null) {
                                  return 'Please enter a valid amount';
                                }
                                if (double.parse(cleanValue) <= 0) {
                                  return 'Amount must be greater than 0';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizationsHelper.of(context).category,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppConstants.primaryPurple,
                                fontFamily: AppConstants.fontFamily,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedCategory,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              items: _categories.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value!;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizationsHelper.of(context).description,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppConstants.primaryPurple,
                                fontFamily: AppConstants.fontFamily,
                              ),
                            ),
                            const SizedBox(height: 8),
                            CustomTextField(
                              placeholder: 'Enter description',
                              controller: _descriptionController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter description';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizationsHelper.of(context).date,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppConstants.primaryPurple,
                                fontFamily: AppConstants.fontFamily,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: _selectDate,
                              child: AbsorbPointer(
                                child: CustomTextField(
                                  placeholder: 'Select date',
                                  controller: _dateController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select expense date';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                        const SizedBox(height: 32),
                        BlocBuilder<ExpenseBloc, ExpenseState>(
                          builder: (context, state) {
                            return CustomButton(
                              text: AppLocalizationsHelper.of(context).addExpense,
                              onPressed: state is ExpenseLoading
                                  ? null
                                  : _addExpense,
                              isLoading: state is ExpenseLoading,
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const BottomNavigationWidget(currentIndex: 0),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF7430EB),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: 16,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LandingScreen(),
                    ),
                  );
                },
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                AppLocalizationsHelper.of(context).expenses,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppConstants.fontFamily,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }
}
