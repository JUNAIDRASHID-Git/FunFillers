import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/app_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AppRepository repository;

  AuthBloc({required this.repository}) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    on<AuthGuestRequested>(_onAuthGuestRequested);
    on<AuthGoogleSignInRequested>(_onAuthGoogleSignInRequested);
    on<AuthSendOtpRequested>(_onAuthSendOtpRequested);
    on<AuthVerifyOtpRequested>(_onAuthVerifyOtpRequested);
  }

  Future<void> _onAuthSendOtpRequested(
    AuthSendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final res = await repository.sendPhoneOtp(event.phone);
      emit(AuthOtpSentState(
        phone: event.phone,
        verificationId: res['verificationId']?.toString() ?? 'verif_123',
      ));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onAuthVerifyOtpRequested(
    AuthVerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await repository.verifyPhoneOtp(event.phone, event.otp);
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onAuthGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await repository.signInWithGoogle(
        email: event.email,
        name: event.name,
        avatarUrl: event.avatarUrl,
      );
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onAuthGuestRequested(
    AuthGuestRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await repository.signInAsGuest();
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await repository.getCurrentUser();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (_) {
      emit(Unauthenticated());
    }
  }

  Future<void> _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await repository.signInWithEmailPassword(event.email, event.password);
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await repository.signUp(event.name, event.email, event.password);
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await repository.signOut();
    emit(Unauthenticated());
  }
}
