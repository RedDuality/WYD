import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wyd_front/model/users/view_settings.dart';

class ViewSettingsStorage {
  static const _databaseName = 'viewSettingsStorage.db';
  static const _tableName = 'view_settings';
  static const _databaseVersion = 1;

  static final ViewSettingsStorage _instance = ViewSettingsStorage._internal();
  factory ViewSettingsStorage() => _instance;
  ViewSettingsStorage._internal();

  final _settingsUpdateController = StreamController<ViewSettings>();
  Stream<ViewSettings> get updates => _settingsUpdateController.stream;

  final Map<String, ViewSettings> _inMemoryStorage = {}; // key: "$viewerId:$viewedId"
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
            viewerId TEXT NOT NULL,
            viewedId TEXT NOT NULL,
            viewConfirmed INTEGER NOT NULL,
            viewShared INTEGER NOT NULL,
            PRIMARY KEY (viewerId, viewedId)
          )
        ''');
        await db.execute('CREATE INDEX idx_viewerId ON $_tableName(viewerId)');
        await db.execute('CREATE INDEX idx_viewedId ON $_tableName(viewedId)');
      },
    );
  }

  /// Save or update a single ViewSettings
  Future<void> saveViewSettings(ViewSettings settings) async {
    if (!kIsWeb) {
      final db = await database;
      if (db == null) return;
      await db.insert(
        _tableName,
        settings.toDbMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      _inMemoryStorage['${settings.viewerId}:${settings.viewedId}'] = settings;
    }
    _settingsUpdateController.sink.add(settings);
  }

  /// Save or overwrite multiple ViewSettings
  Future<void> saveMultiple(List<ViewSettings> settingsList) async {
    if (!kIsWeb) {
      final db = await database;
      if (db == null) return;
      await db.transaction((txn) async {
        for (final settings in settingsList) {
          await txn.insert(
            _tableName,
            settings.toDbMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
    } else {
      for (final settings in settingsList) {
        _inMemoryStorage['${settings.viewerId}:${settings.viewedId}'] = settings;
      }
    }

    for (final settings in settingsList) {
      _settingsUpdateController.sink.add(settings);
    }
  }

  /// Retrieve all settings for a given viewerId
  Future<List<ViewSettings>> getByViewerId(String viewerId) async {
    if (kIsWeb) {
      return _inMemoryStorage.values.where((s) => s.viewerId == viewerId).toList();
    }

    final db = await database;
    if (db == null) return [];

    final maps = await db.query(
      _tableName,
      where: 'viewerId = ?',
      whereArgs: [viewerId],
    );

    return maps.map((m) => ViewSettings.fromDbMap(m)).toList();
  }

/*
  /// Retrieve all settings for a given viewedId
  Future<List<ViewSettings>> getByViewedId(String viewedId) async {
    if (kIsWeb) {
      return _inMemoryStorage.values
          .where((s) => s.viewedId == viewedId)
          .toList();
    }

    final db = await database;
    if (db == null) return [];

    final maps = await db.query(
      _tableName,
      where: 'viewedId = ?',
      whereArgs: [viewedId],
    );

    return maps.map((m) => ViewSettings.fromDbMap(m)).toList();
  }
*/
  /// Retrieve a specific viewer/viewed pair
  Future<ViewSettings?> getPair(String viewerId, String viewedId) async {
    if (kIsWeb) {
      return _inMemoryStorage['$viewerId:$viewedId'];
    }

    final db = await database;
    if (db == null) return null;

    final maps = await db.query(
      _tableName,
      where: 'viewerId = ? AND viewedId = ?',
      whereArgs: [viewerId, viewedId],
    );

    if (maps.isNotEmpty) {
      return ViewSettings.fromDbMap(maps.first);
    }
    return null;
  }

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
