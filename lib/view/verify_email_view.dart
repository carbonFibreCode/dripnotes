import 'package:dripnotes/services/auth/bloc/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/auth/bloc/auth_bloc.dart';

class verifyEmailView extends StatefulWidget {
  const verifyEmailView({super.key});

  @override
  State<verifyEmailView> createState() => _verifyEmailViewState();
}

class _verifyEmailViewState extends State<verifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Verify E-mail",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
                "We've sent a mail to verify your E-mail Address please open it to verify"),
            const Text("If yet not recieved E-mail... click on the button below"),
            TextButton(
              onPressed: () {
                context.read<AuthBloc>().add(const AuthEventSendEmailVerification());
              },
              child: const Text("Send Verification Mail"),
            ),
            TextButton(
              onPressed: () async {
                context.read<AuthBloc>().add(const AuthEventLogout());
              },
              child: const Text("Restart"),
            )
          ],
        ),
      ),
    );
  }
}
