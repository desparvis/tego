import 'package:equatable/equatable.dart';

/// Abstract base class for all failures in the application
/// 
/// Following clean architecture principles, failures are used to represent
/// errors in a type-safe way without throwing exceptions across layers.
abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

/// Failure related to network connectivity issues
class NetworkFailure extends Failure {
  const NetworkFailure({
    String message = 'Network connection failed',
    int? code,
  }) : super(message: message, code: code);
}

/// Failure related to authentication issues
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({
    String message = 'Authentication failed',
    int? code,
  }) : super(message: message, code: code);
}

/// Failure related to Firebase operations
class FirebaseFailure extends Failure {
  const FirebaseFailure({
    String message = 'Firebase operation failed',
    int? code,
  }) : super(message: message, code: code);
}

/// Failure related to data validation
class ValidationFailure extends Failure {
  final Map<String, String> fieldErrors;

  const ValidationFailure({
    String message = 'Validation failed',
    this.fieldErrors = const {},
    int? code,
  }) : super(message: message, code: code);

  @override
  List<Object?> get props => [message, code, fieldErrors];
}