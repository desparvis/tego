import 'package:flutter/material.dart';
import 'landing_screen.dart';

class SalesListScreen extends StatelessWidget {
  const SalesListScreen({super.key});

  // Sample sales data (replace with API later)
  final List<Map<String, String>> _sales = const [
    {'amount': '4,501 rwf', 'date': '18-12-2025'},
    {'amount': '12,010 rwf', 'date': '17-12-2025'},
    {'amount': '5,000 rwf', 'date': '16-12-2025'},
    {'amount': '4,870 rwf', 'date': '15-12-2025'},
    {'amount': '1,500 rwf', 'date': '14-12-2025'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Top App Bar — consistent with Home
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
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
        ],
        backgroundColor: const Color(0xFF7430EB),
        elevation: 0,
      ),

      // Main Body
      body: Column(
        children: [
          // FIXED HEADER: "Sales List" — stays at top
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            decoration: const BoxDecoration(
              color: Color(0xFF7430EB),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: const Text(
              'Sales List',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // TABLE HEADER: Amount | Date
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: Colors.grey[100],
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Amount',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Date',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),

          // SCROLLABLE LIST — this part scrolls
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: _sales.length,
              itemBuilder: (context, index) {
                final sale = _sales[index];
                return Column(
                  children: [
                    // Each Sale Row
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              sale['amount']!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              sale['date']!,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Divider line between rows
                    const Divider(height: 1, color: Colors.grey),
                  ],
                );
              },
            ),
          ),
        ],
      ),

      // SAME BOTTOM NAV as Home
      bottomNavigationBar: _buildBottomNav(context, selectedIndex: 1),
    );
  }

  // Reusable Bottom Navigation Bar
  Widget _buildBottomNav(BuildContext context, {required int selectedIndex}) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      selectedItemColor: const Color(0xFF7430EB),
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      elevation: 12,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LandingScreen()),
          );
        }

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
