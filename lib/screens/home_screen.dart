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
      body: ListView.builder(
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
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Colors.grey.shade300, width: 1),
              ),
              title: Text(
                task.title,
                style: TextStyle(
                  fontSize: 20,
                  decoration: task.isDone
                    ? TextDecoration.lineThrough
                    : TextDecoration.none
                ),
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
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("New Task"),
      content: TextField(
        onChanged: (value) => newTaskTitle = value,
        decoration: InputDecoration(hintText: "Task Content"),
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
                ));
            }
            Navigator.pop(context);
            },
          child: Text("Add"),
          ),
        ],
      )
    );
  }
}