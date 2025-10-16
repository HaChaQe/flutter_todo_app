import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/storage_service.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = true;
  final StorageService storage = StorageService();

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;

  TaskProvider(){
    loadTasks();
  }

  void loadTasks() async {
    _tasks = await storage.loadTasks();
    _sortTasks();
    _isLoading = false;
    notifyListeners();
  }

  void addTask(Task task) {
    _tasks.add(task);
    _sortTasks();
    storage.saveTasks(_tasks);
    notifyListeners();
  }

  void toggleTask(Task task) {
    task.isDone = !task.isDone;
    _sortTasks();
    storage.saveTasks(_tasks);
    notifyListeners();
  }

  void removeTask(Task task) {
    _tasks.remove(task);
    _sortTasks();
    storage.saveTasks(_tasks);
    notifyListeners();
  }

  void _sortTasks() {
    _tasks.sort((a, b) {
      // Önce tamamlanmamış görevler tamamlanmışlara göre önde
      if (a.isDone && !b.isDone) return 1;
      if (!a.isDone && b.isDone) return -1;

      // Her ikisi de tamamlanmamış veya tamamlanmışsa, tarihi olan önde
      if (a.dueDate != null && b.dueDate == null) return -1;
      if (a.dueDate == null && b.dueDate != null) return 1;

      // Tarihler ikisi de varsa, yakın tarih önde
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }

      // Diğer durumlarda eşit kalacak
      return 0;
    });
  }

}
