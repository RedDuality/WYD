import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:wyd_front/model/event.dart';

class EventStorage {
  static const _databaseName = 'eventCache.db';
  static const _tableName = 'events';
  static const _databaseVersion = 1;

  // --- Singleton Implementation ---
  static final EventStorage _instance = EventStorage._internal();
  factory EventStorage() => _instance;
  EventStorage._internal();
  // --------------------------------

  // StreamController notifies ALL listeners that the underlying data in range has changed.
  final _rangeUpdateController = StreamController<DateTimeRange>.broadcast();
  final _eventUpdateController = StreamController<Event>.broadcast();

  Stream<DateTimeRange> get ranges => _rangeUpdateController.stream;
  Stream<Event> get updates => _eventUpdateController.stream;

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
            eventHash TEXT PRIMARY KEY,
            title TEXT,
            startTime INTEGER,    -- Storing as Unix timestamp (milliseconds)
            endTime INTEGER,      -- Storing as Unix timestamp (milliseconds)
            updatedAt INTEGER,    -- Storing as Unix timestamp
            totalConfirmed INTEGER,
            totalProfiles INTEGER,
            hasCachedMedia INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  /// Converts the Dart Event object to a Map for SQLite.
  Map<String, dynamic> _toMap(Event event) {
    return {
      'eventHash': event.eventHash,
      'title': event.title,
      // Convert DateTime to Unix milliseconds for storage
      'startTime': event.startTime!.millisecondsSinceEpoch,
      'endTime': event.endTime!.millisecondsSinceEpoch,
      'updatedAt': event.updatedAt.millisecondsSinceEpoch,
      'totalConfirmed': event.totalConfirmed,
      'totalProfiles': event.totalProfiles,
      'hasCachedMedia': event.hasCachedMedia ? 1 : 0,
    };
  }

  /// Saves to storage and emits a change event.
  Future<void> saveEvent(Event event) async {
    if (!kIsWeb) {
      final db = await database;
      if (db == null) return;
      await db.insert(
        _tableName,
        _toMap(event),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      _inMemoryStorage[event.eventHash] = event;
    }

    // Send a signal that data has been modified.
    _eventUpdateController.sink.add(event);
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
            _toMap(event),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
    } else {
      for (final event in events) {
        _inMemoryStorage[event.eventHash] = event;
      }
    }

    // Send a single signal after all saves are complete.
    _rangeUpdateController.sink.add(range);
  }

  /// Removes an event by its hash and signals a range update.
  Future<void> remove(Event event) async {
    if (!kIsWeb) {
      final db = await database;
      if (db == null) return;

      // Delete the event from the SQLite database
      await db.delete(
        _tableName,
        where: 'eventHash = ?',
        whereArgs: [event.eventHash],
      );
    } else {
      // Remove the event from the in-memory cache
      _inMemoryStorage.remove(event.eventHash);
    }

// TODO get the update correctly
    _rangeUpdateController.sink.add(DateTimeRange(
      start: DateTime.fromMillisecondsSinceEpoch(0),
      end: DateTime.now().add(const Duration(days: 365 * 10)),
    ));
  }

  /// Given a period, this function returns events that overlaps it.
  /// Overlap logic: (E_end > P_start) AND (E_start < P_end)
  Future<List<Event>> getEventsInTimeRange(DateTimeRange range) async {
    if (kIsWeb) {
      return _inMemoryStorage.values.where((event) {
        final eventEndTime = event.endTime?.millisecondsSinceEpoch;
        final eventStartTime = event.startTime?.millisecondsSinceEpoch;
        final periodStartMs = range.start.millisecondsSinceEpoch;
        final periodEndMs = range.end.millisecondsSinceEpoch;

        if (eventEndTime == null || eventStartTime == null) return false;

        return eventEndTime > periodStartMs && eventStartTime < periodEndMs;
      }).toList()
        ..sort((a, b) => a.startTime!.compareTo(b.startTime!));
    } else {
      final db = await database;
      if (db == null) return [];

      final int startTimestamp = range.start.millisecondsSinceEpoch;
      final int endTimestamp = range.end.millisecondsSinceEpoch;

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

  /// Retrieves the next events that directly follows the given time
  Future<Event?> getNextEvent(DateTime time) async {
    final targetMs = time.millisecondsSinceEpoch;

    if (kIsWeb) {
      // Filter and sort events that start after the given time
      final events = _inMemoryStorage.values
          .where((e) => e.startTime != null && e.startTime!.millisecondsSinceEpoch > targetMs)
          .cast<Event>()
          .toList();

      // Return the event with the earliest start time
      return events.isEmpty ? null : events.reduce((a, b) => a.startTime!.isBefore(b.startTime!) ? a : b);
    }

    // SQLite implementation
    final db = await database;
    if (db == null) return null;

    final maps = await db.query(
      _tableName,
      where: 'startTime > ?',
      whereArgs: [targetMs],
      orderBy: 'startTime ASC',
      limit: 1,
    );

    return maps.isNotEmpty ? Event.fromDbMap(maps.first) : null;
  }

  Future<Event?> getEventByHash(String eventHash) async {
    if (kIsWeb) {
      return _inMemoryStorage[eventHash];
    }

    final db = await database;
    if (db == null) return null;

    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'eventHash = ?',
      whereArgs: [eventHash],
    );

    if (maps.isNotEmpty) {
      return Event.fromDbMap(maps.first);
    }
    return null;
  }

  // This should be called when the application is shutting down
  void close() {
    _rangeUpdateController.close();
  }
}
