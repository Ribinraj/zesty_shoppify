import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:zestyvibe/data/models/customer_model.dart';
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
        on<AuthUpdateProfileRequested>(_onUpdateProfile);
         on<AuthUpdateAddressRequested>(_onUpdateAddress); 
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
    FutureOr<void> _onUpdateProfile(
    AuthUpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    // keep old customer in case of error
    CustomerModel? oldCustomer;
    if (state is AuthAuthenticated) {
      oldCustomer = (state as AuthAuthenticated).customer;
    }

    emit(AuthLoading());

    final resp = await repository.updateCustomerProfile(
      firstName: event.firstName,
      lastName: event.lastName,
      phone: event.phone,
      acceptsMarketing: event.acceptsMarketing,
    );

    if (resp.error || resp.data == null) {
      emit(AuthError(resp.message));
      // come back to previous state so UI doesn't get stuck
      if (oldCustomer != null) {
        emit(AuthAuthenticated(oldCustomer));
      } else {
        emit(AuthUnauthenticated());
      }
      return;
    }

    final updatedCustomer = CustomerModel.fromGraphQL(resp.data!);
    emit(AuthAuthenticated(updatedCustomer));
  }
FutureOr<void> _onUpdateAddress(
  AuthUpdateAddressRequested event,
  Emitter<AuthState> emit,
) async {
  CustomerModel? oldCustomer;
  if (state is AuthAuthenticated) {
    oldCustomer = (state as AuthAuthenticated).customer;
  }

  emit(AuthLoading());

  // 1) Create address
  final createResp = await repository.createCustomerAddress(
    address1: event.address1,
    address2: event.address2,
    city: event.city,
    province: event.province,
    zip: event.zip,
    country: event.country,
  );

  if (createResp.error || createResp.data == null) {
    emit(AuthError(createResp.message));
    if (oldCustomer != null) {
      emit(AuthAuthenticated(oldCustomer));
    } else {
      emit(AuthUnauthenticated());
    }
    return;
  }

  final createdAddress = createResp.data!;
  final addressId = createdAddress['id'] as String?;

  if (addressId == null) {
    emit(AuthError('Address created but no id returned'));
    if (oldCustomer != null) {
      emit(AuthAuthenticated(oldCustomer));
    } else {
      emit(AuthUnauthenticated());
    }
    return;
  }

  // 2) Set it as default
  final defaultResp = await repository.setDefaultCustomerAddress(
    addressId: addressId,
  );

  if (defaultResp.error) {
    emit(AuthError(defaultResp.message));
    if (oldCustomer != null) {
      emit(AuthAuthenticated(oldCustomer));
    } else {
      emit(AuthUnauthenticated());
    }
    return;
  }

  // 3) Fetch full updated customer to refresh profile
  final prof = await repository.fetchCustomer();
  if (prof.error || prof.data == null) {
    emit(AuthError(prof.message));
    if (oldCustomer != null) {
      emit(AuthAuthenticated(oldCustomer));
    } else {
      emit(AuthUnauthenticated());
    }
    return;
  }

  final updatedCustomer = CustomerModel.fromGraphQL(prof.data!);
  emit(AuthAuthenticated(updatedCustomer));
}

}
