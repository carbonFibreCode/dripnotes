import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'crud_exceptions.dart';

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });
  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => "Person, ID = $id, email = $email";

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNotes {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseNotes({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });

  DatabaseNotes.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud =
            map[isSyncedWithCloudColumn] as int == 1 ? true : false;

  @override
  String toString() =>
      "Note, ID = id, userId = $userId, isSyncedWithCloud = $isSyncedWithCloud";

  @override
  bool operator ==(covariant DatabaseNotes other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class NotesService {
  Database? _db;

  //Making NotesService a singleton
  static final NotesService _shared = NotesService._sharedInstance();
  NotesService._sharedInstance();
  factory NotesService() => _shared;

  List<DatabaseNotes> _notes = [];

  final _notesStreamController =
      StreamController<List<DatabaseNotes>>.broadcast();

  Stream<List<DatabaseNotes>> get allNotes => _notesStreamController.stream;

  Future<DatabaseUser> getOrCreateUSer({required String email}) async {
    try {
      final user = await getUser(email: email);
      return user;
    } on CouldNotFindUser {
      final createdUser = createuser(email: email);
      return createdUser;
    } catch(e) {
      rethrow;
    }
  }

  Future<void> _cacheNotes() async {
    final allnotes = await getAllNote();
    _notes = allnotes.toList();
    _notesStreamController.add(_notes);
  }

  Future<DatabaseNotes> updateNotes({
    required DatabaseNotes note,
    required String text,
  }) async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    await getNote(id: note.id);

    final updatesCount = await db.update(notesTable, {
      textColumn: text,
      isSyncedWithCloudColumn: 0,
    });
    if (updatesCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      final updateNote = await getNote(id: note.id);
      _notes.removeWhere((notesDel) => note.id == updateNote.id);
      _notes.add(updateNote);
      _notesStreamController.add(_notes);
      return updateNote;
    }
  }

  Future<Iterable<DatabaseNotes>> getAllNote() async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final note = await db.query(notesTable);
    return note.map((noteRow) => DatabaseNotes.fromRow(noteRow));
  }

  Future<DatabaseNotes> getNote({required int id}) async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes =
        await db.query(notesTable, limit: 1, where: 'id = ?', whereArgs: [id]);

    if (notes.isEmpty) {
      throw CouldNotFindNote();
    } else {
      final note = DatabaseNotes.fromRow(notes.first);
      _notes.removeWhere((notesDel) => note.id == id);
      _notes.add(note);
      _notesStreamController.add(_notes);
      return note;
    }
  }

  Future<int> deleteAllNotes() async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final numberOfDeletions = await db.delete(notesTable);
    _notes = [];
    _notesStreamController.add(_notes);
    return numberOfDeletions;
  }

  Future<void> deleteNote({required int id}) async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    } else {
      _notes.removeWhere((notes) => notes.id == id);
      _notesStreamController.add(_notes);
    }
  }

  Future<DatabaseNotes> createNotes({required DatabaseUser owner}) async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final dbUser = getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }

    const text = '';
    final noteId = await db.insert(notesTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSyncedWithCloudColumn: 1,
    });
    final note = DatabaseNotes(
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true,
    );
    //updating the _notes and _notesStreamController
    _notes.add(note);
    _notesStreamController.add(_notes);

    return note;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<DatabaseUser> createuser({required String email}) async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExist();
    }
    final userId =
        await db.insert(userTable, {emailColumn: email.toLowerCase()});

    return DatabaseUser(
      id: userId,
      email: email,
    );
  }

  Future<void> deleteUser({required String email}) async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> ensureDbIsOpen() async {
    try {
      await open();
    } on DatabseAlreadyOpenedException {

    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabseAlreadyOpenedException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      //create the user table, const is at the downside of the file

      //execute the created user table
      await db.execute(CreateUserTable);

      //create the notes table, const is at the downside of the file

      //execute the notes table
      await db.execute(CreateTheNotesTable);
      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirecotry();
    }
  }
}

const dbName = 'dripnotes.db';
const userTable = 'user';
const notesTable = 'notes';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_with_column';
const CreateUserTable = '''
        CREATE TABLE "user" (
	      "id"	INTEGER NOT NULL,
	      "email"	TEXT NOT NULL UNIQUE,
	      PRIMARY KEY("id" AUTOINCREMENT)
        );
      ''';
const CreateTheNotesTable = '''
        CREATE TABLE "notes" (
	      "id"	INTEGER NOT NULL,
	      "user_id"	INTEGER NOT NULL,
	      "text"	TEXT,
	      "is_synced_with_server"	INTEGER DEFAULT 0,
	      PRIMARY KEY("id" AUTOINCREMENT),
	      FOREIGN KEY("user_id") REFERENCES ""
        );
      ''';
