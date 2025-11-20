import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:wyd_front/model/profile_event.dart';

class ProfileEventsStorage {
  static const _databaseName = 'profileEvents.db';
  static const _tableName = 'profile_events';
  static const _databaseVersion = 1;

  // --- Singleton Implementation ---
  static final ProfileEventsStorage _instance = ProfileEventsStorage._internal();
  factory ProfileEventsStorage() => _instance;
  ProfileEventsStorage._internal();
  // --------------------------------

  // StreamControllers to notify listeners about changes
  final _updateController = StreamController<ProfileEvent>();
  Stream<ProfileEvent> get updates => _updateController.stream;

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
        // Create table
        await db.execute('''
        CREATE TABLE $_tableName (
          eventHash TEXT,
          profileId TEXT,
          role INTEGER,
          confirmed INTEGER,
          trusted INTEGER,
          PRIMARY KEY (eventHash, profileId),
          FOREIGN KEY (eventHash) REFERENCES events(eventHash)
        )
      ''');

        // Create indexes
        await db.execute('CREATE INDEX idx_profile_events_profileId ON $_tableName(profileId)');
        await db.execute('CREATE INDEX idx_profile_events_eventId ON $_tableName(eventId)');
        await db.execute('CREATE INDEX idx_profile_events_confirmed ON $_tableName(confirmed)');
      },
    );
  }

  /// Save a single ProfileEvent
  Future<void> saveSingle(ProfileEvent profileEvent) async {
    if (!kIsWeb) {
      final db = await database;
      if (db == null) return;

      await db.insert(
        _tableName,
        profileEvent.toDbMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      final existing = _inMemoryStorage[profileEvent.eventId] ?? <ProfileEvent>{};
      existing.add(profileEvent);
      _inMemoryStorage[profileEvent.eventId] = existing;
    }
  }

  /// Save multiple ProfileEvents
  Future<void> saveMultiple(String eventId, Set<ProfileEvent> profileEvents) async {
    if (!kIsWeb) {
      final db = await database;
      if (db == null) return;

      await db.transaction((txn) async {
        for (final pe in profileEvents) {
          await txn.insert(
            _tableName,
            pe.toDbMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
    } else {
      final existing = _inMemoryStorage[eventId] ?? <ProfileEvent>{};
      existing.addAll(profileEvents);
      _inMemoryStorage[eventId] = existing;
    }
  }

  Future<void> update(ProfileEvent profileEvent) async {
    if (!kIsWeb) {
      final db = await database;
      if (db == null) return;

      await db.insert(
        _tableName,
        profileEvent.toDbMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      final existing = _inMemoryStorage[profileEvent.eventId] ?? <ProfileEvent>{};
      existing.add(profileEvent);
      _inMemoryStorage[profileEvent.eventId] = existing;
    }

    _updateController.sink.add(profileEvent);
  }

  /// Get a single ProfileEvent by eventHash + profileHash
  Future<ProfileEvent?> getSingle(String eventId, String profileId) async {
    if (!kIsWeb) {
      final db = await database;
      if (db == null) return null;

      final maps = await db.query(
        _tableName,
        where: 'eventHash = ? AND profileHash = ?',
        whereArgs: [eventId, profileId],
      );

      if (maps.isNotEmpty) {
        return ProfileEvent.fromDbMap(maps.first);
      }
      return null;
    } else {
      return _inMemoryStorage[eventId]?.where((pe) => pe.profileId == profileId).firstOrNull;
    }
  }

  /// Get all ProfileEvents related to an eventHash
  Future<Set<ProfileEvent>> getAll(String eventId) async {
    if (!kIsWeb) {
      final db = await database;
      if (db == null) return {};

      final maps = await db.query(
        _tableName,
        where: 'eventHash = ?',
        whereArgs: [eventId],
      );

      return maps.map((m) => ProfileEvent.fromDbMap(m)).toSet();
    } else {
      return _inMemoryStorage[eventId] ?? {};
    }
  }

  Future<Map<String, Set<ProfileEvent>>> getAllForEvents(List<String> eventIds) async {
    if (!kIsWeb) {
      final db = await database;
      if (db == null) return {};

      final maps = await db.query(
        _tableName,
        where: 'eventHash IN (${List.filled(eventIds.length, '?').join(',')})',
        whereArgs: eventIds,
      );

      final result = <String, Set<ProfileEvent>>{};
      for (final m in maps) {
        final pe = ProfileEvent.fromDbMap(m);
        result.putIfAbsent(pe.eventId, () => {}).add(pe);
      }
      return result;
    } else {
      return {for (final e in eventIds) e: _inMemoryStorage[e] ?? {}};
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
      _inMemoryStorage[eventHash]?.removeWhere((pe) => pe.profileId == profileHash);
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
