// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// void main() async {
//   // Required for accessing SharedPreferences before runApp
//   WidgetsFlutterBinding.ensureInitialized();
  
//   final taskProvider = TaskProvider();
//   await taskProvider.loadTasks(); // Load saved data from memory

//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider.value(value: taskProvider),
//       ],
//       child: const ProfessionalTodoApp(),
//     ),
//   );
// }

// // --- APP THEME ---
// class AppTheme {
//   static const Color primary = Color(0xFF2B2D42);
//   static const Color accent = Color(0xFFEF233C);
//   static const Color background = Color(0xFFEDF2F4);
  
//   static ThemeData get lightTheme => ThemeData(
//     useMaterial3: true,
//     scaffoldBackgroundColor: background,
//     colorScheme: ColorScheme.fromSeed(seedColor: primary, secondary: accent),
//   );
// }

// // --- MODEL WITH JSON CONVERSION ---
// class Task {
//   final String id;
//   final String title;
//   final DateTime date;
//   bool isCompleted;

//   Task({required this.id, required this.title, required this.date, this.isCompleted = false});

//   // Convert Task to Map for JSON saving
//   Map<String, dynamic> toJson() => {
//     'id': id, 'title': title, 'date': date.toIso8601String(), 'isCompleted': isCompleted,
//   };

//   // Convert JSON back to Task
//   factory Task.fromJson(Map<String, dynamic> json) => Task(
//     id: json['id'],
//     title: json['title'],
//     date: DateTime.parse(json['date']),
//     isCompleted: json['isCompleted'],
//   );
// }

// // --- PERSISTENT STATE MANAGEMENT ---
// class TaskProvider extends ChangeNotifier {
//   List<Task> _tasks = [];
//   List<Task> get tasks => _tasks;
//   int get completedCount => _tasks.where((t) => t.isCompleted).length;

//   // --- SAVE & LOAD LOGIC ---
//   Future<void> saveTasks() async {
//     final prefs = await SharedPreferences.getInstance();
//     final String encodedData = json.encode(_tasks.map((t) => t.toJson()).toList());
//     await prefs.setString('user_tasks', encodedData);
//   }

//   Future<void> loadTasks() async {
//     final prefs = await SharedPreferences.getInstance();
//     final String? taskString = prefs.getString('user_tasks');
//     if (taskString != null) {
//       final List<dynamic> decodedData = json.decode(taskString);
//       _tasks = decodedData.map((item) => Task.fromJson(item)).toList();
//       notifyListeners();
//     }
//   }

//   // --- ACTIONS ---
//   void addTask(String title) {
//     _tasks.insert(0, Task(id: DateTime.now().toString(), title: title, date: DateTime.now()));
//     saveTasks(); // Persist
//     notifyListeners();
//   }

//   void toggleTask(String id) {
//     final index = _tasks.indexWhere((t) => t.id == id);
//     if (index != -1) {
//       _tasks[index].isCompleted = !_tasks[index].isCompleted;
//       saveTasks(); // Persist
//       notifyListeners();
//     }
//   }

//   void deleteTask(String id) {
//     _tasks.removeWhere((t) => t.id == id);
//     saveTasks(); // Persist
//     notifyListeners();
//   }
// }

// // --- UI CODE (SAME AS BEFORE) ---
// class ProfessionalTodoApp extends StatelessWidget {
//   const ProfessionalTodoApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: AppTheme.lightTheme,
//       home: const HomeScreen(),
//     );
//   }
// }

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: [
//             const _HeaderSection(),
//             Expanded(
//               child: Consumer<TaskProvider>(
//                 builder: (context, provider, child) {
//                   return provider.tasks.isEmpty
//                       ? const Center(child: Text("No tasks found. Add one!"))
//                       : ListView.builder(
//                           padding: const EdgeInsets.symmetric(horizontal: 20),
//                           itemCount: provider.tasks.length,
//                           itemBuilder: (context, index) => _TaskTile(task: provider.tasks[index]),
//                         );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () => _showAddTaskModal(context),
//         label: const Text("Add Task"),
//         icon: const Icon(Icons.add),
//       ),
//     );
//   }

//   void _showAddTaskModal(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
//       builder: (context) => const _AddTaskModal(),
//     );
//   }
// }

// class _HeaderSection extends StatelessWidget {
//   const _HeaderSection();
//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<TaskProvider>(context);
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text("Todo Management App", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primary)),
//           const SizedBox(height: 15),
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(20)),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                   const Text("Progress", style: TextStyle(color: Colors.white70)),
//                   Text("${provider.completedCount} / ${provider.tasks.length} Done", 
//                     style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
//                 ]),
//                 const Icon(Icons.cloud_done_outlined, color: Colors.greenAccent, size: 30),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _TaskTile extends StatelessWidget {
//   final Task task;
//   const _TaskTile({required this.task});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
//       child: ListTile(
//         leading: Checkbox(
//           value: task.isCompleted,
//           onChanged: (_) => Provider.of<TaskProvider>(context, listen: false).toggleTask(task.id),
//         ),
//         title: Text(task.title, style: TextStyle(decoration: task.isCompleted ? TextDecoration.lineThrough : null)),
//         subtitle: Text(DateFormat('jm').format(task.date)),
//         trailing: IconButton(
//           icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
//           onPressed: () => Provider.of<TaskProvider>(context, listen: false).deleteTask(task.id),
//         ),
//       ),
//     );
//   }
// }

// class _AddTaskModal extends StatefulWidget {
//   const _AddTaskModal();
//   @override
//   State<_AddTaskModal> createState() => _AddTaskModalState();
// }

// class _AddTaskModalState extends State<_AddTaskModal> {
//   final _controller = TextEditingController();
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           TextField(controller: _controller, autofocus: true, decoration: const InputDecoration(hintText: "What's the plan?")),
//           const SizedBox(height: 15),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
//             onPressed: () {
//               if (_controller.text.isNotEmpty) {
//                 Provider.of<TaskProvider>(context, listen: false).addTask(_controller.text);
//                 Navigator.pop(context);
//               }
//             },
//             child: const Text("Save Task"),
//           ),
//         ],
//       ),
//     );
//   }
// }



import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final taskProvider = TaskProvider();
  await taskProvider.loadTasks(); 

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider.value(value: taskProvider)],
      child: const ProfessionalTodoApp(),
    ),
  );
}

// --- APP THEME ---
class AppTheme {
  static const Color primary = Color(0xFF2B2D42);
  static const Color accent = Color(0xFFEF233C);
  static const Color background = Color(0xFFEDF2F4);
  
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.fromSeed(seedColor: primary, secondary: accent),
  );
}

// --- MODEL ---
class Task {
  final String id;
  final String title;
  final DateTime date;
  bool isCompleted;

  Task({required this.id, required this.title, required this.date, this.isCompleted = false});

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'date': date.toIso8601String(), 'isCompleted': isCompleted};
  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'],
    title: json['title'],
    date: DateTime.parse(json['date']),
    isCompleted: json['isCompleted'],
  );
}

// --- PERSISTENT STATE MANAGEMENT ---
class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;
  int get completedCount => _tasks.where((t) => t.isCompleted).length;
  double get completionPercentage => _tasks.isEmpty ? 0 : completedCount / _tasks.length;

  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(_tasks.map((t) => t.toJson()).toList());
    await prefs.setString('user_tasks', encodedData);
  }

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? taskString = prefs.getString('user_tasks');
    if (taskString != null) {
      final List<dynamic> decodedData = json.decode(taskString);
      _tasks = decodedData.map((item) => Task.fromJson(item)).toList();
      notifyListeners();
    }
  }

  void addTask(String title) {
    _tasks.insert(0, Task(id: DateTime.now().toString(), title: title, date: DateTime.now()));
    saveTasks();
    notifyListeners();
  }

  void toggleTask(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
      saveTasks();
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    saveTasks();
    notifyListeners();
  }
}

// --- MAIN APP ---
class ProfessionalTodoApp extends StatelessWidget {
  const ProfessionalTodoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const _HeaderSection(),
            Expanded(
              child: Consumer<TaskProvider>(
                builder: (context, provider, child) {
                  return provider.tasks.isEmpty
                      ? const Center(child: Text("No tasks yet. Enjoy your day!"))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: provider.tasks.length,
                          itemBuilder: (context, index) => _TaskTile(task: provider.tasks[index]),
                        );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskModal(context),
        label: const Text("New Task"),
        icon: const Icon(Icons.add_task),
      ),
    );
  }

  void _showAddTaskModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => const _AddTaskModal(),
    );
  }
}

// --- UI COMPONENTS ---

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("My Tasks", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primary)),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, Color(0xFF434662)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Daily Progress", style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text("${provider.completedCount} of ${provider.tasks.length} tasks done", 
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                // CIRCULAR PROGRESS INDICATOR
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 50, height: 50,
                      child: CircularProgressIndicator(
                        value: provider.completionPercentage,
                        strokeWidth: 6,
                        backgroundColor: Colors.white10,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
                      ),
                    ),
                    Text(
                      "${(provider.completionPercentage * 100).toInt()}%",
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final Task task;
  const _TaskTile({required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        leading: Transform.scale(
          scale: 1.2,
          child: Checkbox(
            shape: const CircleBorder(),
            activeColor: AppTheme.accent,
            value: task.isCompleted,
            onChanged: (_) => Provider.of<TaskProvider>(context, listen: false).toggleTask(task.id),
          ),
        ),
        title: Text(task.title, style: TextStyle(
          fontWeight: FontWeight.w600,
          color: task.isCompleted ? Colors.grey : AppTheme.primary,
          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
        )),
        subtitle: Text(DateFormat('jm').format(task.date), style: const TextStyle(fontSize: 12)),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
          onPressed: () => Provider.of<TaskProvider>(context, listen: false).deleteTask(task.id),
        ),
      ),
    );
  }
}

class _AddTaskModal extends StatefulWidget {
  const _AddTaskModal();
  @override
  State<_AddTaskModal> createState() => _AddTaskModalState();
}

class _AddTaskModalState extends State<_AddTaskModal> {
  final _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(25, 25, 25, MediaQuery.of(context).viewInsets.bottom + 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("New Task", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          TextField(
            controller: _controller, 
            autofocus: true, 
            decoration: InputDecoration(
              hintText: "What needs to be done?",
              filled: true, fillColor: AppTheme.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  Provider.of<TaskProvider>(context, listen: false).addTask(_controller.text);
                  Navigator.pop(context);
                }
              },
              child: const Text("Add to List", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}