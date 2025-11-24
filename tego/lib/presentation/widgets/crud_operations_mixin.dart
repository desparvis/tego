import 'package:flutter/material.dart';
import 'custom_snackbar.dart';

/// Mixin for handling CRUD operations with instant UI feedback
mixin CrudOperationsMixin<T extends StatefulWidget> on State<T> {
  
  /// Shows success message with instant feedback
  void showSuccessMessage(String message) {
    CustomSnackBar.show(
      context,
      message: message,
      type: SnackBarType.success,
      duration: const Duration(seconds: 2),
    );
  }

  /// Shows error message with retry option
  void showErrorMessage(String message, {VoidCallback? onRetry}) {
    CustomSnackBar.show(
      context,
      message: message,
      type: SnackBarType.error,
      duration: const Duration(seconds: 5),
      onAction: onRetry,
      actionLabel: onRetry != null ? 'RETRY' : null,
    );
  }

  /// Shows loading indicator
  void showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// Hides loading indicator
  void hideLoadingDialog() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  /// Shows confirmation dialog for delete operations
  Future<bool> showDeleteConfirmation(String itemName) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this $itemName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
  }

  /// Handles optimistic updates with rollback on error
  void performOptimisticUpdate<TData>({
    required TData optimisticData,
    required Future<void> Function() operation,
    required void Function(TData data) updateUI,
    required void Function() revertUI,
    required String successMessage,
    required String errorMessage,
  }) async {
    // Apply optimistic update
    updateUI(optimisticData);
    showSuccessMessage(successMessage);

    try {
      await operation();
    } catch (e) {
      // Revert on error
      revertUI();
      showErrorMessage(errorMessage);
    }
  }
}