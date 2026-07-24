import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_event.freezed.dart';

@freezed
sealed class AuthEvent with _$AuthEvent {
  const factory AuthEvent.checkSessionRequested() = AuthCheckSessionRequested;

  const factory AuthEvent.signUpRequested({
    required String email,
    required String password,
    required String name,
  }) = AuthSignUpRequested;

  const factory AuthEvent.loginRequested({
    required String email,
    required String password,
  }) = AuthLoginRequested;

  const factory AuthEvent.logoutRequested() = AuthLogoutRequested;
}
