import 'package:team_workspace/core/mappers/result_mapper.dart';
import 'package:team_workspace/core/usecase/usecase.dart';
import 'package:team_workspace/features/auth/domain/entities/user_entity.dart';
import 'package:team_workspace/features/auth/domain/repositories/auth_repository.dart';

class SignUpParams {
  final String email;
  final String password;
  final String? name;

  const SignUpParams({required this.email, required this.password, this.name});
}

class SignUpUsecase implements UseCase<UserEntity, SignUpParams> {
  final AuthRepository _repository;

  SignUpUsecase(this._repository);

  @override
  Future<Result<UserEntity>> call(SignUpParams params) {
    return _repository.signUp(
      email: params.email,
      password: params.password,
      name: params.name,
    );
  }
}
