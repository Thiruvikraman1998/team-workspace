/// Generic Result wrapper used across the data/domain layers instead of
/// throwing exceptions up to the presentation layer.
sealed class Result<T> {
  const Result();

  R when<R>({
    required R Function(T data) success,
    required R Function(String message, int? statusCode) failure,
  }) {
    final self = this;
    if (self is SuccessResult<T>) return success(self.data);
    if (self is FailureResult<T>) {
      return failure(self.errorMessage, self.statusCode);
    }
    throw StateError('Unknown Result subtype');
  }

  bool get isSuccess => this is SuccessResult<T>;
  bool get isFailure => this is FailureResult<T>;
}

class SuccessResult<T> extends Result<T> {
  final T data;
  const SuccessResult({required this.data});
}

class FailureResult<T> extends Result<T> {
  final String errorMessage;
  final int? statusCode;
  const FailureResult({required this.errorMessage, this.statusCode});
}
