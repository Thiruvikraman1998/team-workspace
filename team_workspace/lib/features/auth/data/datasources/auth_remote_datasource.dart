import 'package:firebase_auth/firebase_auth.dart';
import 'package:team_workspace/features/auth/domain/entities/user_entity.dart';

abstract class AuthRemoteDatasource {
  Future<UserEntity> signUp({
    required String email,
    required String password,
    String? name,
  });

  Future<UserEntity> login({required String email, required String password});

  Future<void> logout();

  UserEntity? get currentUser;
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final FirebaseAuth _firebaseAuth;

  AuthRemoteDatasourceImpl(this._firebaseAuth);

  @override
  Future<UserEntity> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user!;
    if (name != null && name.trim().isNotEmpty) {
      await user.updateDisplayName(name);
    }
    return UserEntity(uid: user.uid, email: user.email ?? email, name: name);
  }

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user!;
    return UserEntity(
      uid: user.uid,
      email: user.email ?? email,
      name: user.displayName,
    );
  }

  @override
  Future<void> logout() {
    return _firebaseAuth.signOut();
  }

  @override
  UserEntity? get currentUser {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return UserEntity(uid: user.uid, email: user.email ?? '', name: user.displayName);
  }
}
