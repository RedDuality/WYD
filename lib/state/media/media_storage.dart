import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wyd_front/state/media/media_flag_storage.dart';

class MediaStorage {
  static const _databaseName = 'cachedMediaStorage.db';
  static const _tableName = 'cached_media';
  static const _databaseVersion = 1;

  static final MediaStorage _instance = MediaStorage._internal();

  factory MediaStorage() => _instance;
  MediaStorage._internal();

  final _eventMediaUpdateController = StreamController<(String eventId, bool deleted)>.broadcast();
  Stream<(String eventId, bool deleted)> get updates => _eventMediaUpdateController.stream;

  final _eventMediaSelectionController = StreamController<(AssetEntity asset, bool selected)>.broadcast();
  Stream<(AssetEntity asset, bool selected)> get selections => _eventMediaSelectionController.stream;

  final _clearAllChannel = StreamController<void>.broadcast();
  Stream<void> get clearChannel => _clearAllChannel.stream;

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
            eventId TEXT,
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
            PRIMARY KEY (eventId, assetId)
          )
        ''');
      },
    );
  }

  Map<String, dynamic> _toMap(String eventId, AssetEntity asset, bool isSelected) {
    return {
      'eventId': eventId,
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

  // overwrites previous records
  Future<void> setCachedMedia(String eventId, Set<AssetEntity> assets) async {
    final db = await database;
    // to delete, call removeAllMedia
    if (db == null || assets.isEmpty) return;
    await db.transaction((txn) async {
      await txn.delete(_tableName, where: 'eventId = ?', whereArgs: [eventId]);

      for (final asset in assets) {
        await txn.insert(
          _tableName,
          _toMap(eventId, asset, true),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });

    MediaFlagStorage().saveEventId(eventId);

    _eventMediaUpdateController.sink.add((eventId, false));
  }

  Future<void> removeAllMedia(String eventId) async {
    final db = await database;
    if (db == null) return;

    _eventMediaUpdateController.sink.add((eventId, true));

    await db.delete(_tableName, where: 'eventId = ?', whereArgs: [eventId]);

    MediaFlagStorage().remove(eventId);
  }

  Future<void> updateSelection(String eventId, AssetEntity asset, bool isSelected) async {
    final db = await database;
    if (db == null) return;

    _eventMediaSelectionController.sink.add((asset, isSelected));

    await db.insert(
      _tableName,
      _toMap(eventId, asset, isSelected),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<AssetEntity, bool>> getMedia(String eventId) async {
    final db = await database;
    if (db == null) return {};
    final result = await db.query(
      _tableName,
      where: 'eventId = ?',
      whereArgs: [eventId],
    );
    return Map.fromEntries(result.map(_fromDbMap));
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
