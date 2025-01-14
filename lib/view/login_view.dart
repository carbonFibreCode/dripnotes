import 'package:dripnotes/constants/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

import '../utilities/showErrorDialog.dart';

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
                await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: email, password: password);
                final user = FirebaseAuth.instance.currentUser;
                if(user != null){
                  if(user.emailVerified){
                    Navigator.of(context).pushNamedAndRemoveUntil(notesRoute, (route) => false);
                  }
                  else{
                    Navigator.of(context).pushNamed(verifyEmailRoute);
                  }
                }
                else{
                  Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);
                }
              } on FirebaseAuthException catch (e) {
                if (e.code == "invalid-credential") {
                  await showErrorDialog(context, "User email or password is invalid");
                }
                else if (e.code == "channel-error") {
                  await showErrorDialog(context, "Enter the valid credentials");
                }
                else{
                  await showErrorDialog(context, "error : ${e.code}");
                }
              } catch (e) {
                await showErrorDialog(context, "error : $e");
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

