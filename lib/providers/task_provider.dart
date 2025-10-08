import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/storage_service.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  final StorageService storage = StorageService();

  List<Task> get tasks => _tasks;

  TaskProvider(){
    loadTasks();
  }

  void loadTasks() async {
    _tasks = await storage.loadTasks();
    notifyListeners();
  }

  void addTask(Task task) {
    _tasks.add(task);
    storage.saveTasks(_tasks);
    notifyListeners();
  }

  void toggleTask(Task task) {
    task.isDone = !task.isDone;
    storage.saveTasks(_tasks);
    notifyListeners();
  }

  void removeTask(Task task) {
    _tasks.remove(task);
    storage.saveTasks(_tasks);
    notifyListeners();
  }
}
