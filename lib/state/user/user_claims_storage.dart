import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wyd_front/model/users/user_claim.dart';

class UserClaimStorage {
  static const _databaseName = 'userClaimStorage.db';
  static const _tableName = 'user_claims';
  static const _databaseVersion = 1;

  final Map<String, List<UserClaim>> _inMemoryStorage = {}; // profileId → claims
  static Database? _database;

  // --- Singleton Implementation ---
  static final UserClaimStorage _instance = UserClaimStorage._internal();
  factory UserClaimStorage() => _instance;
  UserClaimStorage._internal();
  // --------------------------------

  final _clearAllChannel = StreamController<void>();
  Stream<void> get clearChannel => _clearAllChannel.stream;
  
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
            profileId TEXT NOT NULL,
            claim TEXT NOT NULL,
            PRIMARY KEY (profileId, claim)
          )
        ''');
        await db.execute('CREATE INDEX idx_profileId ON $_tableName(profileId)');
      },
    );
  }

  /// Save or update a single UserClaim
  Future<void> saveClaim(UserClaim claim) async {
    if (!kIsWeb) {
      final db = await database;
      if (db == null) return;
      await db.insert(
        _tableName,
        claim.toDbMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      final claims = _inMemoryStorage[claim.profileId] ?? [];
      claims.removeWhere((c) => c.claim == claim.claim);
      claims.add(claim);
      _inMemoryStorage[claim.profileId] = claims;
    }
  }

  /// Save or overwrite multiple UserClaims
  Future<void> saveMultiple(List<UserClaim> claims) async {
    if (!kIsWeb) {
      final db = await database;
      if (db == null) return;
      await db.transaction((txn) async {
        for (final claim in claims) {
          await txn.insert(
            _tableName,
            claim.toDbMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
    } else {
      for (final claim in claims) {
        final list = _inMemoryStorage[claim.profileId] ?? [];
        list.removeWhere((c) => c.claim == claim.claim);
        list.add(claim);
        _inMemoryStorage[claim.profileId] = list;
      }
    }
  }

  /// Retrieve all claims for a given profileId
  Future<List<UserClaim>> getByProfileId(String profileId) async {
    if (kIsWeb) {
      return _inMemoryStorage[profileId] ?? [];
    }

    final db = await database;
    if (db == null) return [];

    final maps = await db.query(
      _tableName,
      where: 'profileId = ?',
      whereArgs: [profileId],
    );

    return maps.map((m) => UserClaim.fromDbMap(m)).toList();
  }

  /// ✅ Check if a profile has a specific claim
  Future<bool> hasClaim(String profileId, String claim) async {
    if (kIsWeb) {
      final claims = _inMemoryStorage[profileId] ?? [];
      return claims.any((c) => c.claim == claim);
    }

    final db = await database;
    if (db == null) return false;

    final maps = await db.query(
      _tableName,
      where: 'profileId = ? AND claim = ?',
      whereArgs: [profileId, claim],
      limit: 1,
    );

    return maps.isNotEmpty;
  }

  /// Clear all claims
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
