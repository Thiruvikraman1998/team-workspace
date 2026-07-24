import 'package:team_workspace/core/mappers/result_mapper.dart';
import 'package:team_workspace/core/usecase/usecase.dart';
import 'package:team_workspace/features/auth/domain/repositories/auth_repository.dart';

class LogoutUsecase implements UseCase<void, NoParams> {
  final AuthRepository _repository;

  LogoutUsecase(this._repository);

  @override
  Future<Result<void>> call(NoParams params) {
    return _repository.logout();
  }
}
