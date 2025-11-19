import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:wyd_front/model/profile_event.dart';

class ProfileEventStorage {
  static const _databaseName = 'profileEvents.db';
  static const _tableName = 'profile_events';
  static const _databaseVersion = 1;

  // --- Singleton Implementation ---
  static final ProfileEventStorage _instance = ProfileEventStorage._internal();
  factory ProfileEventStorage() => _instance;
  ProfileEventStorage._internal();
  // --------------------------------

  // StreamControllers to notify listeners about changes
  final _updateController = StreamController<(ProfileEvent, bool)>();
  Stream<(ProfileEvent, bool)> get updates => _updateController.stream;

  // In-memory cache for web/other environments where sqflite isn't used
  final Map<String, Set<ProfileEvent>> _inMemoryStorage = {};

  static Database? _database;

  Future<Database?> get database async {
    if (kIsWeb) return null;

    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            eventHash TEXT,
            profileHash TEXT,
            confirmed INTEGER,
            role TEXT,
            PRIMARY KEY (eventHash, profileHash)
          )
        ''');
      },
    );
  }

  /// Save a single ProfileEvent
  Future<void> saveSingle(String eventHash, ProfileEvent profileEvent) async {
    if (!kIsWeb) {
      final db = await database;
      if (db == null) return;

      await db.insert(
        _tableName,
        profileEvent.toDbMap(eventHash),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      final existing = _inMemoryStorage[eventHash] ?? <ProfileEvent>{};
      existing.add(profileEvent);
      _inMemoryStorage[eventHash] = existing;
    }

    _updateController.sink.add((profileEvent, false));
  }

  /// Save multiple ProfileEvents
  Future<void> saveMultiple(String eventHash, Set<ProfileEvent> profileEvents) async {
    if (!kIsWeb) {
      final db = await database;
      if (db == null) return;

      await db.transaction((txn) async {
        for (final pe in profileEvents) {
          await txn.insert(
            _tableName,
            pe.toDbMap(eventHash),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
    } else {
      final existing = _inMemoryStorage[eventHash] ?? <ProfileEvent>{};
      existing.addAll(profileEvents);
      _inMemoryStorage[eventHash] = existing;
    }
  }

  /// Get a single ProfileEvent by eventHash + profileHash
  Future<ProfileEvent?> getSingle(String eventHash, String profileHash) async {
    if (!kIsWeb) {
      final db = await database;
      if (db == null) return null;

      final maps = await db.query(
        _tableName,
        where: 'eventHash = ? AND profileHash = ?',
        whereArgs: [eventHash, profileHash],
      );

      if (maps.isNotEmpty) {
        return ProfileEvent.fromDbMap(maps.first);
      }
      return null;
    } else {
      return _inMemoryStorage[eventHash]?.where((pe) => pe.profileHash == profileHash).firstOrNull;
    }
  }

  /// Get all ProfileEvents related to an eventHash
  Future<Set<ProfileEvent>> getAll(String eventHash) async {
    if (!kIsWeb) {
      final db = await database;
      if (db == null) return {};

      final maps = await db.query(
        _tableName,
        where: 'eventHash = ?',
        whereArgs: [eventHash],
      );

      return maps.map((m) => ProfileEvent.fromDbMap(m)).toSet();
    } else {
      return _inMemoryStorage[eventHash] ?? {};
    }
  }

  /// Checks if a given profile has confirmed the event using a direct SQL query.
  Future<bool> hasProfileConfirmed(String eventHash, String profileHash) async {
    if (!kIsWeb) {
      final db = await database;
      if (db == null) return false;

      final result = await db.rawQuery(
        'SELECT confirmed FROM $_tableName '
        'WHERE eventHash = ? AND profileHash = ? LIMIT 1',
        [eventHash, profileHash],
      );

      if (result.isEmpty) return false;
      final confirmedValue = result.first['confirmed'] as int?;
      return confirmedValue == 1;
    } else {
      // Fallback to in-memory check
      final eventProfiles = _inMemoryStorage[eventHash] ?? {};
      return eventProfiles.any((pe) => pe.profileHash == profileHash && pe.confirmed);
    }
  }

  /// Returns the set of profileHashes that are both confirmed and belong to the given [myProfiles].
  Future<Set<String>> profilesThatConfirmed(String eventHash, Set<String> myProfiles) async {
    if (!kIsWeb) {
      final db = await database;
      if (db == null) return {};

      if (myProfiles.isEmpty) return {};

      // Build dynamic placeholders for the IN clause
      final placeholders = List.filled(myProfiles.length, '?').join(',');

      final maps = await db.query(
        _tableName,
        columns: ['profileHash'],
        where: 'eventHash = ? AND confirmed = 1 AND profileHash IN ($placeholders)',
        whereArgs: [eventHash, ...myProfiles],
      );

      return maps.map((m) => m['profileHash'] as String).toSet();
    } else {
      // Fallback to in-memory filtering
      final eventProfiles = _inMemoryStorage[eventHash] ?? {};
      return eventProfiles
          .where((pe) => pe.confirmed && myProfiles.contains(pe.profileHash))
          .map((pe) => pe.profileHash)
          .toSet();
    }
  }

  /// Counts how many ProfileEvents for [eventHash] match the given [userProfileHashes].
  Future<int> countMatchingProfiles(String eventHash, Set<String> userProfileHashes) async {
    if (!kIsWeb) {
      final db = await database;
      if (db == null) return 0;

      if (userProfileHashes.isEmpty) return 0;

      // Build dynamic placeholders for the IN clause
      final placeholders = List.filled(userProfileHashes.length, '?').join(',');

      final result = await db.rawQuery(
        'SELECT COUNT(*) as cnt FROM $_tableName '
        'WHERE eventHash = ? AND profileHash IN ($placeholders)',
        [eventHash, ...userProfileHashes],
      );

      return Sqflite.firstIntValue(result) ?? 0;
    } else {
      // Fallback to in-memory filtering
      final eventProfiles = _inMemoryStorage[eventHash] ?? {};
      return eventProfiles.where((pe) => userProfileHashes.contains(pe.profileHash)).length;
    }
  }

  /// Remove a single ProfileEvent
  Future<void> removeSingle(String eventHash, String profileHash) async {
    if (!kIsWeb) {
      final db = await database;
      if (db == null) return;

      await db.delete(
        _tableName,
        where: 'eventHash = ? AND profileHash = ?',
        whereArgs: [eventHash, profileHash],
      );
    } else {
      _inMemoryStorage[eventHash]?.removeWhere((pe) => pe.profileHash == profileHash);
    }
  }

  /// Remove all ProfileEvents for an event
  Future<void> removeAll(String eventHash) async {
    if (!kIsWeb) {
      final db = await database;
      if (db == null) return;

      await db.delete(
        _tableName,
        where: 'eventHash = ?',
        whereArgs: [eventHash],
      );
    } else {
      _inMemoryStorage.remove(eventHash);
    }
  }
}
