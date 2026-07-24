import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_workspace/core/usecase/usecase.dart';
import 'package:team_workspace/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:team_workspace/features/auth/domain/usecases/login_usecase.dart';
import 'package:team_workspace/features/auth/domain/usecases/logout_usecase.dart';
import 'package:team_workspace/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:team_workspace/features/auth/presentation/bloc/auth_event.dart';
import 'package:team_workspace/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignUpUsecase _signUpUsecase;
  final LoginUsecase _loginUsecase;
  final LogoutUsecase _logoutUsecase;
  final GetCurrentUserUsecase _getCurrentUserUsecase;

  AuthBloc({
    required SignUpUsecase signUpUsecase,
    required LoginUsecase loginUsecase,
    required LogoutUsecase logoutUsecase,
    required GetCurrentUserUsecase getCurrentUserUsecase,
  })  : _signUpUsecase = signUpUsecase,
        _loginUsecase = loginUsecase,
        _logoutUsecase = logoutUsecase,
        _getCurrentUserUsecase = getCurrentUserUsecase,
        super(const AuthState.initial()) {
    on<AuthCheckSessionRequested>(_onCheckSession);
    on<AuthSignUpRequested>(_onSignUp);
    on<AuthLoginRequested>(_onLogin);
    on<AuthLogoutRequested>(_onLogout);
  }

  Future<void> _onCheckSession(
    AuthCheckSessionRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final user = await _getCurrentUserUsecase();
    if (user != null) {
      emit(AuthState.authenticated(user));
    } else {
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _onSignUp(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final result = await _signUpUsecase(
      SignUpParams(email: event.email, password: event.password, name: event.name),
    );
    result.when(
      success: (user) => emit(AuthState.authenticated(user)),
      failure: (message, _) => emit(AuthState.failure(message)),
    );
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final result = await _loginUsecase(
      LoginParams(email: event.email, password: event.password),
    );
    result.when(
      success: (user) => emit(AuthState.authenticated(user)),
      failure: (message, _) => emit(AuthState.failure(message)),
    );
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());
    final result = await _logoutUsecase(const NoParams());
    result.when(
      success: (_) => emit(const AuthState.unauthenticated()),
      failure: (message, _) => emit(AuthState.failure(message)),
    );
  }
}
