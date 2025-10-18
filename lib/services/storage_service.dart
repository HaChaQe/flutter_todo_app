import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/task.dart';

class StorageService {
  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> encodedTasks =
        tasks.map((t) => jsonEncode({
          'id': t.id,
          'title': t.title,
          'isDone': t.isDone,
          'dueDate': t.dueDate?.toIso8601String(), // DEĞİŞTİ
          'priority': t.priority.index,             // YENİ
          'category': t.category,                   // YENİ
        })).toList();
    prefs.setStringList('tasks', encodedTasks);
  }

  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? encodedTasks = prefs.getStringList('tasks');
    if (encodedTasks == null) return [];
    return encodedTasks.map((t) {
      final data = jsonDecode(t);
      return Task(
        id: data['id'],
        title: data['title'],
        isDone: data['isDone'],
        // DEĞİŞTİ: Tarih null olabilir
        dueDate: data['dueDate'] == null ? null : DateTime.parse(data['dueDate']),
        // YENİ: Öncelik ve kategori okunuyor
        priority: Priority.values[data['priority'] ?? Priority.medium.index],
        category: data['category'] ?? 'Genel',
      );
    }).toList();
  }

  Future<void> clearTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('tasks');
  }
}