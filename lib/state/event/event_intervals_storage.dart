import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:wyd_front/model/util/date_time_interval.dart';
import 'package:wyd_front/state/util/intervals_cache.dart';

class EventIntervalsStorage implements IntervalStorage{
  static const _databaseName = 'appointment_cache.db';
  static const _tableName = 'cachedEventIntervals';
  static const _databaseVersion = 1;

  static Database? _database;

  static final EventIntervalsStorage _instance = EventIntervalsStorage._internal();
  factory EventIntervalsStorage() => _instance;
  EventIntervalsStorage._internal();

  final _clearAllChannel = StreamController<void>();
  @override
  Stream<void> get clearChannel => _clearAllChannel.stream;

  Future<Database?> get database async {
    if (kIsWeb) return null;

    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName(
            start_timestamp INTEGER PRIMARY KEY,
            end_timestamp INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  @override
  Future<List<Map<String, dynamic>>> loadIntervals() async {
    final db = await database;
    if (db == null) return [];

    return await db.query(_tableName, orderBy: 'start_timestamp ASC');
  }

  @override
  Future<void> addInterval(DateTimeRange newInterval, List<DateTimeRange<DateTime>> overWrittenIntervals) async {
    final db = await database;
    if (db == null) return;
    await db.transaction((txn) async {
      // Delete the old overlapping intervals from the database.
      if (overWrittenIntervals.isNotEmpty) {
        for (final interval in overWrittenIntervals) {
          await txn.delete(
            _tableName,
            where: 'start_timestamp = ?',
            whereArgs: [interval.start.millisecondsSinceEpoch],
          );
        }
      }
      // Insert the new merged interval.
      await txn.insert(_tableName, newInterval.toDatabaseMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<void> clearAll() async {
    _clearAllChannel.sink.add(null);
    if (!kIsWeb) {
      final db = await database;
      if (db == null) return;

      await db.delete(_tableName);
    }
  }
}
