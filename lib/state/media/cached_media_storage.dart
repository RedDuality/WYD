import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sqflite/sqflite.dart';

class CachedMediaStorage {
  static const _databaseName = 'cachedMediaStorage.db';
  static const _tableName = 'cached_media';
  static const _databaseVersion = 1;

  static final CachedMediaStorage _instance = CachedMediaStorage._internal();
  factory CachedMediaStorage() => _instance;
  CachedMediaStorage._internal();

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
    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            eventHash TEXT,
            assetId TEXT,
            typeInt INTEGER,
            width INTEGER,
            height INTEGER,
            duration INTEGER,
            orientation INTEGER,
            isFavorite INTEGER,
            title TEXT,
            createDateSecond INTEGER,
            modifiedDateSecond INTEGER,
            relativePath TEXT,
            latitude REAL,
            longitude REAL,
            mimeType TEXT,
            subtype INTEGER,
            isSelected INTEGER,
            PRIMARY KEY (eventHash, assetId)
          )
        ''');
      },
    );
  }

  Map<String, dynamic> _toMap(String eventHash, AssetEntity asset, bool isSelected) {
    return {
      'eventHash': eventHash,
      'assetId': asset.id,
      'typeInt': asset.typeInt,
      'width': asset.width,
      'height': asset.height,
      'duration': asset.duration,
      'orientation': asset.orientation,
      'isFavorite': asset.isFavorite ? 1 : 0,
      'title': asset.title,
      'createDateSecond': asset.createDateSecond,
      'modifiedDateSecond': asset.modifiedDateSecond,
      'relativePath': asset.relativePath,
      'latitude': asset.latitude,
      'longitude': asset.longitude,
      'mimeType': asset.mimeType,
      'subtype': asset.subtype,
      'isSelected': isSelected ? 1 : 0,
    };
  }

  MapEntry<AssetEntity, bool> _fromDbMap(Map<String, dynamic> map) {
    final asset = AssetEntity(
      id: map['assetId'],
      typeInt: map['typeInt'],
      width: map['width'],
      height: map['height'],
      duration: map['duration'],
      orientation: map['orientation'],
      isFavorite: map['isFavorite'] == 1,
      title: map['title'],
      createDateSecond: map['createDateSecond'],
      modifiedDateSecond: map['modifiedDateSecond'],
      relativePath: map['relativePath'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      mimeType: map['mimeType'],
      subtype: map['subtype'],
    );
    return MapEntry(asset, map['isSelected'] == 1);
  }

  Future<void> setMedia(String eventHash, Set<AssetEntity> assets) async {
    final db = await database;
    if (db == null) return;
    await db.transaction((txn) async {
      for (final asset in assets) {
        await txn.insert(
          _tableName,
          _toMap(eventHash, asset, true),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> removeMedia(String eventHash) async {
    final db = await database;
    if (db == null) return;
    await db.delete(_tableName, where: 'eventHash = ?', whereArgs: [eventHash]);
  }

  Future<void> updateSelection(String eventHash, AssetEntity asset, bool isSelected) async {
    final db = await database;
    if (db == null) return;
    await db.insert(
      _tableName,
      _toMap(eventHash, asset, isSelected),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<AssetEntity, bool>> getMedia(String eventHash) async {
    final db = await database;
    if (db == null) return {};
    final result = await db.query(
      _tableName,
      where: 'eventHash = ?',
      whereArgs: [eventHash],
    );
    return Map.fromEntries(result.map(_fromDbMap));
  }

  Future<void> clearAll() async {
    if (!kIsWeb) {
      final db = await database;
      if (db == null) return;
      await db.delete(_tableName);
    }
  }
}
