

sealed class Result<T> {
  const Result();
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
