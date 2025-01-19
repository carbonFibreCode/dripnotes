import 'package:dripnotes/services/auth/auth_service.dart';
import 'package:dripnotes/view/login_view.dart';
import 'package:dripnotes/view/notes/create_update_note_view.dart';
import 'package:dripnotes/view/notes/notes_view.dart';
import 'package:dripnotes/view/register_view.dart';
import 'package:dripnotes/view/verify_email_view.dart';
import 'package:flutter/material.dart';
import 'constants/routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute : (context) => const NotesView(),
        verifyEmailRoute : (context) => const verifyEmailView(), // Corrected class name
        createOrUpdateNoteRoute : (context) => const CreateUpdateNoteView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            print('User state: $user'); // Debugging line
            if (user != null) {
              if (user.isEmailVerified) {
                return const NotesView(); // Ensure this initializes properly
              } else {
                return const verifyEmailView(); // Corrected class name
              }
            } else {
              return const LoginView();
            }
          case ConnectionState.waiting:
            return const CircularProgressIndicator();
          default:
            return const Center(child: Text('Error initializing app.'));
        }
      },
    );
  }
}
