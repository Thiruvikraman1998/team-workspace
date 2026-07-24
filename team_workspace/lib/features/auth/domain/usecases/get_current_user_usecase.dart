import 'package:team_workspace/features/auth/domain/entities/user_entity.dart';
import 'package:team_workspace/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUserUsecase {
  final AuthRepository _repository;

  GetCurrentUserUsecase(this._repository);

  Future<UserEntity?> call() {
    return _repository.getCurrentUser();
  }
}
