import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';


class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = true;
  final StorageService storage = StorageService();
  final NotificationService _notificationService;

  // YENİ: Filtreleme ve arama için state'ler
  String _searchQuery = '';
  String? _selectedCategory;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;

  // YENİ: Arama ve filtreleme getter'ları (Eksik olan kısım burası)
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;

  // YENİ: Tüm görevlerden benzersiz ve sıralı kategori listesi oluşturan getter
  List<String> get allCategories {
    if (_tasks.isEmpty) {
      return [];
    }
    final categories = _tasks.map((task) => task.category).toSet().toList();
    categories.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return categories;
  }

  // YENİ: Filtrelenmiş ve aranmış görev listesini döndüren getter
  List<Task> get filteredTasks {
    List<Task> filtered = _tasks;

    // Kategoriye göre filtrele
    if (_selectedCategory != null) {
      filtered = filtered.where((task) => task.category == _selectedCategory).toList();
    }

    // Arama sorgusuna göre filtrele
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((task) => task.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    return filtered;
  }

  TaskProvider(this._notificationService) {
    loadTasks();
  }
  
  // YENİ: Arama sorgusunu güncelleyen metod
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // YENİ: Seçili kategoriyi güncelleyen metod
  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
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
    _notificationService.scheduleNotificationForTask(task);
    notifyListeners();
  }

  void updateTask(Task updatedTask) {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      _sortTasks();
      storage.saveTasks(_tasks);
      _notificationService.cancelNotificationForTask(updatedTask);
      _notificationService.scheduleNotificationForTask(updatedTask);
      notifyListeners();
    }
  }

  void toggleTask(Task task) {
    task.isDone = !task.isDone;
    _sortTasks();
    storage.saveTasks(_tasks);
    if (task.isDone){
      _notificationService.cancelNotificationForTask(task);
    }else {
      _notificationService.scheduleNotificationForTask(task);
    }
    notifyListeners();
  }

  void removeTask(Task task) {
    _tasks.remove(task);
    storage.saveTasks(_tasks);
    _notificationService.cancelNotificationForTask(task);
    notifyListeners();
  }

  void _sortTasks() {
    _tasks.sort((a, b) {
      if (a.isDone && !b.isDone) return 1;
      if (!a.isDone && b.isDone) return -1;

      if (a.priority.index > b.priority.index) return -1;
      if (a.priority.index < b.priority.index) return 1;

      if (a.dueDate != null && b.dueDate == null) return -1;
      if (a.dueDate == null && b.dueDate != null) return 1;

      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }
      return 0;
    });
  }
}