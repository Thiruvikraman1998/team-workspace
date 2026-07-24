import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart';
import 'package:team_workspace/core/database/app_database.dart';
import 'package:team_workspace/core/mappers/result_mapper.dart';
import 'package:team_workspace/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:team_workspace/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:team_workspace/features/auth/domain/entities/user_entity.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;

class MockAuthRemoteDatasource extends Mock implements AuthRemoteDatasource {}
class MockAppDatabase extends Mock implements AppDatabase {}
class MockDatabase extends Mock implements Database {}
class MockFirebaseAuthException extends Mock implements firebase.FirebaseAuthException {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDatasource mockRemoteDatasource;
  late MockAppDatabase mockAppDatabase;
  late MockDatabase mockDatabase;

  setUp(() {
    mockRemoteDatasource = MockAuthRemoteDatasource();
    mockAppDatabase = MockAppDatabase();
    mockDatabase = MockDatabase();
    repository = AuthRepositoryImpl(mockRemoteDatasource, mockAppDatabase);

    when(() => mockAppDatabase.database).thenAnswer((_) async => mockDatabase);
  });

  const tUser = UserEntity(uid: '123', email: 'test@example.com', name: 'Test User');

  group('signUp', () {
    test('should return SuccessResult when signUp is successful', () async {
      // arrange
      when(() => mockRemoteDatasource.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
        name: any(named: 'name'),
      )).thenAnswer((_) async => tUser);
      when(() => mockDatabase.insert(any(), any(), conflictAlgorithm: any(named: 'conflictAlgorithm')))
          .thenAnswer((_) async => 1);

      // act
      final result = await repository.signUp(email: 'test@example.com', password: 'password', name: 'Test User');

      // assert
      expect(result, isA<SuccessResult<UserEntity>>());
      expect((result as SuccessResult).data, tUser);
      verify(() => mockRemoteDatasource.signUp(email: 'test@example.com', password: 'password', name: 'Test User')).called(1);
      verify(() => mockDatabase.insert('user_session', any(), conflictAlgorithm: ConflictAlgorithm.replace)).called(1);
    });

    test('should return FailureResult when FirebaseAuthException occurs', () async {
      // arrange
      final mockException = MockFirebaseAuthException();
      when(() => mockException.code).thenReturn('email-already-in-use');
      when(() => mockRemoteDatasource.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
        name: any(named: 'name'),
      )).thenThrow(mockException);

      // act
      final result = await repository.signUp(email: 'test@example.com', password: 'password', name: 'Test User');

      // assert
      expect(result, isA<FailureResult<UserEntity>>());
      expect((result as FailureResult).errorMessage, 'This email is already registered');
    });
  });

  group('login', () {
    test('should return SuccessResult and persist session on success', () async {
      // arrange
      when(() => mockRemoteDatasource.login(email: any(named: 'email'), password: any(named: 'password')))
          .thenAnswer((_) async => tUser);
      when(() => mockDatabase.insert(any(), any(), conflictAlgorithm: any(named: 'conflictAlgorithm')))
          .thenAnswer((_) async => 1);

      // act
      final result = await repository.login(email: 'test@example.com', password: 'password');

      // assert
      expect(result, isA<SuccessResult<UserEntity>>());
      verify(() => mockDatabase.insert('user_session', any(), conflictAlgorithm: ConflictAlgorithm.replace)).called(1);
    });
  });

  group('logout', () {
    test('should return SuccessResult and delete session on logout', () async {
      // arrange
      when(() => mockRemoteDatasource.logout()).thenAnswer((_) async => {});
      when(() => mockDatabase.delete(any())).thenAnswer((_) async => 1);

      // act
      final result = await repository.logout();

      // assert
      expect(result, isA<SuccessResult<void>>());
      verify(() => mockRemoteDatasource.logout()).called(1);
      verify(() => mockDatabase.delete('user_session')).called(1);
    });
  });

  group('getCurrentUser', () {
    test('should return remote user and persist session when remote user is not null', () async {
      // arrange
      when(() => mockRemoteDatasource.currentUser).thenReturn(tUser);
      when(() => mockDatabase.insert(any(), any(), conflictAlgorithm: any(named: 'conflictAlgorithm')))
          .thenAnswer((_) async => 1);

      // act
      final result = await repository.getCurrentUser();

      // assert
      expect(result, tUser);
      verify(() => mockDatabase.insert('user_session', any(), conflictAlgorithm: ConflictAlgorithm.replace)).called(1);
    });

    test('should fallback to database when remote user is null', () async {
      // arrange
      when(() => mockRemoteDatasource.currentUser).thenReturn(null);
      when(() => mockDatabase.query('user_session', limit: 1)).thenAnswer((_) async => [
        {'uid': '123', 'email': 'test@example.com', 'name': 'Test User'}
      ]);

      // act
      final result = await repository.getCurrentUser();

      // assert
      expect(result, tUser);
      verify(() => mockDatabase.query('user_session', limit: 1)).called(1);
    });
  });
}
