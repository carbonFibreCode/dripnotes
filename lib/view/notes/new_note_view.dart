import 'package:dripnotes/services/auth/auth_service.dart';
import 'package:dripnotes/services/crud/notes_service.dart';
import 'package:flutter/material.dart';

class NewNoteView extends StatefulWidget {
  const NewNoteView({super.key});

  @override
  State<NewNoteView> createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<NewNoteView> {
  DatabaseNotes? _notes;
  late final NotesService _notesService;
  late final TextEditingController _textController;

  @override
  void initState() {
    _notesService = NotesService();
    _textController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final note = _notes;
    if (note == null) {
      return;
    }
    final text = _textController.text;
    await _notesService.updateNotes(
      note: note,
      text: text,
    );
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<DatabaseNotes> createNewNote() async {
    final existingNote = _notes;
    if (existingNote != null) {
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser;
    final email = currentUser!.email!;
    final owner = await _notesService.getUser(email: email);
    return await _notesService.createNotes(owner: owner);
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _notes;
    if (_textController.text.isEmpty && note != null) {
      _notesService.deleteNote(id: note.id);
    }
  }

  void _saveNoteIfTextNotempty() async {
    final note = _notes;
    final text = _textController.text;
    if (note != null && text.isNotEmpty) {
      await _notesService.updateNotes(
        note: note,
        text: text,
      );
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotempty();
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
                if(snapshot.hasData) {
                  _notes = snapshot.data as DatabaseNotes;
                  _setupTextControllerListener();
                }
                return TextField(
                  controller: _textController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: 'start typing your note...'
                  )
                );
              default:
                return const CircularProgressIndicator();
            }
          },
        ));
  }
}
