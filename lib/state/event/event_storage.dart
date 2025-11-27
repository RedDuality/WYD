import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:wyd_front/model/events/event.dart';

class EventStorage {
  static const _databaseName = 'eventStorage.db';
  static const _tableName = 'events';
  static const _databaseVersion = 1;

  // --- Singleton Implementation ---
  static final EventStorage _instance = EventStorage._internal();
  factory EventStorage() => _instance;
  EventStorage._internal();
  // --------------------------------

  // StreamController notifies the listener that the underlying data in range has changed.
  final _rangeUpdateController = StreamController<DateTimeRange>();
  final _eventUpdateController = StreamController<(Event event, bool deleted)>();
  final _clearAllChannel = StreamController<void>();

  Stream<DateTimeRange> get rangesChannel => _rangeUpdateController.stream;
  Stream<(Event event, bool deleted)> get updatesChannel => _eventUpdateController.stream;
  Stream<void> get clearChannel => _clearAllChannel.stream;

  // In-memory cache for web/other environments where sqflite isn't used
  final Map<String, Event> _inMemoryStorage = {};

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
            startTime INTEGER,    -- Storing as Unix timestamp (milliseconds)
            endTime INTEGER,      -- Storing as Unix timestamp (milliseconds)
            updatedAt INTEGER,    -- Storing as Unix timestamp
            totalConfirmed INTEGER,
            totalProfiles INTEGER
          )
        ''');
        await db.execute('CREATE INDEX idx_events_start_end ON $_tableName(startTime, endTime)');
        await db.execute('CREATE INDEX idx_events_endTime ON $_tableName(endTime)');
      },
    );
  }

  /// Saves multiple events and emits a single change event.
  Future<void> saveMultiple(List<Event> events, DateTimeRange range) async {
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

    // Send a single signal after all saves are complete.
    _rangeUpdateController.sink.add(range);
  }

  /// Saves to storage and emits a change event.
  Future<void> saveEvent(Event event) async {
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
  }

  /// Removes an event by its hash and signals a range update.
  Future<void> remove(Event event) async {
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

  Future<Event?> getEventByHash(String id) async {
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
      return Event.fromDbMap(maps.first);
    }
    return null;
  }

  /// Given a period, this function returns events that overlaps it.
  /// Overlap logic: (E_end > R_start) AND (E_start < R_end)
  Future<List<Event>> getEventsInRange(DateTimeRange range) async {
    if (kIsWeb) {
      return _inMemoryStorage.values.where((event) {
        final eventEndTime = event.endTime?.toUtc().millisecondsSinceEpoch;
        final eventStartTime = event.startTime?.toUtc().millisecondsSinceEpoch;

        final periodStartMs = range.start.toUtc().millisecondsSinceEpoch;
        final periodEndMs = range.end.toUtc().millisecondsSinceEpoch;

        if (eventEndTime == null || eventStartTime == null) return false;

        return eventEndTime > periodStartMs && eventStartTime < periodEndMs;
      }).toList()
        ..sort((a, b) => a.startTime!.compareTo(b.startTime!));
    } else {
      final db = await database;
      if (db == null) return [];

      final int startTimestamp = range.start.toUtc().millisecondsSinceEpoch;
      final int endTimestamp = range.end.toUtc().millisecondsSinceEpoch;

      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'endTime > ? AND startTime < ?',
        whereArgs: [startTimestamp, endTimestamp],
        orderBy: 'startTime ASC',
      );

      return List.generate(maps.length, (i) {
        return Event.fromDbMap(maps[i]);
      });
    }
  }

  /// Returns events whose endTime falls inside the given range.
  Future<List<Event>> getEventsEndingInRange(DateTimeRange range) async {
    if (kIsWeb) {
      final periodStartMs = range.start.toUtc().millisecondsSinceEpoch;
      final periodEndMs = range.end.toUtc().millisecondsSinceEpoch;

      return _inMemoryStorage.values.where((event) {
        final eventEndTime = event.endTime?.toUtc().millisecondsSinceEpoch;
        if (eventEndTime == null) return false;

        return eventEndTime >= periodStartMs && eventEndTime <= periodEndMs;
      }).toList()
        ..sort((a, b) => a.endTime!.compareTo(b.endTime!));
    } else {
      final db = await database;
      if (db == null) return [];

      final int startTimestamp = range.start.toUtc().millisecondsSinceEpoch;
      final int endTimestamp = range.end.toUtc().millisecondsSinceEpoch;

      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'endTime >= ? AND endTime <= ?',
        whereArgs: [startTimestamp, endTimestamp],
        orderBy: 'endTime ASC',
      );

      return List.generate(maps.length, (i) {
        return Event.fromDbMap(maps[i]);
      });
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
