import 'package:firebase_auth/firebase_auth.dart';
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
          const Text("Verify your E-mail Address"),
          TextButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                await user?.sendEmailVerification();
              },
              child: const Text("Send Verification Mail"))
        ],
      ),
    );
  }
}
