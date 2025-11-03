// lib/landing_screen.dart
import 'package:flutter/material.dart';
import 'sales_list_screen.dart'; // Import the new sales page

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  // Tracks which tab is selected (0 = Home)
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Top App Bar — shows username and time
      appBar: AppBar(
        title: const Text(
          'Username',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '9:30',
              style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.9)),
            ),
          ),
        ],
        backgroundColor: const Color(0xFF7430EB),
        elevation: 0,
      ),

      // Main Body — full screen, scrollable
      body: Container(
        width: double.infinity,
        color: Colors.grey[50],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === ALL TIME SALES CARD (FULL WIDTH) ===
              _buildSectionTitle('All time sales'),
              const SizedBox(height: 12),

              // Big purple card with "21" and "+2 made today"
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF7430EB),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7430EB).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      '21',
                      style: TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '+2 made today',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // === EXPENSES & BALANCE (SIDE BY SIDE) ===
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Today\'s expenses',
                      value: '5,231 RWF',
                      color: const Color(0xFFD4A4EB),
                      icon: Icons.trending_down,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Balance',
                      value: '21,000 RWF',
                      color: const Color(0xFFF4A4A4),
                      icon: Icons.account_balance_wallet,
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

      // Bottom Navigation — shared with Sales page
      bottomNavigationBar: _buildBottomNav(context, selectedIndex: 0),
    );
  }

  // === HELPER: Section Title (like "All time sales") ===
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
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
            color: color.withOpacity(0.3),
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
            color: color.withOpacity(0.3),
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
              color: Colors.black.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  // === SHARED BOTTOM NAVIGATION BAR ===
  // This is used in BOTH Home and Sales pages
  Widget _buildBottomNav(BuildContext context, {required int selectedIndex}) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      selectedItemColor: const Color(0xFF7430EB),
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      elevation: 12,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        if (index == 1) {
          // Go to Sales List
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SalesListScreen()),
          );
        }
        // Add other pages later (Add, Settings)
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Sales'),
        BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }
}