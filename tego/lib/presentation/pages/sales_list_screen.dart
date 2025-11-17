import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/bottom_navigation_widget.dart';

class SalesListScreen extends StatelessWidget {
  const SalesListScreen({super.key});

  // We'll stream sales for the current user from Firestore.

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
                color: Colors.white.withValues(alpha: 0.9),
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

          // SCROLLABLE LIST — stream from Firestore
          Expanded(
            child: Builder(
              builder: (context) {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  return const Center(
                    child: Text('Please sign in to view sales'),
                  );
                }

                return StreamBuilder<QuerySnapshot>(
                  stream: FirestoreService.instance.streamCollection(
                    'users/${user.uid}/sales',
                    limit: 200,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text('Failed to load sales'));
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snapshot.data!.docs;
                    if (docs.isEmpty) {
                      return const Center(child: Text('No sales recorded'));
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      itemCount: docs.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: Colors.grey),
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final amount = data['amount']?.toString() ?? '';
                        final date = data['date']?.toString() ?? '';
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  amount,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  date,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // Bottom Navigation
      bottomNavigationBar: const BottomNavigationWidget(currentIndex: 1),
    );
  }
}
