import 'package:flutter/material.dart';
import 'package:todolist/controller/todolist_screen_controller.dart';
import 'package:todolist/view/todolist_screen/todolist_screen.dart';

class CategoryScreen extends StatefulWidget {
  final String category;
  const CategoryScreen({super.key,required this.category});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
List todoList = [];


getTodosByCategory() async{
   await TodolistScreenController.getTodosByCategory(widget.category);
    setState(() {
    todoList = TodolistScreenController.todoList; 
  });
 
}


@override
void initState() {
  super.initState();
  getTodosByCategory();
}




 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text("${widget.category} Todos"),
      backgroundColor: Colors.green,
    ),
    body: todoList.isEmpty
        ? Center(
            child: Text(
              "No todos available in ${widget.category}",
              style: TextStyle(fontSize: 16),
            ),
          )
        : ListView.builder(
            itemCount: todoList.length,
            itemBuilder: (context, index) {
              final todo = todoList[index]; 
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(todo['title']),
                  subtitle: Text(todo['description']),
                  trailing: Text(todo['todoDate']),
                ),
              );
            },
          ),
  );
}

}