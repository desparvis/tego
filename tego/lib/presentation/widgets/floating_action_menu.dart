import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../pages/sales_recording_screen.dart';
import '../pages/expense_recording_screen.dart';

class FloatingActionMenu extends StatefulWidget {
  const FloatingActionMenu({super.key});

  @override
  State<FloatingActionMenu> createState() => _FloatingActionMenuState();
}

class _FloatingActionMenuState extends State<FloatingActionMenu>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: _animation,
          child: FloatingActionButton(
            heroTag: "expense",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExpenseRecordingScreen(),
                ),
              );
            },
            backgroundColor: Colors.red[400],
            child: const Icon(Icons.remove, color: Colors.white),
          ),
        ),
        const SizedBox(height: 10),
        ScaleTransition(
          scale: _animation,
          child: FloatingActionButton(
            heroTag: "sale",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SalesRecordingScreen(),
                ),
              );
            },
            backgroundColor: AppConstants.primaryPurple,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
        const SizedBox(height: 10),
        FloatingActionButton(
          heroTag: "main",
          onPressed: _toggle,
          backgroundColor: AppConstants.primaryPurple,
          child: AnimatedRotation(
            turns: _isOpen ? 0.125 : 0,
            duration: const Duration(milliseconds: 300),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}