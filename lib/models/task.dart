class Task {
  String id;
  String title;
  bool isDone;
  DateTime? dueDate;

  Task({
    required this.id,
    required this.title,
    this.isDone = false,
    this.dueDate,
  });
}