import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:wyd_front/model/mask/mask.dart';

class MaskStorage {
  static const _databaseName = 'maskStorage.db';
  static const _tableName = 'masks';
  static const _databaseVersion = 1;

  // --- Singleton Implementation ---
  static final MaskStorage _instance = MaskStorage._internal();
  factory MaskStorage() => _instance;
  MaskStorage._internal();
  // --------------------------------

  // StreamController notifies the listener that the underlying data in range has changed.
  final _rangeUpdateController = StreamController<DateTimeRange>();
  final _maskUpdateController = StreamController<(Mask mask, bool deleted)>();
  final _clearAllChannel = StreamController<void>();

  Stream<DateTimeRange> get rangesChannel => _rangeUpdateController.stream;
  Stream<(Mask mask, bool deleted)> get updatesChannel => _maskUpdateController.stream;
  Stream<void> get clearChannel => _clearAllChannel.stream;

  // In-memory cache for web/other environments where sqflite isn't used
  final Map<String, Mask> _inMemoryStorage = {};

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
            eventId TEXT UNIQUE,
            startTime INTEGER,
            endTime INTEGER, 
            updatedAt INTEGER,
          )
        ''');
      },
    );
  }

  /// Saves multiple masks and emits a single change event.
  Future<void> saveMultiple(List<Mask> masks, DateTimeRange range) async {
    if (!kIsWeb) {
      final db = await database;
      if (db == null) return;

      await db.transaction((txn) async {
        for (final mask in masks) {
          await txn.insert(
            _tableName,
            mask.toDbMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
    } else {
      for (final mask in masks) {
        _inMemoryStorage[mask.id] = mask;
      }
    }

    // Send a single signal after all saves are complete.
    _rangeUpdateController.sink.add(range);
  }

  /// Saves to storage and emits a change event.
  Future<void> saveMask(Mask mask) async {
    // Send a signal that data has been modified.
    _maskUpdateController.sink.add((mask, false));

    if (!kIsWeb) {
      final db = await database;
      if (db == null) return;
      await db.insert(
        _tableName,
        mask.toDbMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      _inMemoryStorage[mask.id] = mask;
    }
  }

  Future<Mask?> getMaskById(String id) async {
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
      return Mask.fromDbMap(maps.first);
    }
    return null;
  }

  /// Given a period, this function returns masks that overlap it.
  /// Overlap logic: (M_end > R_start) AND (M_start < R_end)
  Future<List<Mask>> getMasksInRange(DateTimeRange range) async {
    if (kIsWeb) {
      return _inMemoryStorage.values.where((mask) {
        final maskEndTime = mask.endTime.toUtc().millisecondsSinceEpoch;
        final maskStartTime = mask.startTime.toUtc().millisecondsSinceEpoch;

        final periodStartMs = range.start.toUtc().millisecondsSinceEpoch;
        final periodEndMs = range.end.toUtc().millisecondsSinceEpoch;

        return maskEndTime > periodStartMs && maskStartTime < periodEndMs;
      }).toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
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
        return Mask.fromDbMap(maps[i]);
      });
    }
  }

  Future<void> deleteMask(Mask mask) async {
    _maskUpdateController.sink.add((mask, true));

    if (!kIsWeb) {
      final db = await database;
      if (db == null) return;

      await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [mask.id],
      );
    } else {
      _inMemoryStorage.remove(mask.id);
    }
  }

  /// Removes all masks associated with a specific eventId.
  Future<void> deleteMaskByEventId(String eventId) async {
    List<Mask> masksToDelete = [];

    if (kIsWeb) {
      masksToDelete = _inMemoryStorage.values.where((m) => m.eventId == eventId).toList();
      for (var m in masksToDelete) {
        _inMemoryStorage.remove(m.id);
      }
    } else {
      final db = await database;
      if (db == null) return;

      // Fetch masks before deletion to send update events
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'eventId = ?',
        whereArgs: [eventId],
      );
      masksToDelete = maps.map((m) => Mask.fromDbMap(m)).toList();

      await db.delete(
        _tableName,
        where: 'eventId = ?',
        whereArgs: [eventId],
      );
    }

    // 2. Notify the controller for each deleted mask
    for (final mask in masksToDelete) {
      _maskUpdateController.sink.add((mask, true));
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
