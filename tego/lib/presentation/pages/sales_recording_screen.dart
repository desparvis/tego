import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/app_localizations_helper.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/bottom_navigation_widget.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/animated_card.dart';

import '../../core/utils/responsive_layout.dart';
import '../../core/utils/screen_utils.dart';
import '../../core/navigation/app_router.dart';
import '../widgets/bloc_status_indicator.dart';
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
    ScreenUtils.init(context);
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
      );
  }

  List<Widget> _buildFormContent(BuildContext context) {
    final isSmallScreen = ResponsiveLayout.isSmallScreen(context);
    final isLargeScreen = ResponsiveLayout.isLargeScreen(context);
    
    return [
      // Enhanced Page Title with Animation
      AnimatedCard(
        color: AppConstants.primaryPurple,
        padding: EdgeInsets.symmetric(
          vertical: isSmallScreen ? 20 : (isLargeScreen ? 28 : 24),
          horizontal: isSmallScreen ? 20 : (isLargeScreen ? 32 : 28),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.point_of_sale,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              AppLocalizationsHelper.of(context).sales,
              style: TextStyle(
                fontSize: ResponsiveLayout.getResponsiveFontSize(context, 24),
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: AppConstants.fontFamily,
              ),
            ),
          ],
        ),
      ),

      // Pixel-perfect Form Fields
      AnimatedCard(
        padding: EdgeInsets.all(ScreenUtils.w(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sale Amount Field
            Row(
              children: [
                Container(
                  width: ScreenUtils.w(32),
                  height: ScreenUtils.w(32),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(ScreenUtils.w(8)),
                  ),
                  child: Icon(
                    Icons.monetization_on_outlined,
                    color: AppConstants.primaryPurple,
                    size: ScreenUtils.w(18),
                  ),
                ),
                SizedBox(width: ScreenUtils.w(12)),
                Text(
                  AppLocalizationsHelper.of(context).amount,
                  style: TextStyle(
                    fontSize: ScreenUtils.sp(16),
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontFamily: AppConstants.fontFamily,
                  ),
                ),
              ],
            ),
            SizedBox(height: ScreenUtils.h(12)),
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
            SizedBox(height: ScreenUtils.h(24)),
            
            // Item Sold Field
            Row(
              children: [
                Container(
                  width: ScreenUtils.w(32),
                  height: ScreenUtils.w(32),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(ScreenUtils.w(8)),
                  ),
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    color: AppConstants.primaryPurple,
                    size: ScreenUtils.w(18),
                  ),
                ),
                SizedBox(width: ScreenUtils.w(12)),
                Text(
                  'Item Sold',
                  style: TextStyle(
                    fontSize: ScreenUtils.sp(16),
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontFamily: AppConstants.fontFamily,
                  ),
                ),
              ],
            ),
            SizedBox(height: ScreenUtils.h(12)),
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
            SizedBox(height: ScreenUtils.h(24)),
            
            // Sale Date Field
            Row(
              children: [
                Container(
                  width: ScreenUtils.w(32),
                  height: ScreenUtils.w(32),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(ScreenUtils.w(8)),
                  ),
                  child: Icon(
                    Icons.calendar_today_outlined,
                    color: AppConstants.primaryPurple,
                    size: ScreenUtils.w(18),
                  ),
                ),
                SizedBox(width: ScreenUtils.w(12)),
                Text(
                  AppLocalizationsHelper.of(context).date,
                  style: TextStyle(
                    fontSize: ScreenUtils.sp(16),
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontFamily: AppConstants.fontFamily,
                  ),
                ),
              ],
            ),
            SizedBox(height: ScreenUtils.h(12)),
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
      ),

      // Enhanced Add Sale Button with BLoC state handling
      BlocBuilder<SalesBloc, SalesState>(
        builder: (context, state) {
          return CustomButton(
            text: AppLocalizationsHelper.of(context).addSale,
            icon: Icons.add_circle,
            onPressed: state is SalesLoading ? null : _addSale,
            isLoading: state is SalesLoading,
            height: AppConstants.minTapTarget,
            semanticLabel: 'Add new sale record',
          );
        },
      ),
    ];
  }

  // Pixel-perfect Custom Header
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: AppConstants.primaryPurple,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenUtils.w(20),
            vertical: ScreenUtils.h(16),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => AppRouter.pop(context),
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
                  AppLocalizationsHelper.of(context).sales,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ScreenUtils.sp(20),
                    fontWeight: FontWeight.w600,
                    fontFamily: AppConstants.fontFamily,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const BlocStatusIndicator(),
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
