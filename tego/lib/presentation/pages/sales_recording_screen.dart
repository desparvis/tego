import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/app_localizations_helper.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/bottom_navigation_widget.dart';
import '../widgets/custom_snackbar.dart';
import '../../core/navigation/app_router.dart';
import '../bloc/sales_bloc.dart';

class SalesRecordingScreen extends StatefulWidget {
  const SalesRecordingScreen({super.key});

  @override
  State<SalesRecordingScreen> createState() => _SalesRecordingScreenState();
}

class _SalesRecordingScreenState extends State<SalesRecordingScreen> {
  final _amountController = TextEditingController();
  final _itemController = TextEditingController();
  final _dateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Set today's date as default
    _dateController.text = _formatDate(DateTime.now());
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  /// Handles form submission with advanced state management
  void _addSale() {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0.0;
      final date = _dateController.text;
      
      // Dispatch event to BLoC with optimistic UI updates
      context.read<SalesBloc>().add(AddSaleEvent(
        amount: amount,
        date: date,
        item: _itemController.text.trim(),
      ));
      
      // Clear form immediately for better UX (optimistic update)
      _amountController.clear();
      _itemController.clear();
      _dateController.text = _formatDate(DateTime.now());
    }
  }
  
  /// Handles retry functionality for failed operations
  void _retrySale() {
    final currentState = context.read<SalesBloc>().state;
    if (currentState is SalesError && currentState.isRetryable) {
      // Reset state and allow user to retry
      context.read<SalesBloc>().add(ResetSalesStateEvent());
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
    return Scaffold(
        backgroundColor: AppConstants.backgroundWhite,
        body: BlocListener<SalesBloc, SalesState>(
          listener: (context, state) {
            if (state is SalesSuccess) {
              CustomSnackBar.show(
                context,
                message: state.message,
                type: SnackBarType.success,
              );
              AppRouter.pop(context);
            } else if (state is SalesError) {
              CustomSnackBar.show(
                context,
                message: state.error,
                type: SnackBarType.error,
                duration: const Duration(seconds: 5),
                onAction: state.isRetryable ? _retrySale : null,
                actionLabel: state.isRetryable ? 'RETRY' : null,
              );
            }
          },
          child: Column(
            children: [
              // Custom Header
              _buildHeader(),

              // Main Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding,
                    vertical: 20,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _buildFormContent(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const BottomNavigationWidget(currentIndex: 2),
      );
  }

  List<Widget> _buildFormContent(BuildContext context) {
    return [
      // Page Title matching expense screen design
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 24,
        ),
        decoration: BoxDecoration(
          color: AppConstants.primaryPurple,
          borderRadius: BorderRadius.circular(
            AppConstants.cardRadius,
          ),
        ),
        child: Center(
          child: Text(
            AppLocalizationsHelper.of(context).sales,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: AppConstants.fontFamily,
            ),
          ),
        ),
      ),

      // Form Fields matching expense screen layout
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                return 'Please enter sale amount';
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
            'Item Sold',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppConstants.primaryPurple,
              fontFamily: AppConstants.fontFamily,
            ),
          ),
          const SizedBox(height: 8),
          CustomTextField(
            placeholder: 'What was sold?',
            controller: _itemController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter what was sold';
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
                    return 'Please select sale date';
                  }
                  return null;
                },
              ),
            ),
          ),
        ],
      ),

      // Add Sale Button matching expense screen
      BlocBuilder<SalesBloc, SalesState>(
        builder: (context, state) {
          return CustomButton(
            text: AppLocalizationsHelper.of(context).addSale,
            onPressed: state is SalesLoading ? null : _addSale,
            isLoading: state is SalesLoading,
          );
        },
      ),
    ];
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: AppConstants.primaryPurple,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: 16,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => AppRouter.pop(context),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                AppLocalizationsHelper.of(context).sales,
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
    _itemController.dispose();
    _dateController.dispose();
    super.dispose();
  }
}
