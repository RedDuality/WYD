import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:wyd_front/model/util/date_time_interval.dart';

class EventIntervalsCacheManager {
  static const _databaseName = 'appointment_cache.db';
  static const _tableName = 'cachedEventIntervals';
  static const _databaseVersion = 1;

  static final EventIntervalsCacheManager _instance = EventIntervalsCacheManager._internal();
  factory EventIntervalsCacheManager() => _instance;
  EventIntervalsCacheManager._internal() {
    if (!kIsWeb) {
      _initDatabase();
      _loadIntervals();
    }
  }

  static Database? _database;
  final List<DateTimeInterval> _cachedIntervals = [];

  Future<void> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);
    _database = await openDatabase(
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

  Future<void> _loadIntervals() async {
    if (_database == null) return;
    final List<Map<String, dynamic>> maps = await _database!.query(_tableName, orderBy: 'start_timestamp ASC');
    _cachedIntervals.clear();
    _cachedIntervals.addAll(maps.map((map) => DateTimeInterval.fromDatabaseMap(map)));
  }

  /// Adds a new interval to the cache, merging it with any existing overlaps and saving it to the database.
  Future<void> addInterval(DateTimeInterval newInterval) async {
    DateTimeInterval mergedInterval = newInterval;

    if (kIsWeb) {
      final overlappingIntervals = _cachedIntervals.where((interval) => interval.overlapsWith(newInterval)).toList();

      if (overlappingIntervals.isNotEmpty) {
        for (final interval in overlappingIntervals) {
          mergedInterval = mergedInterval.merge(interval);
          _cachedIntervals.remove(interval);
        }
      }
    } else {
      if (_database == null) {
        debugPrint("database null");
        return;
      }
      final overlappingIntervals = _cachedIntervals.where((interval) => interval.overlapsWith(newInterval)).toList();

      await _database!.transaction((txn) async {
        if (overlappingIntervals.isNotEmpty) {
          for (final interval in overlappingIntervals) {
            mergedInterval = mergedInterval.merge(interval);
            _cachedIntervals.remove(interval);
            // Delete the old overlapping intervals from the database.
            await txn.delete(
              _tableName,
              where: 'start_timestamp = ?',
              whereArgs: [interval.start.millisecondsSinceEpoch],
            );
          }
          // Insert the new merged interval.
          await txn.insert(_tableName, mergedInterval.toDatabaseMap(), conflictAlgorithm: ConflictAlgorithm.replace);
        }
      });
    }

    _cachedIntervals.add(mergedInterval);
    // Sort the in-memory cache for efficient lookup.
    _cachedIntervals.sort((a, b) => a.start.compareTo(b.start));
  }

  /// Gets the first and last dates of the first missing interval.
  ///
  /// Returns a [DateTimeInterval] representing the missing data, or `null`
  /// if the entire requested range is already in the cache.
  DateTimeInterval? getMissingInterval(DateTimeInterval requestedInterval) {
    // Check if the requested interval is fully covered by existing cache.
    final fullyCovered = _cachedIntervals.any((interval) {
      return !requestedInterval.start.isBefore(interval.start) && !requestedInterval.end.isAfter(interval.end);
    });

    if (fullyCovered) {
      return null;
    }

    // Find the first part of the requested interval that is not in the cache.
    DateTime missingStart = requestedInterval.start;
    for (final interval in _cachedIntervals) {
      if (!missingStart.isBefore(interval.end)) {
        continue;
      }

      if (!missingStart.isBefore(interval.start)) {
        missingStart = interval.end;
      } else {
        break;
      }
    }

    if (!missingStart.isBefore(requestedInterval.end)) {
      return null;
    }

    // Now, find the end of the missing data.
    DateTime missingEnd = requestedInterval.end;
    for (final interval in _cachedIntervals.reversed) {
      if (!missingEnd.isAfter(interval.start)) {
        continue;
      }

      if (!missingEnd.isAfter(interval.end)) {
        missingEnd = interval.start;
      } else {
        break;
      }
    }

    if (missingStart.isBefore(missingEnd)) {
      return DateTimeInterval(missingStart, missingEnd);
    }

    return null;
  }
}
