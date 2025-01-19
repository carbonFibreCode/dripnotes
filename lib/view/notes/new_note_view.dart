import 'package:dripnotes/services/auth/auth_service.dart';
import 'package:dripnotes/services/crud/notes_service.dart';
import 'package:flutter/material.dart';

class NewNoteView extends StatefulWidget {
  const NewNoteView({super.key});

  @override
  State createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<NewNoteView> {
  DatabaseNotes? _note; // Changed from _notes to _note
  late final NotesService _notesService;
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _notesService = NotesService();
    _textController = TextEditingController();
    _setupTextControllerListener();
  }

  void _setupTextControllerListener() {
    _textController.addListener(() async {
      if (_note != null) {
        final text = _textController.text;
        await _notesService.updateNote(note: _note!, text: text);
      }
    });
  }

  Future<DatabaseNotes?> createNewNote() async {
    final currentUser = AuthService.firebase().currentUser;
    final email = currentUser!.email!;
    final owner = await _notesService.getUser(email: email);
    return await _notesService.createNote(owner: owner);
  }

  void _deleteNoteIfTextIsEmpty() {
    if (_textController.text.isEmpty && _note != null) {
      _notesService.deleteNote(id: _note!.id);
    }
  }

  void _saveNoteIfTextNotEmpty() async {
    final text = _textController.text;
    if (_note != null && text.isNotEmpty) {
      await _notesService.updateNote(note: _note!, text: text);
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New note'),
      ),
      body: FutureBuilder(
        future: createNewNote(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              if (snapshot.hasData) {
                _note = snapshot.data as DatabaseNotes;
                return TextField(
                  controller: _textController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: 'Start typing your note...',
                  ),
                );
              } else {
                return const Text('Error creating note.');
              }
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
