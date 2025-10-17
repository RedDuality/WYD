import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wyd_front/model/enum/role.dart';
import 'package:wyd_front/model/profile.dart';

class ProfileStorage {
  static const _databaseName = 'profileStorage.db';
  static const _tableName = 'profiles';
  static const _databaseVersion = 1;

  // --- Singleton Implementation ---
  static final ProfileStorage _instance = ProfileStorage._internal();
  factory ProfileStorage() => _instance;
  ProfileStorage._internal();
  // --------------------------------

  final _profileUpdateController = StreamController<Profile>.broadcast();

  Stream<Profile> get updates => _profileUpdateController.stream;

  // In-memory cache for web/other environments where sqflite isn't used
  final Map<String, Profile> _inMemoryStorage = {};

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
            lastFetched INTEGER,
            updatedAt INTEGER,
            blobHash TEXT,
            color INTEGER,
            role TEXT,
            mainProfile INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  /// Converts a Profile object to a Map for SQLite.
  Map<String, dynamic> _toMap(Profile profile) {
    return {
      'id': profile.id,
      'tag': profile.tag,
      'name': profile.name,
      'lastFetched': profile.lastFetched.millisecondsSinceEpoch,
      'updatedAt': profile.updatedAt.millisecondsSinceEpoch,
      'blobHash': profile.blobHash,
      'color': profile.color?.toARGB32(),
      'role': profile.role.toString(),
      'mainProfile': profile.mainProfile ? 1 : 0,
    };
  }

  /// Converts a DB map back into a Profile object.
  Profile _fromDbMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] ?? "",
      tag: map['tag'] ?? "",
      name: map['name'] ?? "",
      lastFetched: DateTime.fromMillisecondsSinceEpoch(map['lastFetched']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
      blobHash: map['blobHash'],
      color: map['color'] != null ? Color(map['color']) : null,
      role: Role.values.firstWhere(
        (r) => r.toString() == map['role'],
        orElse: () => Role.viewer,
      ),
      mainProfile: map['mainProfile'] == 1,
    );
  }

  /// Save or update a profile.
  Future<void> saveProfile(Profile profile) async {
    if (!kIsWeb) {
      final db = await database;
      if (db == null) return;
      await db.insert(
        _tableName,
        _toMap(profile),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      _inMemoryStorage[profile.id] = profile;
    }

    _profileUpdateController.sink.add(profile);
  }

  /// Save multiple profiles.
  Future<void> saveMultiple(List<Profile> profiles) async {
    if (!kIsWeb) {
      final db = await database;
      if (db == null) return;
      await db.transaction((txn) async {
        for (final profile in profiles) {
          await txn.insert(
            _tableName,
            _toMap(profile),
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

/*
  /// Remove a profile by ID.
  Future<void> remove(Profile profile) async {
    if (!kIsWeb) {
      final db = await database;
      if (db == null) return;
      await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [profile.id],
      );
    } else {
      _inMemoryStorage.remove(profile.id);
    }
  }
*/
  /// Get a profile by ID.
  Future<Profile?> getProfileById(String id) async {
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
      return _fromDbMap(maps.first);
    }
    return null;
  }

  // This should be called when the application is shutting down
  void close() {
    _profileUpdateController.close();
  }
}
