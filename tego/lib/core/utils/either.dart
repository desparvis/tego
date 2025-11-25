/// Functional programming utility for handling success/failure results
/// 
/// Either represents a value that can be one of two types:
/// - Left: Represents a failure/error case
/// - Right: Represents a success case
/// 
/// This pattern eliminates the need for throwing exceptions and makes
/// error handling explicit and type-safe.
abstract class Either<L, R> {
  const Either();

  /// Creates a Left (failure) instance
  factory Either.left(L value) = Left<L, R>;

  /// Creates a Right (success) instance  
  factory Either.right(R value) = Right<L, R>;

  /// Returns true if this is a Left instance
  bool get isLeft => this is Left<L, R>;

  /// Returns true if this is a Right instance
  bool get isRight => this is Right<L, R>;

  /// Executes the appropriate function based on the Either type
  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight);

  /// Maps the right value if present, otherwise returns the left value
  Either<L, T> map<T>(T Function(R right) mapper);

  /// Returns the right value or throws if this is a Left
  R getOrThrow();
}

/// Left side of Either - represents failure/error
class Left<L, R> extends Either<L, R> {
  final L value;

  const Left(this.value);

  @override
  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight) {
    return onLeft(value);
  }

  @override
  Either<L, T> map<T>(T Function(R right) mapper) {
    return Left<L, T>(value);
  }

  @override
  R getOrThrow() {
    throw Exception('Called getOrThrow on Left: $value');
  }

  @override
  bool operator ==(Object other) {
    return other is Left<L, R> && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

/// Right side of Either - represents success
class Right<L, R> extends Either<L, R> {
  final R value;

  const Right(this.value);

  @override
  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight) {
    return onRight(value);
  }

  @override
  Either<L, T> map<T>(T Function(R right) mapper) {
    return Right<L, T>(mapper(value));
  }

  @override
  R getOrThrow() {
    return value;
  }

  @override
  bool operator ==(Object other) {
    return other is Right<L, R> && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}