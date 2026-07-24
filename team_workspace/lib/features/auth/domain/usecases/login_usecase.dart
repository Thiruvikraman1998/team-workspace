import 'package:team_workspace/core/mappers/result_mapper.dart';
import 'package:team_workspace/core/usecase/usecase.dart';
import 'package:team_workspace/features/auth/domain/entities/user_entity.dart';
import 'package:team_workspace/features/auth/domain/repositories/auth_repository.dart';

class LoginParams {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});
}

class LoginUsecase implements UseCase<UserEntity, LoginParams> {
  final AuthRepository _repository;

  LoginUsecase(this._repository);

  @override
  Future<Result<UserEntity>> call(LoginParams params) {
    return _repository.login(email: params.email, password: params.password);
  }
}
