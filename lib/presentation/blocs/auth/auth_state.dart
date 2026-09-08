import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserEntity user;
  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthOtpSentState extends AuthState {
  final String phone;
  final String verificationId;
  const AuthOtpSentState({required this.phone, required this.verificationId});

  @override
  List<Object?> get props => [phone, verificationId];
}
