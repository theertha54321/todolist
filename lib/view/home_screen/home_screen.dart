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
    // Example logic: cycle through a list of colors based on the index
    List<Color> colors = [Colors.blue, Colors.green, Colors.orange, Colors.red];
    return colors[index % colors.length];
  }
  
    // Request notification permission
  Future<void> requestNotificationPermission() async {
    final permission = await html.Notification.requestPermission();
    if (permission == 'granted') {
      debugPrint('Notification permission granted.');
    } else {
      debugPrint('Notification permission denied.');
    }
  }

  // Show a notification on the home screen when the scheduled time arrives
  void showReminderNotification(String title, String body) {
    if (html.Notification.permission == 'granted') {
      html.Notification(title, body: body);
    }
  }

  // Schedule the reminder notification at the selected time
  void scheduleReminderNotification(String title, String description, DateTime dateTime) {
    final delay = dateTime.difference(DateTime.now());

    if (delay.isNegative) {
      debugPrint('Scheduled time is in the past. Notification not scheduled.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected time is in the past!')),
      );
      return;
    }

    debugPrint('Reminder scheduled for: $dateTime, Delay: $delay');

    // Schedule the reminder notification
    Timer(delay, () {
      debugPrint('Reminder Timer triggered!');
      showReminderNotification(
        title,
        "$description at ${DateFormat('yyyy-MM-dd hh:mm a').format(dateTime)}",
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
        Scaffold.of(context).openDrawer(); // Use context from Builder
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
            UserAccountsDrawerHeader(
              accountName: Text("Abdul Aziz Ahwan"),
              accountEmail: Text("admin@abdulazizahwan"),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(
                    "https://images.pexels.com/photos/29273395/pexels-photo-29273395/free-photo-of-rainy-window-view-in-belfast.jpeg?auto=compress&cs=tinysrgb&w=600&lazy=load"), // Replace with profile image URL
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            // ListTile(
            //   leading: Icon(Icons.home),
            //   title: Text("Home"),
            //   onTap: () {
            //     // Reset to show all todos
            //     setState(() {
            //       selectedCategory = null;
            //     });
            //     Navigator.pop(context); // Close the drawer
            //   },
            // ),
            ExpansionTile(
              leading: Icon(Icons.category),
              title: Text("Categories"),
              children: [
                ListTile(
                  title: Text("Personal"),
                  onTap: () {
                    // Show only Personal todos
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>CategoryScreen(category: "Personal",)));
                    
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

            // Get the todoDate from the database
          final todoDateString = TodolistScreenController.todoList[index]["todoDate"];
          DateTime? date;

          // Try to parse the date, and if the format is incorrect, handle the error
          try {
            date = DateTime.parse(todoDateString); // Try to parse using ISO format
          } catch (e) {
            // Handle invalid date format (show an error or use a default date)
            date = DateTime.now(); // Default to current date if the format is invalid
          }

          // Format the date for display
          final formattedDate = DateFormat('dd-EEEE-yyyy').format(date); // Format for display
          final day = DateFormat('dd').format(date); // Day number
          final dayName = DateFormat('EEEE').format(date); // Day name
          final year = DateFormat('yyyy').format(date); // Year
        
       return Padding(
         padding: const EdgeInsets.all(8.0),
         child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5)
            ),
            child: ListTile(
             
                title : Row(
                  children: [
                    
                    Text(TodolistScreenController.todoList[index]["title"]),
                    
                  ],
                ) ,
                
                subtitle : Text(TodolistScreenController.todoList[index]["category"]) ,
                // trailing: Text(TodolistScreenController.todoList[index]["description"]),
            
                  
                leading : Container(
                  
                width: 90,
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                  color: _getDateContainerColor(index), // Background color for the container
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
                        
                          value: _checkboxStates[index], // Set the checkbox state from the list
                          onChanged: (bool? newValue) {
                            setState(() {
                              _checkboxStates[index] = newValue!; // Update the checkbox state
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
                            color: Colors.white, // Day color
                          ),
                        ),
                        Text(
                          dayName,
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            color: Colors.white, // Day name color
                          ),
                        ),
                        Text(
                          year,
                          style: const TextStyle(
                            fontSize: 8,
                            color: Colors.white, // Year color
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
        Navigator.push(context, MaterialPageRoute(builder: (context)=>TodolistScreen(onSave: _refreshTodoList,)
        
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
