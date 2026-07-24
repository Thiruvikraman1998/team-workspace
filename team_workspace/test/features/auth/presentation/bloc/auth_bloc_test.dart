import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:team_workspace/core/mappers/result_mapper.dart';
import 'package:team_workspace/core/usecase/usecase.dart';
import 'package:team_workspace/features/auth/domain/entities/user_entity.dart';
import 'package:team_workspace/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:team_workspace/features/auth/domain/usecases/login_usecase.dart';
import 'package:team_workspace/features/auth/domain/usecases/logout_usecase.dart';
import 'package:team_workspace/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:team_workspace/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:team_workspace/features/auth/presentation/bloc/auth_event.dart';
import 'package:team_workspace/features/auth/presentation/bloc/auth_state.dart';

class MockSignUpUsecase extends Mock implements SignUpUsecase {}
class MockLoginUsecase extends Mock implements LoginUsecase {}
class MockLogoutUsecase extends Mock implements LogoutUsecase {}
class MockGetCurrentUserUsecase extends Mock implements GetCurrentUserUsecase {}

void main() {
  late AuthBloc authBloc;
  late MockSignUpUsecase mockSignUpUsecase;
  late MockLoginUsecase mockLoginUsecase;
  late MockLogoutUsecase mockLogoutUsecase;
  late MockGetCurrentUserUsecase mockGetCurrentUserUsecase;

  setUp(() {
    mockSignUpUsecase = MockSignUpUsecase();
    mockLoginUsecase = MockLoginUsecase();
    mockLogoutUsecase = MockLogoutUsecase();
    mockGetCurrentUserUsecase = MockGetCurrentUserUsecase();

    authBloc = AuthBloc(
      signUpUsecase: mockSignUpUsecase,
      loginUsecase: mockLoginUsecase,
      logoutUsecase: mockLogoutUsecase,
      getCurrentUserUsecase: mockGetCurrentUserUsecase,
    );
  });

  const tUser = UserEntity(uid: '123', email: 'test@test.com', name: 'Test');

  setUpAll(() {
    registerFallbackValue(const SignUpParams(email: '', password: ''));
    registerFallbackValue(const LoginParams(email: '', password: ''));
    registerFallbackValue(const NoParams());
  });

  group('AuthCheckSessionRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [loading, authenticated] when user is found',
      build: () {
        when(() => mockGetCurrentUserUsecase()).thenAnswer((_) async => tUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthEvent.checkSessionRequested()),
      expect: () => [
        const AuthState.loading(),
        const AuthState.authenticated(tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, unauthenticated] when user is not found',
      build: () {
        when(() => mockGetCurrentUserUsecase()).thenAnswer((_) async => null);
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthEvent.checkSessionRequested()),
      expect: () => [
        const AuthState.loading(),
        const AuthState.unauthenticated(),
      ],
    );
  });

  group('AuthSignUpRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [loading, authenticated] when signUp is successful',
      build: () {
        when(() => mockSignUpUsecase(any())).thenAnswer((_) async => const SuccessResult(data: tUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthEvent.signUpRequested(email: 'e', password: 'p', name: 'n')),
      expect: () => [
        const AuthState.loading(),
        const AuthState.authenticated(tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, failure] when signUp fails',
      build: () {
        when(() => mockSignUpUsecase(any())).thenAnswer((_) async => const FailureResult(errorMessage: 'Error'));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthEvent.signUpRequested(email: 'e', password: 'p', name: 'n')),
      expect: () => [
        const AuthState.loading(),
        const AuthState.failure('Error'),
      ],
    );
  });

  group('AuthLoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [loading, authenticated] when login is successful',
      build: () {
        when(() => mockLoginUsecase(any())).thenAnswer((_) async => const SuccessResult(data: tUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthEvent.loginRequested(email: 'e', password: 'p')),
      expect: () => [
        const AuthState.loading(),
        const AuthState.authenticated(tUser),
      ],
    );
  });

  group('AuthLogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [loading, unauthenticated] when logout is successful',
      build: () {
        when(() => mockLogoutUsecase(any())).thenAnswer((_) async => const SuccessResult(data: null));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthEvent.logoutRequested()),
      expect: () => [
        const AuthState.loading(),
        const AuthState.unauthenticated(),
      ],
    );
  });
}
