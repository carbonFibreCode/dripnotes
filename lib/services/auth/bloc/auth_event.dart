import 'package:flutter/foundation.dart';

@immutable
abstract class AuthEvent{
  const AuthEvent();
}

class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

class AuthEventSendEmailVerification extends AuthEvent {
  const AuthEventSendEmailVerification();
}

class AuthEventLogin extends AuthEvent{
  final String email;
  final String password;

  AuthEventLogin({required this.email, required this.password});
}

class AuthEventRegister extends AuthEvent {
  final String email;
  final String password;
  const AuthEventRegister(this.email, this.password);
}

class AuthEventhShouldRegister extends AuthEvent {
  const AuthEventhShouldRegister();
}

class AuthEventLogout extends AuthEvent {
  const AuthEventLogout();
}