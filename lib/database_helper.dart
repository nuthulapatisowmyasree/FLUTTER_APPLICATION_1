import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  // ============================================================
  // GET DATABASE
  // ============================================================

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('flutter_application.db');

    return _database!;
  }

  // ============================================================
  // INITIALIZE DATABASE
  // ============================================================

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    final db = await openDatabase(
      path,
      version: 5,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );

    await createDefaultAdmin(db);

    return db;
  }

  // ============================================================
  // CREATE DATABASE TABLES
  // ============================================================

  Future<void> _createDB(
    Database db,
    int version,
  ) async {
    // ----------------------------------------------------------
    // USERS TABLE
    // ----------------------------------------------------------

    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        phone TEXT NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'user'
      )
    ''');

    // ----------------------------------------------------------
    // WASTE REPORTS TABLE
    // ----------------------------------------------------------

    await db.execute('''
      CREATE TABLE waste_reports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        category TEXT NOT NULL,
        description TEXT NOT NULL,
        address TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        image BLOB,
        status TEXT NOT NULL DEFAULT 'Pending',
        createdAt TEXT NOT NULL
      )
    ''');

    // ----------------------------------------------------------
    // NOTIFICATIONS TABLE
    // ----------------------------------------------------------

    await db.execute('''
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        isRead INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // ============================================================
  // DATABASE UPGRADE
  // ============================================================

  Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // ----------------------------------------------------------
    // VERSION 3
    // Create waste_reports and notifications if they don't exist
    // ----------------------------------------------------------

    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS waste_reports (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER NOT NULL,
          category TEXT NOT NULL,
          description TEXT NOT NULL,
          address TEXT NOT NULL,
          latitude REAL NOT NULL,
          longitude REAL NOT NULL,
          image BLOB,
          status TEXT NOT NULL DEFAULT 'Pending',
          createdAt TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS notifications (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER NOT NULL,
          title TEXT NOT NULL,
          message TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          isRead INTEGER NOT NULL DEFAULT 0
        )
      ''');
    }

    // ----------------------------------------------------------
    // VERSION 4
    // Add role column to users table
    // ----------------------------------------------------------

    if (oldVersion < 4) {
      final userColumns = await db.rawQuery(
        'PRAGMA table_info(users)',
      );

      final hasRoleColumn = userColumns.any(
        (column) => column['name'] == 'role',
      );

      if (!hasRoleColumn) {
        await db.execute('''
          ALTER TABLE users
          ADD COLUMN role TEXT NOT NULL DEFAULT 'user'
        ''');
      }
    }

    // ----------------------------------------------------------
    // VERSION 5
    // Remove collectedKg from waste_reports
    // ----------------------------------------------------------

    if (oldVersion < 5) {
      // Check whether waste_reports table exists
      final tables = await db.rawQuery('''
        SELECT name
        FROM sqlite_master
        WHERE type = 'table'
        AND name = 'waste_reports'
      ''');

      if (tables.isNotEmpty) {
        // Check the columns of waste_reports
        final columns = await db.rawQuery(
          'PRAGMA table_info(waste_reports)',
        );

        final hasCollectedKg = columns.any(
          (column) => column['name'] == 'collectedKg',
        );

        // Only rebuild the table if collectedKg exists
        if (hasCollectedKg) {
          // Rename old table
          await db.execute('''
            ALTER TABLE waste_reports
            RENAME TO waste_reports_old
          ''');

          // Create new table without collectedKg
          await db.execute('''
            CREATE TABLE waste_reports (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              userId INTEGER NOT NULL,
              category TEXT NOT NULL,
              description TEXT NOT NULL,
              address TEXT NOT NULL,
              latitude REAL NOT NULL,
              longitude REAL NOT NULL,
              image BLOB,
              status TEXT NOT NULL DEFAULT 'Pending',
              createdAt TEXT NOT NULL
            )
          ''');

          // Copy existing data
          await db.execute('''
            INSERT INTO waste_reports (
              id,
              userId,
              category,
              description,
              address,
              latitude,
              longitude,
              image,
              status,
              createdAt
            )
            SELECT
              id,
              userId,
              category,
              description,
              address,
              latitude,
              longitude,
              image,
              status,
              createdAt
            FROM waste_reports_old
          ''');

          // Delete old table
          await db.execute('''
            DROP TABLE waste_reports_old
          ''');
        }
      } else {
        // If waste_reports doesn't exist, create it
        await db.execute('''
          CREATE TABLE waste_reports (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER NOT NULL,
            category TEXT NOT NULL,
            description TEXT NOT NULL,
            address TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            image BLOB,
            status TEXT NOT NULL DEFAULT 'Pending',
            createdAt TEXT NOT NULL
          )
        ''');
      }

      // Make sure notifications table exists
      await db.execute('''
        CREATE TABLE IF NOT EXISTS notifications (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER NOT NULL,
          title TEXT NOT NULL,
          message TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          isRead INTEGER NOT NULL DEFAULT 0
        )
      ''');
    }
  }

  // ============================================================
  // CREATE / FIX DEFAULT ADMIN
  // ============================================================

  Future<void> createDefaultAdmin(Database db) async {
    final existingAdmin = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: ['admin@wastecare.com'],
      limit: 1,
    );

    if (existingAdmin.isEmpty) {
      await db.insert(
        'users',
        {
          'fullName': 'WasteCare Admin',
          'email': 'admin@wastecare.com',
          'phone': '9999999999',
          'password': 'admin123',
          'role': 'admin',
        },
      );

      debugPrint('DEFAULT ADMIN CREATED');
    } else {
      await db.update(
        'users',
        {
          'fullName': 'WasteCare Admin',
          'phone': '9999999999',
          'password': 'admin123',
          'role': 'admin',
        },
        where: 'email = ?',
        whereArgs: ['admin@wastecare.com'],
      );

      debugPrint('ADMIN VERIFIED / UPDATED');
    }
  }

  // ============================================================
  // CHECK ADMIN
  // ============================================================

  Future<void> checkAdmin() async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: ['admin@wastecare.com'],
      limit: 1,
    );

    debugPrint('ADMIN RECORD: $result');
  }

  // ============================================================
  // USER METHODS
  // ============================================================

  // ------------------------------------------------------------
  // CHECK EMAIL EXISTS
  // ------------------------------------------------------------

  Future<bool> emailExists(String email) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    return result.isNotEmpty;
  }

  // ------------------------------------------------------------
  // INSERT USER
  // ------------------------------------------------------------

  Future<int> insertUser(
    Map<String, dynamic> user,
  ) async {
    final db = await database;

    return await db.insert(
      'users',
      user,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // ------------------------------------------------------------
  // GET ALL USERS
  // ------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;

    return await db.query(
      'users',
      orderBy: 'id DESC',
    );
  }

  // ------------------------------------------------------------
  // LOGIN USER / ADMIN
  // ------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getUser(
    String email,
    String password,
  ) async {
    final db = await database;

    return await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );
  }

  // ------------------------------------------------------------
  // GET USER BY ID
  // ------------------------------------------------------------

  Future<Map<String, dynamic>?> getUserById(
    int userId,
  ) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  // ------------------------------------------------------------
  // GET USER BY EMAIL
  // ------------------------------------------------------------

  Future<Map<String, dynamic>?> getUserByEmail(
    String email,
  ) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  // ------------------------------------------------------------
  // UPDATE USER
  // ------------------------------------------------------------

  Future<int> updateUser(
    Map<String, dynamic> user,
  ) async {
    final db = await database;

    return await db.update(
      'users',
      user,
      where: 'id = ?',
      whereArgs: [user['id']],
    );
  }

  // ------------------------------------------------------------
  // DELETE USER
  // ------------------------------------------------------------

  Future<int> deleteUser(
    int id,
  ) async {
    final db = await database;

    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============================================================
  // WASTE REPORT METHODS
  // ============================================================

  // ------------------------------------------------------------
  // INSERT WASTE REPORT
  // ------------------------------------------------------------

  Future<int> insertWasteReport({
    required int userId,
    required String category,
    required String description,
    required String address,
    required double latitude,
    required double longitude,
    Uint8List? image,
  }) async {
    final db = await database;

    final reportId = await db.insert(
      'waste_reports',
      {
        'userId': userId,
        'category': category,
        'description': description,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'image': image,
        'status': 'Pending',
        'createdAt': DateTime.now().toIso8601String(),
      },
    );

    // Create notification for user
    await insertNotification(
      userId: userId,
      title: 'Waste Report Submitted',
      message:
          'Your $category waste report has been submitted successfully.',
    );

    return reportId;
  }

  // ------------------------------------------------------------
  // GET ALL WASTE REPORTS
  // Includes user details for Admin Panel
  // ------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getWasteReports() async {
    final db = await database;

    return await db.rawQuery('''
      SELECT
        waste_reports.*,
        users.fullName AS userName,
        users.email AS userEmail,
        users.phone AS userPhone
      FROM waste_reports
      LEFT JOIN users
        ON waste_reports.userId = users.id
      ORDER BY waste_reports.createdAt DESC
    ''');
  }

  // ------------------------------------------------------------
  // GET USER REPORTS
  // ------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getUserWasteReports(
    int userId,
  ) async {
    final db = await database;

    return await db.query(
      'waste_reports',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
  }

  // ------------------------------------------------------------
  // GET ONE REPORT
  // ------------------------------------------------------------

  Future<Map<String, dynamic>?> getWasteReportById(
    int reportId,
  ) async {
    final db = await database;

    final result = await db.query(
      'waste_reports',
      where: 'id = ?',
      whereArgs: [reportId],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  // ------------------------------------------------------------
  // UPDATE REPORT STATUS
  // ------------------------------------------------------------

  Future<int> updateWasteReportStatus({
    required int reportId,
    required String status,
  }) async {
    final db = await database;

    return await db.update(
      'waste_reports',
      {
        'status': status,
      },
      where: 'id = ?',
      whereArgs: [reportId],
    );
  }

  // ------------------------------------------------------------
  // DELETE REPORT
  // ------------------------------------------------------------

  Future<int> deleteWasteReport(
    int reportId,
  ) async {
    final db = await database;

    return await db.delete(
      'waste_reports',
      where: 'id = ?',
      whereArgs: [reportId],
    );
  }

  // ============================================================
  // USER DASHBOARD STATISTICS
  // ============================================================

  // ------------------------------------------------------------
  // SUBMITTED REPORTS COUNT
  // ------------------------------------------------------------

  Future<int> getSubmittedReportsCount(
    int userId,
  ) async {
    final db = await database;

    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) AS count
      FROM waste_reports
      WHERE userId = ?
      ''',
      [userId],
    );

    final count = result.first['count'];

    return count is int ? count : 0;
  }

  // ------------------------------------------------------------
  // RESOLVED REPORTS COUNT
  // ------------------------------------------------------------

  Future<int> getResolvedReportsCount(
    int userId,
  ) async {
    final db = await database;

    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) AS count
      FROM waste_reports
      WHERE userId = ?
      AND status = ?
      ''',
      [userId, 'Resolved'],
    );

    final count = result.first['count'];

    return count is int ? count : 0;
  }

  // ============================================================
  // NOTIFICATION METHODS
  // ============================================================

  // ------------------------------------------------------------
  // INSERT NOTIFICATION
  // ------------------------------------------------------------

  Future<int> insertNotification({
    required int userId,
    required String title,
    required String message,
  }) async {
    final db = await database;

    return await db.insert(
      'notifications',
      {
        'userId': userId,
        'title': title,
        'message': message,
        'createdAt': DateTime.now().toIso8601String(),
        'isRead': 0,
      },
    );
  }

  // ------------------------------------------------------------
  // GET USER NOTIFICATIONS
  // ------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getUserNotifications(
    int userId,
  ) async {
    final db = await database;

    return await db.query(
      'notifications',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
  }

  // ------------------------------------------------------------
  // GET ALL NOTIFICATIONS - ADMIN
  // ------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getAllNotifications() async {
    final db = await database;

    return await db.query(
      'notifications',
      orderBy: 'createdAt DESC',
    );
  }

  // ------------------------------------------------------------
  // GET UNREAD NOTIFICATION COUNT
  // ------------------------------------------------------------

  Future<int> getUnreadNotificationCount(
    int userId,
  ) async {
    final db = await database;

    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) AS count
      FROM notifications
      WHERE userId = ?
      AND isRead = 0
      ''',
      [userId],
    );

    final count = result.first['count'];

    return count is int ? count : 0;
  }

  // ------------------------------------------------------------
  // MARK NOTIFICATION AS READ
  // ------------------------------------------------------------

  Future<int> markNotificationAsRead(
    int notificationId,
  ) async {
    final db = await database;

    return await db.update(
      'notifications',
      {
        'isRead': 1,
      },
      where: 'id = ?',
      whereArgs: [notificationId],
    );
  }

  // ------------------------------------------------------------
  // MARK ALL NOTIFICATIONS AS READ
  // ------------------------------------------------------------

  Future<int> markAllNotificationsAsRead(
    int userId,
  ) async {
    final db = await database;

    return await db.update(
      'notifications',
      {
        'isRead': 1,
      },
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  // ------------------------------------------------------------
  // DELETE NOTIFICATION
  // ------------------------------------------------------------

  Future<int> deleteNotification(
    int notificationId,
  ) async {
    final db = await database;

    return await db.delete(
      'notifications',
      where: 'id = ?',
      whereArgs: [notificationId],
    );
  }

  // ============================================================
  // CLOSE DATABASE
  // ============================================================

  Future<void> close() async {
    final db = await database;

    await db.close();

    _database = null;
  }
}