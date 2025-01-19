import 'dart:async';
import 'package:dripnotes/extensions/list/filter.dart';
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
  String toString() => "User, ID = $id, email = $email";

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
        text = map[textColumn]?.toString() ?? '',
        isSyncedWithCloud = (map[isSyncedWithCloudColumn] as int?) == 1 {
    print('Creating note from row: $map'); // Debug print
  }

  @override
  String toString() =>
      "Note, ID = $id, userId = $userId, text = $text, isSyncedWithCloud = $isSyncedWithCloud";

  @override
  bool operator ==(covariant DatabaseNotes other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class NotesService {
  Database? _db;
  List<DatabaseNotes> _notes = [];

  DatabaseUser? _user;

  static final NotesService _shared = NotesService._sharedInstance();

  late final StreamController<List<DatabaseNotes>> _notesStreamController;

  NotesService._sharedInstance() {
    _notesStreamController = StreamController<List<DatabaseNotes>>.broadcast(
      onListen: () {
        _notesStreamController.sink.add(_notes);
      },
    );
  }

  factory NotesService() => _shared;

  Stream<List<DatabaseNotes>> get allNotes =>
      _notesStreamController.stream.filter((note) {
        final currentUser = _user;
        if (currentUser != null) {
          return note.userId == currentUser.id;
        } else {
          throw UserShouldBeSetBeforeReadingAllNotes();
        }
      });

  Future<void> verifyDatabaseState() async {
    final db = _getDatabaseOrThrow();

    // Check database content directly
    final dbNotes = await db.query(notesTable);
    print('Database notes: $dbNotes');

    // Check cached notes
    print('Cached notes: $_notes');

    // Check if counts match
    if (dbNotes.length != _notes.length) {
      print(
          'Mismatch between database (${dbNotes.length}) and cache (${_notes.length})');
      await _cacheNotes();
    }
  }

  Future<void> _cacheNotes() async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final notesData = await db.query(notesTable, orderBy: 'id DESC');

    _notes =
        notesData.map((noteRow) => DatabaseNotes.fromRow(noteRow)).toList();
    _notesStreamController.add(_notes);

    print('Refreshed notes count: ${_notes.length}');
    print('Refreshed notes content: $_notes');
  }

  Future<DatabaseUser> getOrCreateUser({
    required String email,
    bool setAsCurrentUser = true,
  }) async {
    try {
      final user = await getUser(email: email);
      if (setAsCurrentUser) {
        _user = user;
      }
      await verifyDatabaseState();
      return user;
    } on CouldNotFindUser {
      final createdUser = await createUser(email: email);
      if (setAsCurrentUser) {
        _user = createdUser;
      }
      await verifyDatabaseState();
      return createdUser;
    }
  }

  Future<DatabaseNotes> updateNote({
    required DatabaseNotes note,
    required String text,
  }) async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    await getNote(id: note.id);

    final updatesCount = await db.update(
        notesTable,
        {
          textColumn: text,
          isSyncedWithCloudColumn: 0,
        },
        where: 'id = ?',
        whereArgs: [note.id]);

    if (updatesCount == 0) {
      throw CouldNotUpdateNote();
    }

    await _cacheNotes();
    await verifyDatabaseState();

    return await getNote(id: note.id);
  }

  Future<Iterable<DatabaseNotes>> getAllNotes() async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final notesData = await db.query(notesTable, orderBy: 'id DESC');

    print('Raw DB data: $notesData');

    final notes = notesData.map((noteRow) {
      final note = DatabaseNotes.fromRow(noteRow);
      print('Mapped note: $note');
      return note;
    }).toList();

    return notes;
  }

  Future<DatabaseNotes> getNote({required int id}) async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final notesData = await db.query(
      notesTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (notesData.isEmpty) {
      throw CouldNotFindNote();
    }

    await _cacheNotes();
    await verifyDatabaseState();

    return DatabaseNotes.fromRow(notesData.first);
  }

  Future<int> deleteAllNotes() async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final numberOfDeletions = await db.delete(notesTable);
    await _cacheNotes();
    await verifyDatabaseState();

    return numberOfDeletions;
  }

  Future<void> deleteNote({required int id}) async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final deletedCount = await db.delete(
      notesTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    }

    await _cacheNotes();
    await verifyDatabaseState();
  }

  Future<DatabaseNotes> createNote({required DatabaseUser owner}) async {
    await ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // Ensure the user exists in the database
    final dbUser = await getUser(email: owner.email);
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

    await _cacheNotes();
    await verifyDatabaseState();

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
    }

    return DatabaseUser.fromRow(results.first);
  }

  Future<DatabaseUser> createUser({required String email}) async {
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
    }
    return db;
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
    } on DatabaseAlreadyOpenedException {
      // ignore
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenedException();
    }

    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      // Create tables
      await db.execute(CreateUserTable);
      await db.execute(CreateTheNotesTable);

      await _cacheNotes();
      await verifyDatabaseState();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
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
const isSyncedWithCloudColumn = 'is_synced_with_server';

const CreateUserTable = '''
  CREATE TABLE IF NOT EXISTS "user" (
    "id"	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "email"	TEXT NOT NULL UNIQUE
  );
''';

const CreateTheNotesTable = '''
  CREATE TABLE IF NOT EXISTS "notes" (
    "id"	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "user_id"	INTEGER NOT NULL REFERENCES user(id),
    "text"	TEXT DEFAULT '',
    "is_synced_with_server"	INTEGER DEFAULT 0
  );
''';
