import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todolist/controller/todolist_screen_controller.dart';
import 'dart:async';
import 'dart:html' as html;


class TodolistScreen extends StatefulWidget {
  final Function onSave; // Callback function to refresh the list



  const TodolistScreen({super.key,required this.onSave});

  @override
  State<TodolistScreen> createState() => _TodolistScreenState();
}

class _TodolistScreenState extends State<TodolistScreen> {
  var todoTitleController = TextEditingController();

  var todoDescriptionController=TextEditingController();

 

  var selectedValue;
  
  var todoDateController = TextEditingController();
   var todoTimeController = TextEditingController();

  
  
  DateTime selectedDate= DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();


  // Request notification permission when the widget initializes
  @override
  void initState() {
    super.initState();
    requestNotificationPermission();
  }

  /// Request notification permission
  Future<void> requestNotificationPermission() async {
    final permission = await html.Notification.requestPermission();
    if (permission == 'granted') {
      debugPrint('Notification permission granted.');
    } else {
      debugPrint('Notification permission denied.');
    }
  }

  /// Show a notification
  void showNotification(String title, String body) {
    html.Notification(title, body: body);
  }

  /// Schedule a notification for the selected date and time
  void scheduleNotification(String title, String description, DateTime dateTime) {
    final delay = dateTime.difference(DateTime.now());
    if (delay.isNegative) {
      debugPrint('Scheduled time is in the past. Notification not scheduled.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected time is in the past!')),
      );
      return;
    }
     // Format the DateTime for the notification
    String formattedDate = DateFormat('yyyy-MM-dd hh:mm a').format(dateTime);

    // Schedule the notification
    Timer(delay, () {
      showNotification(
        title,
        "$description at $formattedDate",
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Notification scheduled for $formattedDate')),
    );
  }




  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Todo"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: todoTitleController,
              decoration: InputDecoration(
                labelText: "Title",
                hintText: "Write Todo title"
              ),
            ),
             TextField(
              controller: todoDescriptionController,
              decoration: InputDecoration(
                labelText: "Description",
                hintText: "Write Todo Description"
              ),
            ),
             TextField(
              controller: todoDateController,
              decoration: InputDecoration(
                labelText: "Date",
                hintText: "Pick",
                prefixIcon: InkWell(
                  onTap: () async {
                     DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000), // Earliest date allowed
                      lastDate: DateTime(2100),  // Latest date allowed
                    );
                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = pickedDate;
                        // Format the date using Intl package
                        todoDateController.text =
                            DateFormat('yyyy-MM-dd').format(pickedDate);
                      });
                    }
                  },
                  child: Icon(Icons.calendar_today),
                )
              ),
            ),
            TextField(
              controller: todoTimeController,
              decoration: InputDecoration(
                labelText: "Time",
                hintText: "Pick",
                prefixIcon: InkWell(
                  onTap: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (pickedTime != null) {
                      setState(() {
                        selectedTime = pickedTime;
                        todoTimeController.text = pickedTime.format(context);
                      });
                    }
                  },
                  child: Icon(Icons.access_time),
                ),
              ),
            ),
            DropdownButtonFormField(
              
              items: [
                  DropdownMenuItem(value: "College", child: Text("College")),
                  DropdownMenuItem(value: "Personal", child: Text("Personal")),
                  DropdownMenuItem(value: "Business", child: Text("Business")),
  ],
              value:selectedValue ,
              hint: Text("Category"),
            
            onChanged: (value){
              selectedValue=value;
              setState(() {
                
              });
            }
            ),
            SizedBox(
              height: 20,
              
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.green)
              ),
              onPressed: () async {
                await TodolistScreenController.addTodo(title: todoTitleController.text, description: todoDescriptionController.text, category:selectedValue , todoDate: todoDateController.text);
                 widget.onSave();
                  Navigator.pop(context);
            
        
          
            }, 
            child: Text("Save",style: TextStyle(color: Colors.white),)
            ),
           SizedBox(height: 30,),
            ElevatedButton(
              onPressed: () {
                if (todoTitleController.text.isEmpty ||
                    todoDescriptionController.text.isEmpty ||
                    todoDateController.text.isEmpty ||
                    todoTimeController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all fields.')),
                  );
                  return;
                }

                final notificationDateTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );

                scheduleNotification(
                  todoTitleController.text,
                  todoDescriptionController.text,
                  notificationDateTime,
                );
              },
              child: Text("Schedule Notification"),
            ),
          ],
        ),
      ),
    );
  }
}