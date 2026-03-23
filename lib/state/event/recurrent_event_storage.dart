import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:wyd_front/model/events/recurrent_event.dart';

class RecurrentEventStorage {
  static const _databaseName = 'recurrentEventStorage.db';
  static const _tableName = 'recurrentEvents';
  static const _databaseVersion = 1;

  // --- Singleton Implementation ---
  static final RecurrentEventStorage _instance = RecurrentEventStorage._internal();
  factory RecurrentEventStorage() => _instance;
  RecurrentEventStorage._internal();
  // --------------------------------

  // StreamController notifies the listener that the underlying data in range has changed.
  final _eventUpdateController = StreamController<(RecurrentEvent event, bool deleted)>();
  final _clearAllChannel = StreamController<void>();

  Stream<(RecurrentEvent event, bool deleted)> get updatesChannel => _eventUpdateController.stream;
  Stream<void> get clearChannel => _clearAllChannel.stream;

  // In-memory cache for web/other environments where sqflite isn't used
  final Map<String, RecurrentEvent> _inMemoryStorage = {};

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
            id TEXT PRIMARY KEY,
            title TEXT,
            sTime INTEGER,    -- Storing as Unix timestamp (milliseconds)
            eTime INTEGER,      -- Storing as Unix timestamp (milliseconds)
            updatedAt INTEGER,    -- Storing as Unix timestamp
            rEnd INTEGER,
            rRule TEXT
          )
        ''');
        // sTime: filters masters whose first occurrence starts before range end.
        // rEnd: filters masters whose recurrence ends after range start (NULLs = infinite, also indexed).
        await db.execute('CREATE INDEX idx_recurrent_sTime ON $_tableName(sTime)');
        await db.execute('CREATE INDEX idx_recurrent_rEnd ON $_tableName(rEnd)');
      },
    );
  }

  /// Saves multiple events and emits a single change event.
  Future<void> saveMultiple(List<RecurrentEvent> events) async {
    if (!kIsWeb) {
      final db = await database;
      if (db == null) return;

      await db.transaction((txn) async {
        for (final event in events) {
          await txn.insert(
            _tableName,
            event.toDbMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
    } else {
      for (final event in events) {
        _inMemoryStorage[event.id] = event;
      }
    }
  }

  /// Saves to storage and emits a change event.
  Future<void> saveEvent(RecurrentEvent event) async {
    // Send a signal that data has been modified.
    _eventUpdateController.sink.add((event, false));

    if (!kIsWeb) {
      final db = await database;
      if (db == null) return;
      await db.insert(
        _tableName,
        event.toDbMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      _inMemoryStorage[event.id] = event;
    }
    debugPrint("event added ${event.id}");
  }

  /// Removes an event by its hash and signals a range update.
  Future<void> remove(RecurrentEvent event) async {
    _eventUpdateController.sink.add((event, true));

    if (!kIsWeb) {
      final db = await database;
      if (db == null) return;

      // Delete the event from the SQLite database
      await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [event.id],
      );
    } else {
      // Remove the event from the in-memory cache
      _inMemoryStorage.remove(event.id);
    }
  }

  /// Removes an event by id and emits a delete event to the stream,
  /// letting EventsCache handle the EventController eviction reactively.
  Future<void> removeById(String id) async {
    if (kIsWeb) {
      final event = _inMemoryStorage.remove(id);
      if (event != null) _eventUpdateController.sink.add((event, true));
    } else {
      final db = await database;
      if (db == null) return;
      // Fetch first so we can emit the full Event object on the stream,
      // which _delete needs to identify the right EventController entry.
      final maps = await db.query(_tableName, where: 'id = ?', whereArgs: [id], limit: 1);
      if (maps.isEmpty) return;

      final event = RecurrentEvent.fromDbMap(maps.first);
      _eventUpdateController.sink.add((event, true));

      await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
    }
  }

  Future<RecurrentEvent?> getEventById(String id) async {
    if (kIsWeb) {
      return _inMemoryStorage[id];
    }

    final db = await database;
    if (db == null) return null;

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return RecurrentEvent.fromDbMap(maps.first);
    }
    return null;
  }

  /// Returns master [RecurrentEvent]s that could have occurrences overlapping [range].
  /// Overlap condition: sTime < rangeEnd AND (rEnd IS NULL OR rEnd > rangeStart).
  /// Called by [RecurrentEventStorageService]
  Future<List<RecurrentEvent>> getMastersInRange(DateTimeRange range) async {
    if (kIsWeb) {
      final periodStartMs = range.start.toUtc().millisecondsSinceEpoch;
      final periodEndMs = range.end.toUtc().millisecondsSinceEpoch;

      return _inMemoryStorage.values.where((event) {
        final sTime = event.startTime?.toUtc().millisecondsSinceEpoch;
        final rEnd = event.recurrenceEnd?.toUtc().millisecondsSinceEpoch;
        if (sTime == null) return false;
        return sTime < periodEndMs && (rEnd == null || rEnd > periodStartMs);
      }).toList()
        ..sort((a, b) => a.startTime!.compareTo(b.startTime!));
    } else {
      final db = await database;
      if (db == null) return [];

      final int startTimestamp = range.start.toUtc().millisecondsSinceEpoch;
      final int endTimestamp = range.end.toUtc().millisecondsSinceEpoch;

      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'sTime < ? AND (rEnd IS NULL OR rEnd > ?)',
        whereArgs: [endTimestamp, startTimestamp],
        orderBy: 'sTime ASC',
      );

      return List.generate(maps.length, (i) => RecurrentEvent.fromDbMap(maps[i]));
    }
  }

  Future<void> clearAll() async {
    _clearAllChannel.sink.add(null);
    if (!kIsWeb) {
      final db = await database;
      if (db == null) return;

      await db.delete(_tableName);
    } else {
      _inMemoryStorage.clear();
    }
  }
}
