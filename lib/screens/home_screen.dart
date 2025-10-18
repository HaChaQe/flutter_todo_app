import 'package:flutter/material.dart';
import '../models/task.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

// StatefulWidget'a dönüştürülmüştü
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // EKSİK OLAN KISIM: Arama durumu için değişkenler
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  // Önceliğe göre renk döndüren yardımcı metod
  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.red.shade300;
      case Priority.medium:
        return Colors.orange.shade300;
      case Priority.low:
        return Colors.green.shade300;
      default:
        return Colors.grey.shade300;
    }
  }

  // EKSİK OLAN KISIM: Arama ve normal durum için AppBar oluşturan metod
  AppBar _buildAppBar(BuildContext context, TaskProvider taskProvider) {
    if (_isSearching) {
      // Arama modu için AppBar
      return AppBar(
        backgroundColor: Colors.amber.shade400,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchController.clear();
              taskProvider.setSearchQuery('');
            });
          },
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Görev ara...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          style: const TextStyle(color: Colors.white, fontSize: 18),
          onChanged: (query) => taskProvider.setSearchQuery(query),
        ),
      );
    } else {
      // Normal AppBar
      return AppBar(
        backgroundColor: Colors.amber.shade300,
        title: Text(
          taskProvider.selectedCategory ?? "Tüm Görevler",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 2,
        shadowColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                _isSearching = true;
              });
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            tooltip: "Kategoriye Göre Filtrele",
            onSelected: (String category) {
              // 'Tümü' seçilirse null yollayarak filtreyi kaldırıyoruz
              taskProvider.setSelectedCategory(category == 'Tümü' ? null : category);
            },
            itemBuilder: (BuildContext context) {
              final categories = ['Tümü', ...taskProvider.allCategories];
              return categories.map((String category) {
                return PopupMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList();
            },
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final filteredTasks = taskProvider.filteredTasks;

    return Scaffold(
      // DEĞİŞİKLİK: Dinamik AppBar'ı çağırıyoruz
      appBar: _buildAppBar(context, taskProvider),
      body: taskProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredTasks.isEmpty // DEĞİŞİKLİK: taskProvider.tasks yerine filteredTasks
              ? const Center(
                  child: Text("Görev bulunamadı!",
                      style: TextStyle(fontSize: 18, color: Colors.grey)))
              : ListView.builder(
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    // DEĞİŞİKLİK: `filteredTasks` listesi kullanılıyor
                    final task = filteredTasks[index];
                    return Dismissible(
                      key: Key(task.id),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        child: const Icon(Icons.delete,
                            color: Colors.white, size: 30),
                      ),
                      secondaryBackground: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete,
                            color: Colors.white, size: 30),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: Text("Emin misiniz?"),
                                  content: Text(
                                      "Bu görevi silmek istiyor musunuz?"),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: Text("İptal")),
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: Text("Sil")),
                                  ],
                                ));
                      },
                      onDismissed: (_) {
                        final removedTask = task;
                        taskProvider.removeTask(task);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('"${removedTask.title}" silindi'),
                          action: SnackBarAction(
                              label: 'Geri Al',
                              onPressed: () {
                                taskProvider.addTask(removedTask);
                              }),
                        ));
                      },
                      child: ListTile(
                        onTap: () => _showTaskDialog(context, taskProvider, task: task),
                        tileColor:
                            task.isDone ? Colors.grey.shade200 : Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.grey.shade300, width: 1),
                        ),
                        leading: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _getPriorityColor(task.priority),
                            shape: BoxShape.circle,
                          ),
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: TextStyle(
                                  fontSize: 20,
                                  color: task.isDone
                                      ? Colors.grey.shade600
                                      : Colors.black,
                                  decoration: task.isDone
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    task.category,
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey.shade700),
                                  ),
                                ),
                                if (task.dueDate != null) ...[
                                  SizedBox(width: 8),
                                  Text(
                                    "${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year} ${task.dueDate!.hour}:${task.dueDate!.minute.toString().padLeft(2, '0')}",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: task.isDone
                                            ? Colors.grey.shade500
                                            : Colors.grey.shade600),
                                  )
                                ],
                              ],
                            )
                          ],
                        ),
                        trailing: Checkbox(
                            activeColor: Colors.amber,
                            checkColor: Colors.white,
                            value: task.isDone,
                            onChanged: (_) {
                              taskProvider.toggleTask(task);
                            }),
                      ),
                    );
                  }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber.shade300,
        onPressed: () => _showTaskDialog(context, taskProvider),
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 35,
        ),
      ),
    );
  }

  void _showTaskDialog(BuildContext context, TaskProvider provider, {Task? task}) {
    final isEditing = task != null;
    String taskTitle = isEditing ? task.title : '';
    DateTime? selectedDate = isEditing ? task.dueDate : null;
    Priority selectedPriority = isEditing ? task.priority : Priority.medium;
    final categoryController = TextEditingController(text: isEditing ? task.category : 'Genel');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEditing ? "Görevi Düzenle" : "Yeni Görev"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: taskTitle,
                  onChanged: (value) => taskTitle = value,
                  decoration: InputDecoration(hintText: "Görev Başlığı"),
                ),
                SizedBox(height: 20),
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<String>.empty();
                    }
                    return provider.allCategories.where((String option) {
                      return option
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  onSelected: (String selection) {
                    categoryController.text = selection;
                  },
                  fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                    if (controller.text != categoryController.text) {
                       Future.microtask(() => controller.text = categoryController.text);
                    }
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(hintText: "Kategori"),
                    );
                  },
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<Priority>(
                  initialValue: selectedPriority,
                  items: Priority.values.map((Priority priority) {
                    return DropdownMenuItem<Priority>(
                      value: priority,
                      child: Text(
                        priority.toString().split('.').last.toUpperCase(),
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() => selectedPriority = newValue!);
                  },
                  decoration: InputDecoration(labelText: "Öncelik"),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: Text(
                      selectedDate == null
                        ? "Tarih ve saat seçilmedi"
                        : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year} - ${selectedDate!.hour}:${selectedDate!.minute.toString().padLeft(2, '0')}",
                      )
                    ),
                    IconButton(
                      icon: Icon(Icons.calendar_today, color: Colors.amber.shade700,),
                      onPressed: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        
                        );
                        if (pickedDate == null) return;

                        final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(selectedDate ?? DateTime.now()),
                        );

                        if (pickedTime == null) return;

                        setState((){
                          selectedDate = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                        });
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("İptal"),
            ),
            TextButton(
              onPressed: () {
                final category = categoryController.text;
                if (taskTitle.isNotEmpty && category.isNotEmpty) {
                  if (isEditing) {
                    final updatedTask = Task(
                      id: task.id,
                      title: taskTitle,
                      isDone: task.isDone,
                      dueDate: selectedDate,
                      priority: selectedPriority,
                      category: category,
                    );
                    provider.updateTask(updatedTask);
                  } else {
                    provider.addTask(Task(
                      id: DateTime.now().microsecondsSinceEpoch.toString(),
                      title: taskTitle,
                      dueDate: selectedDate,
                      priority: selectedPriority,
                      category: category,
                    ));
                  }
                }
                Navigator.pop(context);
              },
              child: Text(isEditing ? "Kaydet" : "Ekle"),
            ),
          ],
        ),
      ),
    );
  }
}