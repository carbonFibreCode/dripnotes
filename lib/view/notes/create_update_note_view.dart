import 'package:dripnotes/services/auth/auth_service.dart';
import 'package:dripnotes/utilities/dialog/generics/get_arguments.dart';
import 'package:flutter/material.dart';
import 'package:dripnotes/services/cloud/cloud_note.dart';
import 'package:dripnotes/services/cloud/firebase_cloud_storage.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note; // Changed from _notes to _note
  late final FirebaseCloudStorage _notesService;
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _notesService = FirebaseCloudStorage();
    _textController = TextEditingController();
    _setupTextControllerListener();
  }

  void _setupTextControllerListener() {
    final note = _note;
    _textController.addListener(() async {
      if (_note != null) {
        final text = _textController.text;
        await _notesService.updateNote(
          documentId: note!.documentId,
          text: text,
        );
      }
    });
  }

  Future<CloudNote> createOrGetExistingNote() async {
    final widgetNote = context.getArgument<CloudNote>();

    if (widgetNote != null) {
      _note = widgetNote;
      _textController.text = widgetNote.text;
      return widgetNote;
    }

    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }

    final currentUser = AuthService.firebase().currentUser;
    final userId = currentUser!.id;
    final newNote = await _notesService.createNewNote(ownerUserId: userId);
    _note = newNote;
    return newNote;
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (_textController.text.isEmpty && _note != null) {
      _notesService.deleteNote(documentId: note!.documentId);
    }
  }

  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    if (_note != null && text.isNotEmpty) {
      await _notesService.updateNote(
        documentId: note!.documentId,
        text: text,
      );
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
