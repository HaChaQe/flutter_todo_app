import 'package:flutter/material.dart';
import '../models/task.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build (BuildContext context){
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber.shade300,
        title: Text("TO-DO's", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        elevation: 2,
        shadowColor: Colors.black
      ),
      body: taskProvider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : taskProvider.tasks.isEmpty
          ? const Center(
            child: Text(
              "Henüz görev yok!",
              style: TextStyle(fontSize:18, color: Colors.grey )
            )
          )
          : ListView.builder(
        itemCount: taskProvider.tasks.length,
        itemBuilder: (context, index) {
          final task = taskProvider.tasks[index];
          return Dismissible(
            key: Key(task.id),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              child: const Icon(Icons.delete, color: Colors.white, size: 30),
            ),
            secondaryBackground: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white, size: 30),
            ),
            confirmDismiss: (direction) async {
              return await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text("Are you sure?"),
                content: Text("Do you want to delete this goal?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text("Cancel")
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text("Delete")
                  ),
                ],
              )
              );
            },
            onDismissed: (_){
              final removedTask = task;
              taskProvider.removeTask(task);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"${removedTask.title}" removed'),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () {
                      taskProvider.addTask(removedTask);
                    }
                  ),
                )
              );
            },
            child: ListTile(
              tileColor: task.isDone ? Colors.grey.shade200 : Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Colors.grey.shade300, width: 1),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 20,
                      color: task.isDone ? Colors.grey.shade600 : Colors.black,
                      decoration: task.isDone
                        ? TextDecoration.lineThrough
                        : TextDecoration.none
                    ),
                  ),
                  if (task.dueDate != null)
                    Text(
                      "${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}",
                      style: TextStyle(
                        fontSize: 14,
                        color: task.isDone ? Colors.grey.shade500 : Colors.grey.shade600
                        ),
                    )
                ],
              ),
              trailing: Checkbox(
                activeColor: Colors.amber,
                checkColor: Colors.white,
                value: task.isDone,
                onChanged: (_) {
                  taskProvider.toggleTask(task);
                }
              ),
            ),
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber.shade300,
        onPressed: ()=> _addTaskDialog(context, taskProvider),
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 35,
          ),
      ),
    );
  }

  void _addTaskDialog(BuildContext context, TaskProvider provider) {
  String newTaskTitle = '';
  DateTime? selectedDate;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text("New Goal"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: (value) => newTaskTitle = value,
              decoration: InputDecoration(hintText: "Goal Header"),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text(
                  selectedDate == null
                      ? "Tarih seçilmedi"
                      : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                ),
                Spacer(),
                TextButton(
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => selectedDate = picked);
                  },
                  child: Text("Choose Date"),
                ),
              ],
            ),
          ],
        ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            if (newTaskTitle.isNotEmpty) {
              provider.addTask(Task(
                id: DateTime.now().microsecondsSinceEpoch.toString(),
                title: newTaskTitle,
                dueDate: selectedDate,
                ));
            }
            Navigator.pop(context);
            },
          child: Text("Add"),
          ),
        ],
      )
    )
    );
  }
}