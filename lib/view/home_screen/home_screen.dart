import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todolist/controller/todolist_screen_controller.dart';
import 'package:todolist/view/category/category.dart';
import 'dart:html' as html;
import 'package:todolist/view/todolist_screen/todolist_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
 String? selectedCategory; 


  List<bool> _checkboxStates = [];

  @override
  void initState() {
    super.initState();
    _refreshTodoList();
    requestNotificationPermission();
   
  }

  Future<void> _refreshTodoList() async {
    await TodolistScreenController.getTodo();
     _checkboxStates = List.generate(TodolistScreenController.todoList.length, (_) => false);
    setState(() {});
  }
  
  Color _getDateContainerColor(int index) {
    
    List<Color> colors = [Colors.blue, Colors.green, Colors.orange, Colors.red];
    return colors[index % colors.length];
  }
  
   
  Future<void> requestNotificationPermission() async {
    final permission = await html.Notification.requestPermission();
    if (permission == 'granted') {
      debugPrint('Notification permission granted.');
    } else {
      debugPrint('Notification permission denied.');
    }
  }

  
  void showReminderNotification(String title, String body) {
    if (html.Notification.permission == 'granted') {
      html.Notification(title, body: body);
    }
  }

  
  void scheduleReminderNotification(String title, DateTime dateTime) {
    final delay = dateTime.difference(DateTime.now());

    if (delay.isNegative) {
      debugPrint('Scheduled time is in the past. Notification not scheduled.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected time is in the past!')),
      );
      return;
    }

    debugPrint('Reminder scheduled for: $dateTime, Delay: $delay');

    
    Timer(delay, () {
      
      showReminderNotification(
        title,
        "${DateFormat('yyyy-MM-dd hh:mm a').format(dateTime)}",
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reminder notification scheduled for $dateTime')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: Builder(
  builder: (BuildContext context) {
    return InkWell(
      onTap: () {
        Scaffold.of(context).openDrawer(); 
      },
      child: Icon(Icons.menu, color: Colors.white),
    );
  },
),

        title: Text(
          selectedCategory == null
              ? "Todolist sqflite"
              : "$selectedCategory Todos",
          style: TextStyle(color: Colors.white),
        ),
      ),
      
      
      
       drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            
            
            ExpansionTile(
              leading: Icon(Icons.category,color: Colors.black,),
              title: Text("Categories", style: TextStyle(color: Colors.black),),
              children: [
                ListTile(
                  title: Text("Personal"),
                  onTap: () {
                    
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>CategoryScreen(category: "Personal"),));
                    
                  },
                ),
                ListTile(
                  title: Text("College"),
                  onTap: () {
                     Navigator.push(context, MaterialPageRoute(builder: (context)=>CategoryScreen(category: "College",)));
                  },
                ),
                ListTile(
                  title: Text("Business"),
                  onTap: () {
                     Navigator.push(context, MaterialPageRoute(builder: (context)=>CategoryScreen(category: "Business",)));
                  }
                ),
              ],
            ),
          ],
        ),
      ),



      body:ListView.builder(
        
        itemCount: TodolistScreenController.todoList.length,
        itemBuilder: (context,index){

           
          final todoDateString = TodolistScreenController.todoList[index]["todoDate"];
          DateTime? date;

          
          try {
            date = DateTime.parse(todoDateString); 
          } catch (e) {
           
            date = DateTime.now(); 
          }

          
          final formattedDate = DateFormat('dd-EEEE-yyyy').format(date); 
          final day = DateFormat('dd').format(date);
          final dayName = DateFormat('EEEE').format(date); 
          final year = DateFormat('yyyy').format(date); 
        
       return Padding(
         padding: const EdgeInsets.all(5.0),
         child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5)
            ),
            child: ListTile(
              onTap: () async {
                final todo = TodolistScreenController.todoList[index];
    await Navigator.push(
       context,
            MaterialPageRoute(
          builder: (context) => TodolistScreen(
          onSave: _refreshTodoList,
          todo: todo,
           ),
        ),
         );
  
              },
             
                subtitle : Row(
                  children: [
                    
                    Text(TodolistScreenController.todoList[index]["title"],style: TextStyle(fontSize: 13,color: Colors.black,fontWeight: FontWeight.w500),),
                    
                  ],
                ) ,
                
                title : Text(TodolistScreenController.todoList[index]["category"],style: TextStyle(fontSize: 16,color: Colors.black,fontWeight: FontWeight.bold),) ,
                trailing: IconButton(
                  onPressed: () async {
                    await TodolistScreenController.deleteTodo(id: TodolistScreenController.todoList[index]['id']);
                    await _refreshTodoList(); 
                  },
                  icon:Icon(Icons.delete)),
            
                  
                leading : Container(
                  
                width: 85,
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                  color: _getDateContainerColor(index), 
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    
                    Transform.scale(
                      scale: .7,
                      child: Checkbox(
                        checkColor: Colors.black,
                        side: BorderSide(color: Colors.transparent),
                        fillColor: WidgetStatePropertyAll(Colors.white),
                        
                          value: _checkboxStates[index], 
                          onChanged: (bool? newValue) {
                            setState(() {
                              _checkboxStates[index] = newValue!; 
                               
                              TodolistScreenController.updateTodo(
                                id: TodolistScreenController.todoList[index]['id'],
                                title: TodolistScreenController.todoList[index]['title'],
                                category: TodolistScreenController.todoList[index]['category'],
                                todoDate: TodolistScreenController.todoList[index]['todoDate'],
                                todoTime: TodolistScreenController.todoList[index]['todoTime'],
                                isCompleted: newValue,
                              );
                            });
                          },
                        ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                     
                        children: [
                          
                        
                        Text(
                          day,
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          dayName,
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          year,
                          style: const TextStyle(
                            fontSize: 8,
                            color: Colors.white, 
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                ),
                             
                  ),
          
          ),
       );
        }
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () async {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>TodolistScreen(onSave: _refreshTodoList,todo: null,)
        
        )
        );
        await _refreshTodoList();
        setState(() {
          
        });
          
        
      },
      child: Icon(Icons.add,color: Colors.white,),
      ),
      
    );
    
  }
}
