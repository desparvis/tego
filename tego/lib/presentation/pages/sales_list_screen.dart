import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/bottom_navigation_widget.dart';

class SalesListScreen extends StatefulWidget {
  const SalesListScreen({super.key});

  @override
  State<SalesListScreen> createState() => _SalesListScreenState();
}

class _SalesListScreenState extends State<SalesListScreen> {
  static const int pageSize = 20;
  final List<DocumentSnapshot> _docs = [];
  bool _loading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDoc;
  StreamSubscription<QuerySnapshot>? _realtimeSub;

  @override
  void initState() {
    super.initState();
    _setupRealtimeAndLoad();
  }

  Future<void> _setupRealtimeAndLoad() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // attempt to load a page anyway (no user means no data)
      await _loadPage();
      return;
    }

    // Listen to most recent page realtime (updates for newest items)
    _realtimeSub = FirestoreService.instance
        .streamCollectionQuery(
          'users/${user.uid}/sales',
          queryBuilder: (col) =>
              col.orderBy('timestamp', descending: true).limit(pageSize),
        )
        .listen((snapshot) {
          // Prepend realtime docs: keep them at the front and avoid duplicates
          final newDocs = snapshot.docs;
          final merged = <DocumentSnapshot>[];
          for (final d in newDocs) {
            merged.add(d);
          }
          for (final d in _docs) {
            if (!merged.any((m) => m.id == d.id)) merged.add(d);
          }
          setState(() {
            _docs
              ..clear()
              ..addAll(merged);
          });
        });

    // Load older pages after realtime subscription
    await _loadPage();
  }

  Future<void> _loadPage() async {
    if (_loading || !_hasMore) return;
    setState(() => _loading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }
    final page = await FirestoreService.instance.paginateCollection(
      'users/${user.uid}/sales',
      limit: pageSize,
      startAfter: _lastDoc,
      orderByField: 'timestamp',
      descending: true,
    );
    if (page.isEmpty) {
      _hasMore = false;
    } else {
      // Append older docs but avoid duplicates
      for (final d in page) {
        if (!_docs.any((existing) => existing.id == d.id)) _docs.add(d);
      }
      _lastDoc = page.last;
      if (page.length < pageSize) _hasMore = false;
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _realtimeSub?.cancel();
    super.dispose();
  }

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

                if (_docs.isEmpty && _loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (_docs.isEmpty) {
                  return const Center(child: Text('No sales recorded'));
                }

                return Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        itemCount: _docs.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1, color: Colors.grey),
                        itemBuilder: (context, index) {
                          final data =
                              _docs[index].data() as Map<String, dynamic>;
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
                      ),
                    ),
                    if (_hasMore)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: _loading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: _loadPage,
                                child: const Text('Load more'),
                              ),
                      ),
                  ],
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
