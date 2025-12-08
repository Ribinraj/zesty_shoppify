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
class AuthUpdateProfileRequested extends AuthEvent {
  final String? firstName;
  final String? lastName;
  final String? phone;
  final bool? acceptsMarketing;

  AuthUpdateProfileRequested({
    this.firstName,
    this.lastName,
    this.phone,
    this.acceptsMarketing,
  });
}
class AuthUpdateAddressRequested extends AuthEvent {
  final String address1;
  final String? address2;
  final String? city;
  final String? province;
  final String? zip;
  final String? country;

  AuthUpdateAddressRequested({
    required this.address1,
    this.address2,
    this.city,
    this.province,
    this.zip,
    this.country,
  });
}