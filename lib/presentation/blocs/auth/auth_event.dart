import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthSignInRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class AuthSignUpRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  const AuthSignUpRequested(this.name, this.email, this.password);

  @override
  List<Object?> get props => [name, email, password];
}

class AuthSignOutRequested extends AuthEvent {}

class AuthGuestRequested extends AuthEvent {}

class AuthGoogleSignInRequested extends AuthEvent {
  final String? email;
  final String? name;
  final String? avatarUrl;

  const AuthGoogleSignInRequested({this.email, this.name, this.avatarUrl});

  @override
  List<Object?> get props => [email, name, avatarUrl];
}

class AuthSendOtpRequested extends AuthEvent {
  final String phone;
  const AuthSendOtpRequested(this.phone);

  @override
  List<Object?> get props => [phone];
}

class AuthVerifyOtpRequested extends AuthEvent {
  final String phone;
  final String otp;
  const AuthVerifyOtpRequested(this.phone, this.otp);

  @override
  List<Object?> get props => [phone, otp];
}

typedef CheckAuthStatus = AuthCheckRequested;
typedef SignOutRequested = AuthSignOutRequested;
typedef SignInAsGuestRequested = AuthGuestRequested;
