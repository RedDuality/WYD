import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wyd_front/model/detailed_profile.dart';

class DetailedProfileStorage {
  static const _databaseName = 'detailedProfileStorage.db';
  static const _tableName = 'detailed_profiles';
  static const _databaseVersion = 1;

  // --- Singleton Implementation ---
  static final DetailedProfileStorage _instance = DetailedProfileStorage._internal();
  factory DetailedProfileStorage() => _instance;
  DetailedProfileStorage._internal();
  // --------------------------------

  final _profileUpdateController = StreamController<DetailedProfile>();

  Stream<DetailedProfile> get updates => _profileUpdateController.stream;

  final Map<String, DetailedProfile> _inMemoryStorage = {};
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
            tag TEXT,
            name TEXT,
            color INTEGER,
            blobHash TEXT,
            lastFetched INTEGER NOT NULL,
            updatedAt INTEGER
          )
        ''');
      },
    );
  }

  /// Save or update a single profile
  Future<void> saveProfile(DetailedProfile profile) async {
    if (!kIsWeb) {
      final db = await database;
      if (db == null) return;
      await db.insert(
        _tableName,
        profile.toDbMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      _inMemoryStorage[profile.id] = profile;
    }
    _profileUpdateController.sink.add(profile);
  }

  /// Save or overwrite multiple profiles
  Future<void> saveMultiple(List<DetailedProfile> profiles) async {
    if (!kIsWeb) {
      final db = await database;
      if (db == null) return;
      await db.transaction((txn) async {
        for (final profile in profiles) {
          await txn.insert(
            _tableName,
            profile.toDbMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
    } else {
      for (final profile in profiles) {
        _inMemoryStorage[profile.id] = profile;
      }
    }
    for (final profile in profiles) {
      _profileUpdateController.sink.add(profile);
    }
  }

  /// Retrieve by ID
  Future<DetailedProfile?> getById(String id) async {
    if (kIsWeb) {
      return _inMemoryStorage[id];
    }

    final db = await database;
    if (db == null) return null;

    final maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return DetailedProfile.fromDbMap(maps.first);
    }
    return null;
  }

  void close() {
    _profileUpdateController.close();
  }

  /// Clear all
  Future<void> clearAll() async {
    if (!kIsWeb) {
      final db = await database;
      if (db == null) return;
      await db.delete(_tableName);
    } else {
      _inMemoryStorage.clear();
    }
  }
}
