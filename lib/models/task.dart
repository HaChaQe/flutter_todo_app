enum Priority { low, medium, high }

class Task {
  String id;
  String title;
  bool isDone;
  DateTime? dueDate;
  Priority priority; 
  String category; 

  Task({
    required this.id,
    required this.title,
    this.isDone = false,
    this.dueDate,
    this.priority = Priority.medium, 
    this.category = 'Genel',     
  });
}