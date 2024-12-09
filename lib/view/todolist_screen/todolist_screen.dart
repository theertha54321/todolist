import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todolist/controller/todolist_screen_controller.dart';
import 'dart:async';
import 'dart:html' as html;

class TodolistScreen extends StatefulWidget {
  final Function onSave; 
  final Map? todo;
  const TodolistScreen({super.key, required this.onSave, required this.todo});

  @override
  State<TodolistScreen> createState() => _TodolistScreenState();
}

class _TodolistScreenState extends State<TodolistScreen> {
  var todoTitleController = TextEditingController();
  var selectedValue;
  var todoDateController = TextEditingController();
  var todoTimeController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

   bool isCompleted = false; 

  @override
  void initState() {
    super.initState();
   

   
  }
  

  void showNotification(String title) {
    html.Notification(title);
  }



  void scheduleNotification(String title, DateTime dateTime) {
    final delay = dateTime.difference(DateTime.now());
    if (delay.isNegative) {
      debugPrint('Scheduled time is in the past. Notification not scheduled.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected time is in the past!')),
      );
      
    }

    String formattedDate = DateFormat('yyyy-MM-dd hh:mm a').format(dateTime);

    Timer(delay, () {
      showNotification("$title at $formattedDate");
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Notification scheduled for $formattedDate')),
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.todo == null ? "Create Todo" : "Edit Todo"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: todoTitleController,
              decoration: InputDecoration(
                labelText: "Plan",
                hintText: "Write Todo Plan",
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
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = pickedDate;
                        todoDateController.text =
                            DateFormat('yyyy-MM-dd').format(pickedDate);
                      });
                    }
                  },
                  child: Icon(Icons.calendar_today),
                ),
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
              value: selectedValue,
              hint: Text("Category"),
              onChanged: (value) {
                selectedValue = value;
                setState(() {});
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor:WidgetStatePropertyAll(Colors.green),
              ),
              onPressed: () {
                final notificationDateTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );

                scheduleNotification(
                  todoTitleController.text,
                  notificationDateTime,
                );
              },
              child: Text(
                "Schedule Notification",
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.green),
              ),
              onPressed: () async {
                if (widget.todo != null) {
                  await TodolistScreenController.updateTodo(
                    id: widget.todo!['id'],
                    title: todoTitleController.text,
                    category: selectedValue,
                    todoDate: todoDateController.text,
                    todoTime: todoTimeController.text,
                    isCompleted: isCompleted
                    

                  );
                } else {
                  await TodolistScreenController.addTodo(
                    title: todoTitleController.text,
                    category: selectedValue,
                    todoDate: todoDateController.text,
                    todoTime: todoTimeController.text,
                    isCompleted: isCompleted
                  );
                }

                widget.onSave();
                Navigator.pop(context);
              },
              child: Text(
                widget.todo == null ? "Save" : "Update",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
