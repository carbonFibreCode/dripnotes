import 'package:dripnotes/constants/routes.dart';
import 'package:dripnotes/services/auth/auth_service.dart';
import 'package:dripnotes/services/auth/bloc/auth_bloc.dart';
import 'package:dripnotes/services/auth/bloc/auth_event.dart';
import 'package:dripnotes/services/cloud/firebase_cloud_storage.dart';
import 'package:dripnotes/view/notes_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../enums/menu_action.dart';
import '../../utilities/dialog/logout_dialog.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesService;

  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    super.initState(); // Ensure database is opened
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
        appBar: AppBar(
          title:
              const Text("Your Notes", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blue,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
              },
              icon: const Icon(Icons.add, color: Colors.white),
            ),
            PopupMenuButton<MenuAction>(
              onSelected: (value) async {
                switch (value) {
                  case MenuAction.logOut:
                    final shouldLogout = await showLogoutDialog(context);
                    if (shouldLogout) {
                      context.read<AuthBloc>().add(
                            const AuthEventLogout(),
                          );
                    }
                    break;
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: MenuAction.logOut, child: Text("Log Out")),
              ],
            ),
          ],
        ),
        body: StreamBuilder(
          stream: _notesService.allNotes(ownerUserId: userId),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.active:
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  // Check for non-empty data
                  final allNotes = snapshot.data!;
                  print('Displaying notes: $allNotes'); // Debugging line
                  return NotesListView(
                    notes: allNotes,
                    onDeleteNote: (note) async {
                      await _notesService.deleteNote(
                          documentId: note.documentId);
                    },
                    onTap: (note) {
                      Navigator.of(context).pushNamed(
                        createOrUpdateNoteRoute,
                        arguments: note,
                      );
                    },
                  );
                } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                  // Handle empty notes case
                  return const Center(child: Text('No notes available.'));
                } else {
                  return const Center(child: Text('Error fetching notes.'));
                }
              default:
                return const CircularProgressIndicator();
            }
          },
        ));
  }
}
