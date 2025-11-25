import 'package:flutter/material.dart';
import '../../core/utils/screen_utils.dart';


/// Swipe-to-delete widget for instant CRUD operations
class SwipeToDelete extends StatelessWidget {
  final Widget child;
  final VoidCallback onDelete;
  final String confirmationMessage;
  final Color backgroundColor;

  const SwipeToDelete({
    super.key,
    required this.child,
    required this.onDelete,
    this.confirmationMessage = 'Are you sure you want to delete this item?',
    this.backgroundColor = Colors.red,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: Text(confirmationMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: backgroundColor),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: ScreenUtils.w(20)),
        color: backgroundColor,
        child: Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: ScreenUtils.w(24),
        ),
      ),
      child: child,
    );
  }
}