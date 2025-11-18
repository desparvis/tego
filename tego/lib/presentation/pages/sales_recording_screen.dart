import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/bottom_navigation_widget.dart';
import '../widgets/responsive_layout.dart';
import '../bloc/sales_bloc.dart';

class SalesRecordingScreen extends StatefulWidget {
  const SalesRecordingScreen({super.key});

  @override
  State<SalesRecordingScreen> createState() => _SalesRecordingScreenState();
}

class _SalesRecordingScreenState extends State<SalesRecordingScreen> {
  final _amountController = TextEditingController();
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

  /// Handles form submission by dispatching event to BLoC
  void _addSale() {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0.0;
      final date = _dateController.text;
      
      // Dispatch event to BLoC - no business logic in UI
      context.read<SalesBloc>().add(AddSaleEvent(
        amount: amount,
        date: date,
      ));
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: BlocListener<SalesBloc, SalesState>(
          listener: (context, state) {
            if (state is SalesSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppConstants.primaryPurple,
                ),
              );
              Navigator.pop(context);
            } else if (state is SalesError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                ),
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
                    child: ResponsiveLayout(
                      mobile: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildFormContent(context),
                      ),
                      tablet: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveLayout.getScreenWidth(context) * 0.1,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _buildFormContent(context),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const BottomNavigationWidget(currentIndex: 2),
      ),
    );
  }

  List<Widget> _buildFormContent(BuildContext context) {
    final isSmallScreen = ResponsiveLayout.isSmallScreen(context);
    final isLargeScreen = ResponsiveLayout.isLargeScreen(context);
    
    return [
      // Page Title - Purple Box
      Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: isSmallScreen ? 16 : (isLargeScreen ? 24 : 20),
          horizontal: isSmallScreen ? 16 : (isLargeScreen ? 32 : 24),
        ),
        decoration: BoxDecoration(
          color: AppConstants.primaryPurple,
          borderRadius: BorderRadius.circular(
            AppConstants.cardRadius,
          ),
        ),
        child: Center(
          child: Text(
            'Sales Recording',
            style: TextStyle(
              fontSize: isSmallScreen ? 20 : (isLargeScreen ? 28 : 24),
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: AppConstants.fontFamily,
            ),
          ),
        ),
      ),

      // Form Fields Section
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sale Amount Field
          Text(
            'Sale Amount',
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : (isLargeScreen ? 18 : 16),
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
              fontFamily: AppConstants.fontFamily,
            ),
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          CustomTextField(
            placeholder: 'Enter amount in RWF',
            controller: _amountController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter sale amount';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid amount';
              }
              return null;
            },
          ),
          SizedBox(height: isSmallScreen ? 16 : (isLargeScreen ? 32 : 24)),
          // Sale Date Field
          Text(
            'Sale Date',
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : (isLargeScreen ? 18 : 16),
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
              fontFamily: AppConstants.fontFamily,
            ),
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
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

      // Add Sale Button with BLoC state handling
      BlocBuilder<SalesBloc, SalesState>(
        builder: (context, state) {
          return CustomButton(
            text: state is SalesLoading ? 'Adding...' : 'Add Sale',
            onPressed: state is SalesLoading ? () {} : _addSale,
            height: isSmallScreen ? 44 : (isLargeScreen ? 52 : 48),
          );
        },
      ),
    ];
  }

  // Custom Header
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
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Sales Recording',
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
    _dateController.dispose();
    super.dispose();
  }
}
