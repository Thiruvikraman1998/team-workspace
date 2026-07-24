import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';
import 'package:team_workspace/core/database/app_database.dart';
import 'package:team_workspace/core/mappers/result_mapper.dart';
import 'package:team_workspace/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:team_workspace/features/auth/domain/entities/user_entity.dart';
import 'package:team_workspace/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;
  final AppDatabase _database;

  AuthRepositoryImpl(this._remoteDatasource, this._database);

  @override
  Future<Result<UserEntity>> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final user = await _remoteDatasource.signUp(
        email: email,
        password: password,
        name: name,
      );
      await _persistSession(user);
      return SuccessResult(data: user);
    } on FirebaseAuthException catch (e) {
      return FailureResult(errorMessage: _mapFirebaseError(e));
    } catch (e) {
      return FailureResult(errorMessage: e.toString());
    }
  }

  @override
  Future<Result<UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _remoteDatasource.login(email: email, password: password);
      await _persistSession(user);
      return SuccessResult(data: user);
    } on FirebaseAuthException catch (e) {
      return FailureResult(errorMessage: _mapFirebaseError(e));
    } catch (e) {
      return FailureResult(errorMessage: e.toString());
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _remoteDatasource.logout();
      final db = await _database.database;
      await db.delete('user_session');
      return const SuccessResult(data: null);
    } catch (e) {
      return FailureResult(errorMessage: e.toString());
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final remoteUser = _remoteDatasource.currentUser;
    if (remoteUser != null) {
      await _persistSession(remoteUser);
      return remoteUser;
    }

    // Fallback to the last locally persisted session, e.g. app restarted
    // while offline before Firebase had a chance to restore state.
    final db = await _database.database;
    final rows = await db.query('user_session', limit: 1);
    if (rows.isEmpty) return null;
    final row = rows.first;
    return UserEntity(
      uid: row['uid'] as String,
      email: row['email'] as String? ?? '',
      name: row['name'] as String?,
    );
  }

  Future<void> _persistSession(UserEntity user) async {
    final db = await _database.database;
    await db.insert(
      'user_session',
      {
        'uid': user.uid,
        'email': user.email,
        'name': user.name,
        'logged_in_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'invalid-email':
        return 'Enter a valid email address';
      case 'weak-password':
        return 'Password is too weak';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Try again later';
      case 'network-request-failed':
        return 'Please check your network connection';
      default:
        return e.message ?? 'Authentication failed';
    }
  }
}
