import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  runApp(const MainApp());
}

class Task {
  String task;
  bool isDone;
  DateTime dateTime;
  Task(this.task, this.isDone, this.dateTime);
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: SafeArea(child: CheckList()));
  }
}

class CheckList extends StatefulWidget {
  const CheckList({super.key});
  @override
  State<CheckList> createState() => _CheckListState();
}

class _CheckListState extends State<CheckList> with WidgetsBindingObserver {
  List<Task> tasks = [];
  final TextEditingController _controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadTasks();
  }

  @override
  void dispose() {
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      saveTasks();
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("To Do List", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return _buildTaskBoxCheckListCard(task,index); /**/
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniStartDocked,
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {
          setState(() {
            _controller.clear();
            _showTaskCreationScreen(context, _controller);
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void saveTasks() async {
    await saveToFile(tasks);
  }

  void loadTasks() async {
    final loaded = await readTasks();
    setState(() {
      tasks = loaded;
    });
  }

  Card _buildTaskBoxCheckListCard(Task task,int index) {
    return Card(
      color: Colors.black,
      child: Dismissible(
        background: Card(color: Colors.red, child: Icon(Icons.remove_circle)),
        key: UniqueKey(),
        onDismissed: (DismissDirection direction) => setState(() {
          tasks.removeAt(index);
        }),
        confirmDismiss: (DismissDirection direction) async {
          return await showDialog(
            context: context,
            builder: (context) => _buildConfirmationAlertDialog(task),
          );
        },
        child: _buildTaskBoxCheckList(task),
      ),
    );
  }

  Widget _buildConfirmationAlertDialog(Task task) {
    return AlertDialog(
      title: Text("Delete Task"),
      content: Text("Are you sure you want to delete ${task.task}?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text("confirm"),
        ),
      ],
    );
  }

  Widget _buildTaskBoxCheckList(Task task) {
    return CheckboxListTile(
      title: Text(
        'Task: ${task.task}',
        style: TextStyle(
          color: Colors.white,
          decoration: task.isDone ? TextDecoration.lineThrough : null,
          decorationColor: Color.fromARGB(255, 234, 221, 255),
          decorationThickness: 3.5,
        ),
      ),
      subtitle: Text(
        "Due: ${task.dateTime.toLocal().toString().split(' ')[0]}",
        style: TextStyle(
          color: Colors.white,
          decoration: task.isDone ? TextDecoration.lineThrough : null,
          decorationColor: Color.fromARGB(255, 234, 221, 255),
          decorationThickness: 3.5,
        ),
      ),
      value: task.isDone,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: Colors.white,
      checkColor: Color.fromARGB(255, 79, 57, 140),
      onChanged: (bool? value) {
        setState(() {
          task.isDone = value ?? false;
        });
      },
    );
  }

  // ignore: no_leading_underscores_for_local_identifiers
  void _showTaskCreationScreen(BuildContext context,TextEditingController _controller) {
    DateTime? selectedDate = DateTime.now();
    showDialog(
      //I think i can make this more readable
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Your task"),
        content: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Task',
              ),
            ),
            const SizedBox(height: 5),
            TextButton.icon(
              icon: Icon(Icons.calendar_today_rounded),
              label: Text(
                "Due: ${selectedDate!.toLocal().toString().split(' ')[0]}",
              ),
              onPressed: () async {
                selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(), // today
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                setState(() {
                  selectedDate ??= DateTime.now();
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text("submit"),
            onPressed: () {
              final input = _controller.text.trim();
              if (input.isNotEmpty) {
                setState(() {
                  tasks.add(Task(input, false, selectedDate!));
                  tasks.sort((a, b) => a.dateTime.compareTo(b.dateTime));
                });
              }
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: Text("cancel"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

Future<File> getLocalFile() async {
  final directory = await getApplicationDocumentsDirectory(); // Safe for mobile
  return File('${directory.path}/to_do_list.json');
}

Future<List<Task>> readTasks() async {
  try {
    final file = await getLocalFile();
    if (!await file.exists()) {
      await file.create();
      return [];
    }

    final contents = await file.readAsString();
    final List<dynamic> decoded = jsonDecode(contents);
    List<Task> loadedData = [];
    for (var i in decoded) {
      i as Map<String, dynamic>;
      loadedData.add(Task(i["task"], i["complete"], DateTime.parse(i["due"])));
    }
    return loadedData;
  } catch (e) {
    return [];
  }
}

Future<void> saveToFile(List<Task> tasks) async {
  final File file = await getLocalFile();
  List<Map<String, dynamic>> toWrite = [];
  for (var i in tasks) {
    toWrite.add({
      "task": i.task,
      "complete": i.isDone,
      "due": i.dateTime.toIso8601String(),
    });
  }
  await file.writeAsString(jsonEncode(toWrite));
}
