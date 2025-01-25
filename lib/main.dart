import 'package:dripnotes/helpers/loading/loading_screen.dart';
import 'package:dripnotes/services/auth/bloc/auth_bloc.dart';
import 'package:dripnotes/services/auth/bloc/auth_event.dart';
import 'package:dripnotes/services/auth/bloc/auth_state.dart';
import 'package:dripnotes/services/auth/firebase_auth_provider.dart';
import 'package:dripnotes/view/forgot_password_view.dart';
import 'package:dripnotes/view/login_view.dart';
import 'package:dripnotes/view/notes/create_update_note_view.dart';
import 'package:dripnotes/view/notes/notes_view.dart';
import 'package:dripnotes/view/register_view.dart';
import 'package:dripnotes/view/verify_email_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'constants/routes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      title: 'Flutter Demo',
      debugShowCheckedModeBanner:false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const HomePage(),
      ),
      routes: {
        createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if(state.isLoading){
          LoadingScreen().show(context: context, text: state.loadingText ?? 'please wait a moment');
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const NotesView();
        } else if (state is AuthStateNeedsVerification) {
          return const verifyEmailView();
        } else if (state is AuthStateLoggedOut) {
          return const LoginView();
        } else if (state is AuthStateForgotPassword){
          return ForgotPasswordView();
        } else if(state is AuthStateRegistering) {
          return RegisterView();
        }
        else {
          return Scaffold(
            body: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
