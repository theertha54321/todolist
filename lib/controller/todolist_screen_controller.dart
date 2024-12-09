import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class TodolistScreenController {
  static late Database database;
  static List<Map> todoList = [];

  // Step 1 -- Initialize database
  static Future<void> initializeDatabase() async {
    if (kIsWeb) {
      // Change default factory on the web
      databaseFactory = databaseFactoryFfiWeb;
    }

    database = await openDatabase(
      "todo.db",
      version: 3, // Incremented version to 3
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE Todo (id INTEGER PRIMARY KEY, title TEXT, category TEXT, todoDate TEXT, todoTime TEXT, isCompleted INTEGER)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          // Add the isCompleted column 
          await db.execute(
            'ALTER TABLE Todo ADD COLUMN isCompleted INTEGER DEFAULT 0', // Default to 0 (not completed)
          );
        }
      },
    );
  }

  static Future<void> addTodo({
    required String title,
    required String category,
    required String todoDate,
    required String todoTime,
    required bool isCompleted  
  }) async {
    await database.rawInsert(
      'INSERT INTO Todo (title, category, todoDate, todoTime, isCompleted) VALUES (?, ?, ?, ?, ?)',
      [title, category, todoDate, todoTime, isCompleted ? 1 : 0], // Store as 1 for true and 0 for false
    );
    await getTodo();
  }

  static Future<void> updateTodo({
    required int id,
    required String title,
    required String category,
    required String todoDate,
    required String todoTime,
    required bool isCompleted, 
  }) async {
    await database.rawUpdate(
      'UPDATE Todo SET title = ?, category = ?, todoDate = ?, todoTime = ?, isCompleted = ? WHERE id = ?',
      [title, category, todoDate, todoTime, isCompleted ? 1 : 0, id], 
    );
    await getTodo();
  }

  static Future<void> deleteTodo({required int id}) async {
    await database.rawDelete('DELETE FROM Todo WHERE id = ?', [id]);
    await getTodo();
  }

  static Future<void> getTodosByCategory(String category) async {
    todoList = await database.rawQuery(
      'SELECT * FROM Todo WHERE category = ?',
      [category],
    );
    log(todoList.toString());
  }

  static Future<void> getTodo() async {
    todoList = await database.rawQuery('SELECT * FROM Todo');
    log(todoList.toString());
  }
}
