import 'package:team_workspace/core/mappers/result_mapper.dart';
import 'package:team_workspace/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Result<UserEntity>> signUp({
    required String email,
    required String password,
    String? name,
  });

  Future<Result<UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Result<void>> logout();

  /// Reads the persisted session (Firebase current user first, falls back
  /// to the locally cached sqflite session for offline app restarts).
  Future<UserEntity?> getCurrentUser();
}
