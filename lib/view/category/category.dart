import 'package:flutter/material.dart';
import 'package:todolist/controller/todolist_screen_controller.dart';



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
void initState()  {
  super.initState();
 
  getTodosByCategory();
  
}
 



 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      leading:IconButton(
        onPressed: (){
          Navigator.pop(context);
        },
        icon:Icon(Icons.arrow_back),color: Colors.white,),
      title: Text("${widget.category} Todos",style: TextStyle(color: Colors.white),),
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
              
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  
                  
                  title: Text(todoList[index]['title'],style: TextStyle(fontSize: 16,color: Colors.black,fontWeight: FontWeight.bold),),
                  subtitle: Text(todoList[index]['todoDate'],style: TextStyle(fontSize: 10,color: Colors.black,),),
                  
                ),
              );
            },
          ),
  );
}

}