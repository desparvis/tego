import 'package:intl/intl.dart';

/// Utility class for date formatting operations
class DateFormatter {
  /// Formats date to DD-MM-YYYY format
  static String formatDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }

  /// Formats date to readable format (e.g., "Jan 15, 2024")
  static String formatDateReadable(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  /// Formats date with time (e.g., "Jan 15, 2024 at 2:30 PM")
  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy \'at\' h:mm a').format(date);
  }

  /// Gets relative time (e.g., "2 hours ago", "Yesterday")
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return formatDate(date);
    } else if (difference.inDays > 0) {
      return difference.inDays == 1 ? 'Yesterday' : '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return difference.inHours == 1 ? '1 hour ago' : '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1 ? '1 minute ago' : '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  /// Parses date string in DD-MM-YYYY format
  static DateTime? parseDate(String dateString) {
    try {
      return DateFormat('dd-MM-yyyy').parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Gets current month name
  static String getCurrentMonth() {
    return DateFormat('MMMM yyyy').format(DateTime.now());
  }

  /// Checks if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
}