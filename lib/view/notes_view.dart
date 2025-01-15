import 'package:dripnotes/constants/routes.dart';
import 'package:dripnotes/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import '../enums/menu_action.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}


class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Main UI",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
          actions: [
            PopupMenuButton<MenuAction>(
              onSelected: (value) async {
                switch (value) {
                  case MenuAction.logOut:
                    final shouldLogout = await showLogoutDialog(context);
                    if(shouldLogout){
                      await AuthService.firebase().logOut();
                      Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);
                    }
                    break;
                }

              },
              itemBuilder: (context) {
                return const [
                  PopupMenuItem<MenuAction>(
                    value: MenuAction.logOut,
                    child: Text("Log Out"),
                  )
                ];
              },
              style: ButtonStyle(
                iconColor: WidgetStateProperty.all<Color>(Colors.white),
              ),
            )
          ],
        ),
        body: const Text("Hello World"));
  }
}

Future<bool> showLogoutDialog(BuildContext context) {
  return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Log out"),
          content: const Text("Are you sure want to Log Out"),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text("cancel")),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text("Log Out"))
          ],
        );
      }).then((value) => value ?? false);
}
