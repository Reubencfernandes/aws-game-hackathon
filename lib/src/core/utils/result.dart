/// A Result type for handling success and failure cases
sealed class Result<T> {
  const Result();
}

/// Success case with data
class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

/// Failure case with error
class Failure<T> extends Result<T> {
  final String message;
  final Exception? exception;
  const Failure(this.message, [this.exception]);
}

/// Extension methods for Result
extension ResultExtension<T> on Result<T> {
  /// Returns true if this is a Success
  bool get isSuccess => this is Success<T>;

  /// Returns true if this is a Failure
  bool get isFailure => this is Failure<T>;

  /// Get data if Success, null otherwise
  T? get dataOrNull => this is Success<T> ? (this as Success<T>).data : null;

  /// Get error message if Failure, null otherwise
  String? get errorOrNull =>
      this is Failure<T> ? (this as Failure<T>).message : null;

  /// Fold the result into a single value
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(String message, Exception? exception) onFailure,
  }) {
    return switch (this) {
      Success(data: final data) => onSuccess(data),
      Failure(message: final msg, exception: final ex) => onFailure(msg, ex),
    };
  }
}
