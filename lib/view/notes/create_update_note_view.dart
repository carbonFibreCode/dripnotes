import 'package:dripnotes/services/auth/auth_service.dart';
import 'package:dripnotes/services/crud/notes_service.dart';
import 'package:dripnotes/utilities/dialog/generics/get_arguments.dart';
import 'package:flutter/material.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
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

  Future<DatabaseNotes?> createOrGetExistingNote() async {

    final widgetNote = context.getArgument<DatabaseNotes>();

    if(widgetNote != null){
      _note = widgetNote;
      _textController.text = widgetNote.text;
      return widgetNote;
    }

    final existingNote = _note;
    if(existingNote != null) {
      return existingNote;
    }

    final currentUser = AuthService.firebase().currentUser;
    final email = currentUser!.email!;
    final owner = await _notesService.getUser(email: email);
    final newNote = await _notesService.createNote(owner: owner);
    _note = newNote;
    return newNote;
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
        future: createOrGetExistingNote(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              if (snapshot.hasData) {
                _setupTextControllerListener();
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
