part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}
class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  AuthLoginRequested({required this.email, required this.password});
}

class AuthLogoutRequested extends AuthEvent {}

class AuthRegisterRequested extends AuthEvent {
  final String firstName;
  final String? lastName;
  final String email;
  final String password;
  AuthRegisterRequested({
    required this.firstName,
    this.lastName,
    required this.email,
    required this.password,
  });
}