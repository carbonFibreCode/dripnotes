import 'package:dripnotes/constants/routes.dart';
import 'package:dripnotes/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

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
      body: Column(
        children: [
          const Text(
              "We've sent a mail to verify your E-mail Address please open it to verify"),
          const Text("If yet not recieved E-mail... click on the button below"),
          TextButton(
            onPressed: () async {
              await AuthService.firebase().sendEmailVerification();
            },
            child: const Text("Send Verification Mail"),
          ),
          TextButton(
            onPressed: () async {
              await AuthService.firebase().logOut();
              Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false,);
            },
            child: const Text("Restart"),
          )
        ],
      ),
    );
  }
}
