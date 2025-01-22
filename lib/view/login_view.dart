import 'package:dripnotes/services/auth/bloc/auth_bloc.dart';
import 'package:dripnotes/services/auth/bloc/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../utilities/dialog/show_error_dialog.dart';
import 'package:dripnotes/services/auth/auth_exceptions.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Login",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            autocorrect: false,
            enableSuggestions: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: "Enter Email or Username",
            ),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            decoration: const InputDecoration(
              hintText: "Enter Password",
            ),
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              try {
                context.read<AuthBloc>().add(
                      AuthEventLogin(
                        email: email,
                        password: password,
                      ),
                    );
              } on InvalidCredentialsAuthException {
                await showErrorDialog(
                    context, "User email or password is invalid");
              } on InvalidEmailAuthException {
                await showErrorDialog(context, "Enter the valid E-mail");
              } on ChannelErrorAuthException {
                await showErrorDialog(context, "Enter the valid credentials");
              } on GenericAuthException {
                await showErrorDialog(context, 'Authentication Error');
              }
            },
            child: const Text(
              "Login",
              style: TextStyle(
                color: Colors.blue,
              ),
            ),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/register/', (route) => false);
              },
              child: const Text(
                "Not yet registered? Register Now!",
                style: TextStyle(
                  color: Colors.blue,
                ),
              ))
        ],
      ),
    );
  }
}
