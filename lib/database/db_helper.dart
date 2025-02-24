import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DbHelper {
  static late Database _db;

  static Future<void> initDb() async {
    // Initialize the database factory for web
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb; // Use FFI for web
    } else {
      databaseFactory = databaseFactoryFfi; // Use FFI for other platforms
    }

    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      join(dbPath, 'reminders.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE reminders(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            isActive INTEGER,
            RemindersTime TEXT,
            category TEXT
          )
        ''');
      },
      version: 1,
    );
  }

  static Future<List<Map<String, dynamic>>> getReminders() async {
    try {
      return await _db.query('reminders');
    } catch (e) {
      print('Error getting reminders: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> getReminder(int id) async {
    try {
      final List<Map<String, dynamic>> result = 
      await _db.query('reminders', where: 'id = ?', whereArgs: [id]);
      if (result.isNotEmpty) {
        return result.first;
      }
      return null;
    } catch (e) {
      print('Error getting reminder with id $id: $e');
      rethrow;
    }
  }

  static Future<int> insertReminder(Map<String, dynamic> reminder) async {
    try {
      return await _db.insert('reminders', reminder);
    } catch (e) {
      print('Error inserting reminder: $e');
      rethrow;
    }
  }

  static Future<void> updateReminder(int id, Map<String, dynamic> reminder) async {
    try {
      await _db.update('reminders', reminder, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('Error updating reminder with id $id: $e');
      rethrow;
    }
  }

  static Future<void> deleteReminder(int id) async {
    try {
      await _db.delete('reminders', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('Error deleting reminder with id $id: $e');
      rethrow;
    }
  }

  static Future<void> toggleReminder(int id, bool isActive) async {
    try {
      await _db.update('reminders', {'isActive': isActive ? 1 : 0}, 
      where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('Error toggling reminder with id $id: $e');
      rethrow;
    }
  }

  static Future<void> addReminder(Map<String, dynamic> newReminder) async {
    try {
      await _db.insert('reminders', newReminder);
    } catch (e) {
      print('Error adding reminder: $e');
      rethrow;
    }
  }
}
