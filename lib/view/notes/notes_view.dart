import 'package:dripnotes/constants/routes.dart';
import 'package:dripnotes/services/auth/auth_service.dart';
import 'package:dripnotes/services/crud/notes_service.dart';
import 'package:dripnotes/view/notes_list_view.dart';
import 'package:flutter/material.dart';
import '../../enums/menu_action.dart';
import '../../utilities/dialog/logout_dialog.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NotesService _notesService;

  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    super.initState();
    _notesService = NotesService();
    _notesService.open(); // Ensure database is opened
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Notes", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(newNoteRoute);
            },
            icon: const Icon(Icons.add, color: Colors.white),
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logOut:
                  final shouldLogout = await showLogoutDialog(context);
                  if (shouldLogout) {
                    await AuthService.firebase().logOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);
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
      body: FutureBuilder(
        future: _notesService.getOrCreateUser(email: userEmail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder<List<DatabaseNotes>>(
                stream: _notesService.allNotes,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.active:
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) { // Check for non-empty data
                        final allNotes = snapshot.data!;
                        print('Displaying notes: $allNotes'); // Debugging line
                        return NotesListView(
                          notes: allNotes,
                          onDeleteNote: (note) async {
                            await _notesService.deleteNote(id: note.id);
                          },
                        );
                      } else if (snapshot.hasData && snapshot.data!.isEmpty) { // Handle empty notes case
                        return const Center(child: Text('No notes available.'));
                      } else {
                        return const Center(child: Text('Error fetching notes.'));
                      }
                    default:
                      return const CircularProgressIndicator();
                  }
                },
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
