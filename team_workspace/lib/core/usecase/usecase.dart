import 'package:team_workspace/core/mappers/result_mapper.dart';

/// Base contract for a use case that takes [Params] and returns a [Result].
abstract class UseCase<Type, Params> {
  Future<Result<Type>> call(Params params);
}

/// Marker for use cases that take no parameters.
class NoParams {
  const NoParams();
}
