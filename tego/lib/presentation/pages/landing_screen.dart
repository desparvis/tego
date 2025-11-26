import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'expense_recording_screen.dart';
import 'cash_flow_screen.dart';
import 'reports_screen.dart';
import 'reminders_screen.dart';
import 'debt_screen.dart';
import '../../core/services/firestore_service.dart';
import 'sign_in_screen.dart';
import 'expense_list_screen.dart';
import 'inventory_screen.dart';
import 'profit_screen.dart';
import '../../core/utils/preferences_service.dart';
import '../../core/utils/app_localizations_helper.dart';
import '../../core/utils/responsive_helper.dart';
import '../widgets/bottom_navigation_widget.dart';
import '../widgets/floating_action_menu.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  String _username = 'Username';
  String _timeString = '';
  Timer? _timeTimer;
  late AnimationController _animationController;
  late List<Animation<double>> _cardAnimations;

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _updateTime();
    _timeTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _updateTime(),
    );
    
    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Create staggered animations for cards
    _cardAnimations = List.generate(6, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.1,
            0.6 + (index * 0.1),
            curve: Curves.easeOutBack,
          ),
        ),
      );
    });
    
    _animationController.forward();
  }

  void _loadUsername() {
    final firebaseName = FirebaseAuth.instance.currentUser?.displayName;
    final stored = PreferencesService.getUsername();
    setState(() {
      _username = (firebaseName != null && firebaseName.isNotEmpty)
          ? firebaseName
          : (stored.isNotEmpty ? stored : 'User');
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    if (mounted) {
      setState(() {
        _timeString = '$hh:$mm';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white24,
              child: Text(
                _getInitials(_username),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _username,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  AppLocalizationsHelper.of(context).welcomeBack,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _signOut();
            },
            tooltip: 'Sign out',
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _timeString,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
        backgroundColor: const Color(0xFF7430EB),
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SingleChildScrollView(
            padding: ResponsiveHelper.getResponsiveMargin(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Message
              FadeTransition(
                opacity: _cardAnimations[0],
                child: Text(
                  'Welcome back, $_username!',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 24),
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Here's your dashboard for today",
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 14),

              // Sales Section
              _buildSectionTitle(AppLocalizationsHelper.of(context).sales),
              const SizedBox(height: 12),
              
              FadeTransition(
                opacity: _cardAnimations[1],
                child: _buildSalesCard(),
              ),
              const SizedBox(height: 28),

              // Expenses & Inventory Row
              FadeTransition(
                opacity: _cardAnimations[2],
                child: _buildExpensesInventoryRow(),
              ),
              const SizedBox(height: 28),

              // Profit Card
              FadeTransition(
                opacity: _cardAnimations[3],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(AppLocalizationsHelper.of(context).profit),
                    const SizedBox(height: 12),
                    _buildProfitCard(),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Quick Access Section
              FadeTransition(
                opacity: _cardAnimations[4],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(AppLocalizationsHelper.of(context).quickAccess),
                    const SizedBox(height: 12),
                    _buildQuickAccessGrid(),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      ),
      bottomNavigationBar: const BottomNavigationWidget(currentIndex: 0),
      floatingActionButton: const FloatingActionMenu(),
    );
  }

  Widget _buildSalesCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: (() {
        final user = FirebaseAuth.instance.currentUser;
        return (user == null)
            ? null
            : FirestoreService.instance.streamCollection(
                'users/${user.uid}/sales',
                limit: 1000,
              );
      })(),
      builder: (context, snapshot) {
        int totalCount = 0;
        int todayCount = 0;
        double totalAmount = 0.0;

        if (snapshot.hasData) {
          final docs = snapshot.data!.docs;
          totalCount = docs.length;
          final now = DateTime.now();
          for (final doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final amt = (data['amount'] is num)
                ? (data['amount'] as num).toDouble()
                : double.tryParse('${data['amount']}') ?? 0.0;
            totalAmount += amt;

            DateTime? ts;
            if (data['timestamp'] != null && data['timestamp'] is Timestamp) {
              ts = (data['timestamp'] as Timestamp).toDate();
            }
            if (ts != null &&
                ts.year == now.year &&
                ts.month == now.month &&
                ts.day == now.day) {
              todayCount += 1;
            }
          }
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF7430EB),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7430EB).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                '$totalCount',
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '+$todayCount made today',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Total: ${totalAmount.toStringAsFixed(0)} RWF',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExpensesInventoryRow() {
    return Row(
      children: [
        Expanded(child: _buildExpenseCard()),
        const SizedBox(width: 16),
        Expanded(child: _buildInventoryCard()),
      ],
    );
  }

  Widget _buildExpenseCard() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ExpenseListScreen()),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: (() {
          final user = FirebaseAuth.instance.currentUser;
          return (user == null)
              ? null
              : FirestoreService.instance.streamCollection(
                  'users/${user.uid}/expenses',
                  limit: 1000,
                );
        })(),
        builder: (context, snapshot) {
          double todayExpenses = 0.0;
          if (snapshot.hasData) {
            final now = DateTime.now();
            for (final doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              DateTime? ts;
              if (data['timestamp'] != null && data['timestamp'] is Timestamp) {
                ts = (data['timestamp'] as Timestamp).toDate();
              }
              if (ts != null && ts.year == now.year && ts.month == now.month && ts.day == now.day) {
                final amt = (data['amount'] is num)
                    ? (data['amount'] as num).toDouble()
                    : double.tryParse('${data['amount']}') ?? 0.0;
                todayExpenses += amt;
              }
            }
          }
          return _buildStatCard(
            title: AppLocalizationsHelper.of(context).todaysExpenses,
            value: '${todayExpenses.toStringAsFixed(0)} RWF',
            color: Colors.white,
            icon: Icons.trending_down,
          );
        },
      ),
    );
  }

  Widget _buildInventoryCard() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const InventoryScreen()),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: (() {
          final user = FirebaseAuth.instance.currentUser;
          return (user == null)
              ? null
              : FirestoreService.instance.streamCollection(
                  'users/${user.uid}/inventory',
                  limit: 1000,
                );
        })(),
        builder: (context, snapshot) {
          int totalItems = 0;
          int lowStockItems = 0;
          if (snapshot.hasData) {
            totalItems = snapshot.data!.docs.length;
            for (final doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              final quantity = (data['quantity'] as num?)?.toInt() ?? 0;
              final minStock = (data['minStockLevel'] as num?)?.toInt() ?? 5;
              if (quantity <= minStock) lowStockItems++;
            }
          }
          return _buildStatCard(
            title: AppLocalizationsHelper.of(context).inventoryItems,
            value: '$totalItems items',
            color: const Color(0xFF9C7EFF),
            icon: Icons.inventory,
            subtitle: lowStockItems > 0 
                ? '$lowStockItems ${AppLocalizationsHelper.of(context).lowStock}' 
                : AppLocalizationsHelper.of(context).allGood,
          );
        },
      ),
    );
  }

  Widget _buildProfitCard() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfitScreen()),
      ),
      child: _buildLargeCard(
        color: Colors.white,
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                '0 RWF', // Simplified for now
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7B4EFF),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF7B4EFF),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildQuickAccessCard(
                AppLocalizationsHelper.of(context).inventory,
                AppLocalizationsHelper.of(context).manageStock,
                Icons.inventory,
                const Color(0xFF7B4EFF),
                () => Navigator.push(context, MaterialPageRoute(builder: (context) => const InventoryScreen())),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickAccessCard(
                AppLocalizationsHelper.of(context).expenses,
                AppLocalizationsHelper.of(context).addExpense,
                Icons.receipt,
                const Color(0xFF9C7EFF),
                () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ExpenseRecordingScreen())),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickAccessCard(
                'Cash Flow',
                'Track flow',
                Icons.trending_up,
                const Color(0xFF7B4EFF),
                () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CashFlowScreen())),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickAccessCard(
                'Reports',
                'Credit report',
                Icons.assessment,
                const Color(0xFF9C7EFF),
                () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportsScreen())),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickAccessCard(
                'Reminders',
                'Set alerts',
                Icons.notifications,
                const Color(0xFF7B4EFF),
                () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RemindersScreen())),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickAccessCard(
                'Debt',
                'Track debts',
                Icons.account_balance_wallet,
                const Color(0xFF9C7EFF),
                () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DebtScreen())),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _signOut() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      navigator.pushReplacement(
        MaterialPageRoute(builder: (context) => const SignInScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('Sign out failed')));
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    final parts = name.trim().split(RegExp(r"\s+"));
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  @override
  void dispose() {
    _timeTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
    );
  }

  Widget _buildLargeCard({
    required Color color,
    required Widget child,
    double height = 140,
  }) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
    String? subtitle,
  }) {
    final isWhiteCard = color == Colors.white;
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isWhiteCard ? Colors.grey.withValues(alpha: 0.2) : color.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: isWhiteCard ? const Color(0xFF7B4EFF) : Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isWhiteCard ? const Color(0xFF7B4EFF) : Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: isWhiteCard ? Colors.black.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.9),
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isWhiteCard ? Colors.black.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.7),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}