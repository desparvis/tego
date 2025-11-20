import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/firestore_service.dart';
import 'sign_in_screen.dart';
import 'expense_recording_screen.dart';
import 'expense_list_screen.dart';
import '../../core/utils/preferences_service.dart';
import '../widgets/bottom_navigation_widget.dart';
import '../widgets/floating_action_menu.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  String _username = 'Username';
  String _timeString = '';
  Timer? _timeTimer;

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _updateTime();
    _timeTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _updateTime(),
    );
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
      // Top App Bar — shows username and time
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
                  'Welcome back',
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

      // Main Body — full screen, scrollable
      body: Container(
        width: double.infinity,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === WELCOME MESSAGE ===
              Text(
                'Welcome back, $_username!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Here’s your dashboard for today',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 14),

              // === ALL TIME SALES CARD (FULL WIDTH) ===
              _buildSectionTitle('All time sales'),
              const SizedBox(height: 12),

              // Big purple card showing aggregated sales from Firestore
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
                      // amount may be stored as number
                      final amt = (data['amount'] is num)
                          ? (data['amount'] as num).toDouble()
                          : double.tryParse('${data['amount']}') ?? 0.0;
                      totalAmount += amt;

                      DateTime? ts;
                      if (data['timestamp'] != null &&
                          data['timestamp'] is Timestamp) {
                        ts = (data['timestamp'] as Timestamp).toDate();
                      } else if (data['date'] != null &&
                          data['date'] is String) {
                        // fallback parsing dd-mm-yyyy
                        try {
                          final parts = (data['date'] as String).split('-');
                          if (parts.length >= 3) {
                            ts = DateTime(
                              int.parse(parts[2]),
                              int.parse(parts[1]),
                              int.parse(parts[0]),
                            );
                          }
                        } catch (_) {
                          ts = null;
                        }
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
                    padding: const EdgeInsets.symmetric(
                      vertical: 32,
                      horizontal: 20,
                    ),
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
                        // If a stats doc exists prefer that to live computation
                        StreamBuilder<DocumentSnapshot?>(
                          stream: (() {
                            final user = FirebaseAuth.instance.currentUser;
                            if (user == null) return null;
                            return FirestoreService.instance.streamDocument(
                              'users',
                              user.uid,
                            );
                          })(),
                          builder: (context, statsSnap) {
                            if (statsSnap.hasData && statsSnap.data != null) {
                              final stats =
                                  statsSnap.data!.data()
                                      as Map<String, dynamic>?;
                              final count =
                                  stats?['totalSalesCount'] ?? totalCount;
                              final total =
                                  stats?['totalAmount'] ?? totalAmount;
                              return Column(
                                children: [
                                  Text(
                                    '$count',
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
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Total: ${((total is num) ? total.toDouble() : double.tryParse('$total') ?? 0).toStringAsFixed(0)} RWF',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }

                            return Column(
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
                            );
                          },
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
              ),
              const SizedBox(height: 28),

              // === EXPENSES & BALANCE (SIDE BY SIDE) ===
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ExpenseListScreen(),
                        ),
                      ),
                      child: _buildStatCard(
                        title: 'Today\'s expenses',
                        value: '5,231 RWF',
                        color: const Color(0xFFD4A4EB),
                        icon: Icons.trending_down,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ExpenseRecordingScreen(),
                        ),
                      ),
                      child: _buildStatCard(
                        title: 'Add Expense',
                        value: 'Tap to add',
                        color: const Color(0xFFF4A4A4),
                        icon: Icons.add,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // === PROFIT CARD ===
              _buildSectionTitle('Profit'),
              const SizedBox(height: 12),
              _buildLargeCard(
                color: const Color(0xFFD4A4EB),
                height: 80,
                child: const Center(
                  child: Text(
                    '4,501 RWF',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: const BottomNavigationWidget(currentIndex: 0),
      
      // Floating Action Menu
      floatingActionButton: const FloatingActionMenu(),
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
    super.dispose();
  }

  // === HELPER: Section Title (like "All time sales") ===
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

  // === HELPER: Big Card (used for Profit) ===
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
            color: color.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  // === HELPER: Small Stat Card (Expenses & Balance) ===
  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.black54, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
