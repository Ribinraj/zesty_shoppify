import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:zestyvibe/domain/models/customer_model.dart';
import 'package:zestyvibe/domain/repositories/apprepo.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AppRepo repository;
  AuthBloc({required this.repository}) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheck);
    on<AuthLoginRequested>(_onLogin);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthRegisterRequested>(_onRegister);
  }

  FutureOr<void> _onCheck(AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final resp = await repository.fetchCustomer();
    if (resp.error || resp.data == null) {
      emit(AuthUnauthenticated());
      return;
    }
    try {
      final customer = CustomerModel.fromGraphQL(resp.data!);
      emit(AuthAuthenticated(customer));
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  FutureOr<void> _onLogin(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final resp = await repository.loginCustomer(email: event.email, password: event.password);
    if (resp.error) {
      emit(AuthError(resp.message));
      return;
    }
    final prof = await repository.fetchCustomer();
    if (prof.error || prof.data == null) {
      emit(AuthError(prof.message));
      return;
    }
    final customer = CustomerModel.fromGraphQL(prof.data!);
    emit(AuthAuthenticated(customer));
  }

  FutureOr<void> _onLogout(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final resp = await repository.logoutCustomer();
    if (resp.error) {
      emit(AuthError(resp.message));
      return;
    }
    emit(AuthUnauthenticated());
  }

  FutureOr<void> _onRegister(AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final resp = await repository.registerCustomer(
      firstName: event.firstName,
      lastName: event.lastName,
      email: event.email,
      password: event.password,
    );
    if (resp.error) {
      emit(AuthError(resp.message));
      return;
    }
    // auto-login after register
    final login = await repository.loginCustomer(email: event.email, password: event.password);
    if (login.error) {
      emit(AuthError('Registered but login failed: ${login.message}'));
      return;
    }
    final prof = await repository.fetchCustomer();
    if (prof.error || prof.data == null) {
      emit(AuthError(prof.message));
      return;
    }
    final customer = CustomerModel.fromGraphQL(prof.data!);
    emit(AuthAuthenticated(customer));
  }
}
