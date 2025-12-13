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
  final _eventUpdateController = StreamController<(Mask mask, bool deleted)>();
  final _clearAllChannel = StreamController<void>();

  Stream<DateTimeRange> get rangesChannel => _rangeUpdateController.stream;
  Stream<(Mask mask, bool deleted)> get updatesChannel => _eventUpdateController.stream;
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
            eventId TEXT,
            startTime INTEGER,
            endTime INTEGER, 
            updatedAt INTEGER,
          )
        ''');
      },
    );
  }

  /// Saves to storage and emits a change event.
  Future<void> saveMask(Mask mask) async {
    // Send a signal that data has been modified.
    _eventUpdateController.sink.add((mask, false));

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
