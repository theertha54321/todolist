

import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class TodolistScreenController{
static late Database database;
static List<Map> todoList = [];
  // step 1 -- initialize db
static Future<void> initializeDatabase() async {
  if (kIsWeb) {
  // Change default factory on the web
  databaseFactory = databaseFactoryFfiWeb;
  
}

  database = await openDatabase("todo.db",version: 1,onCreate: (db,version) async {

// await db.execute('CREATE TABLE Categories (id INTEGER PRIMARY KEY, title TEXT, description TEXT)');

     await db.execute(
      'CREATE TABLE Todo (id INTEGER PRIMARY KEY, title TEXT, description TEXT,category TEXT,todoDate TEXT)');

  });



}


static Future<void> addTodo({required String title, required String description,required String category,required String todoDate}) async {
 await database.rawInsert('INSERT INTO Todo(title,description,category,todoDate) VALUES(?,?,?,?)',
 [title,description,category,todoDate]
 );
await getTodo();
}




//  static Future<void> updateTodo({
//     required int id,
//     required String title,
//     required String description,
//     required String category,
//     required String todoDate,
//   }) async {
//     await database.rawUpdate(
//       'UPDATE Todo SET title = ?, description = ?, category = ?, todoDate = ? WHERE id = ?',
//       [title, description, category, todoDate, id],
//     );
//     await getTodo(); 
//   }



  
  // static Future<void> deleteTodo({required int id}) async {
  //   await database.rawDelete('DELETE FROM Todo WHERE id = ?', [id]);
  //   await getTodo(); 
  // }




static Future<void> getTodosByCategory(String category) async {
  todoList = await database.rawQuery(
    'SELECT * FROM Todo WHERE category = ?',
    [category],
  );
  log(todoList.toString());
}




static Future<void> getTodo() async {
 todoList= await database.rawQuery('SELECT * FROM Todo');
log(todoList.toString());
}

}
