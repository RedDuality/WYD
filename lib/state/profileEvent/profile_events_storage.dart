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
  final _updateChannel = StreamController<ProfileEvent>();
  Stream<ProfileEvent> get updatesChannel => _updateChannel.stream;

  final _deleteChannel = StreamController<(String, String)>();
  Stream<(String, String)> get deleteChannel => _deleteChannel.stream;

  final _deleteAllChannel = StreamController<String>();
  Stream<String> get deleteAllChannel => _deleteAllChannel.stream;

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
          eventId TEXT,
          profileId TEXT,
          role INTEGER,
          confirmed INTEGER,
          trusted INTEGER,
          PRIMARY KEY (eventId, profileId),
          FOREIGN KEY (eventId) REFERENCES events(eventId)
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

    _updateChannel.sink.add(profileEvent);
  }

  /// Get a single ProfileEvent by eventId + profileId
  Future<ProfileEvent?> getSingle(String eventId, String profileId) async {
    if (!kIsWeb) {
      final db = await database;
      if (db == null) return null;

      final maps = await db.query(
        _tableName,
        where: 'eventId = ? AND profileId = ?',
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

  /// Get all ProfileEvents related to an eventId
  Future<Set<ProfileEvent>> getAll(String eventId) async {
    if (!kIsWeb) {
      final db = await database;
      if (db == null) return {};

      final maps = await db.query(
        _tableName,
        where: 'eventId = ?',
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
        where: 'eventId IN (${List.filled(eventIds.length, '?').join(',')})',
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

  /// Count how many of the given profileIds are present for a specific eventId
  Future<int> countMatchingProfiles(String eventId, Set<String> profileIds) async {
    if (!kIsWeb) {
      final db = await database;
      if (db == null) return 0;

      // Query only the rows that match eventId and profileIds
      final maps = await db.query(
        _tableName,
        columns: ['profileId'],
        where: 'eventId = ? AND profileId IN (${List.filled(profileIds.length, '?').join(',')})',
        whereArgs: [eventId, ...profileIds],
      );

      return maps.length;
    } else {
      final eventProfiles = _inMemoryStorage[eventId] ?? {};
      return eventProfiles.where((pe) => profileIds.contains(pe.profileId)).length;
    }
  }

  /// Remove a single ProfileEvent
  Future<void> removeSingle(String eventId, String profileId) async {
    if (!kIsWeb) {
      final db = await database;
      if (db == null) return;

      await db.delete(
        _tableName,
        where: 'eventId = ? AND profileId = ?',
        whereArgs: [eventId, profileId],
      );
    } else {
      _inMemoryStorage[eventId]?.removeWhere((pe) => pe.profileId == profileId);
    }
    _deleteChannel.sink.add((eventId, profileId));
  }

  /// Remove all ProfileEvents for an event
  Future<void> removeAll(String eventId) async {
    if (!kIsWeb) {
      final db = await database;
      if (db == null) return;

      await db.delete(
        _tableName,
        where: 'eventId = ?',
        whereArgs: [eventId],
      );
    } else {
      _inMemoryStorage.remove(eventId);
    }
    _deleteAllChannel.sink.add(eventId);
  }
}
