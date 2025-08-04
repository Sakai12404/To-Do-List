import 'package:flutter/material.dart';
//import 'package:flutter/rendering.dart';
import 'package:to_do_list/models/task.dart';
import 'package:to_do_list/services/task_storage.dart';

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
                return _buildTaskBoxCheckListCard(task, index);
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
            _showTaskCreationScreen(context, _controller, true, null);
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void saveTasks() async => await saveToFile(tasks);

  void loadTasks() async {
    final loaded = await readTasks();
    setState(() {
      tasks = loaded;
    });
  }

  Card _buildTaskBoxCheckListCard(Task task, int index) {
    return Card(
      color: Colors.black,
      child: Dismissible(
        background: Card(color: Colors.red, child: Icon(Icons.remove_circle)),
        secondaryBackground: Card(
          color: Colors.blue,
          child: Icon(Icons.autorenew_rounded),
        ),
        key: UniqueKey(),
        onDismissed: (DismissDirection direction) => setState(() {
          tasks.removeAt(index);
        }),
        confirmDismiss: (DismissDirection direction) async {
          if (direction == DismissDirection.startToEnd) {
            return await showDialog(
              context: context,
              builder: (context) => _buildConfirmationAlertDialog(task),
            );
          }
          setState(
            () => _showTaskCreationScreen(context, _controller, false, index),
          );
          return false;
        },
        child: _buildTaskBoxCheckList(task),
      ),
    );
  }

  Widget _buildConfirmationAlertDialog(Task task) {
    ScrollController scrollContorler = ScrollController();
    return AlertDialog(
      title: Text("Delete Task"),
      content: Expanded(
        child: SingleChildScrollView(
          controller: scrollContorler,
          scrollDirection: Axis.vertical,
          child: Text(
            "Are you sure you want to delete ${task.task}?",
          ),
        ),
      ),
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
  void _showTaskCreationScreen(
    BuildContext context,
    // ignore: no_leading_underscores_for_local_identifiers
    TextEditingController _controller,
    bool isAdd,
    int? index,
  ) {
    Task? task = index == null ? null : tasks[index];
    bool isTaskNull = task == null;
    DateTime? selectedDate = isTaskNull ? DateTime.now() : task.dateTime;
    ScrollController scrollContorler = ScrollController();
    FocusNode textFieldFocusNode = FocusNode();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Your task"),
        content: IntrinsicHeight(
          child: Column(
            children: [
              GestureDetector(
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                child: Scrollbar(
                  controller: scrollContorler,
                  child: TextField(
                    minLines: 1,
                    maxLines: 5,
                    scrollController: scrollContorler,
                    controller: _controller,
                    focusNode: textFieldFocusNode,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Task:",
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              StatefulBuilder(
                builder: (context, setState) => TextButton.icon(
                  icon: Icon(Icons.calendar_today_rounded),
                  label: Text(
                    "Due: ${selectedDate!.toLocal().toString().split(' ')[0]}",
                  ),
                  onPressed: () async {
                    DateTime? datePicked = await showDatePicker(
                      context: context,
                      initialDate: !isTaskNull
                          ? tasks[index!].dateTime
                          : DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );

                    if (datePicked == null) {
                      if (isAdd) {
                        datePicked = tasks[index!].dateTime;
                      } else {
                        datePicked = DateTime.now();
                      }
                    }
                    setState(() => selectedDate = datePicked);
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text("submit"),
            onPressed: () {
              final input = _controller.text.trim();
              if (input.isNotEmpty) {
                if (isAdd) {
                  setState(() {
                    tasks.add(Task(input, false, selectedDate!));
                    sortTasks(tasks);
                  });
                } else {
                  setState(() {
                    tasks[index!] = Task(
                      input,
                      tasks[index].isDone,
                      selectedDate!,
                    );
                    sortTasks(tasks);
                  });
                }
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

List<Task> sortTasks(List<Task> tasks) {
  tasks.sort((a, b) => a.dateTime.compareTo(b.dateTime));
  return tasks;
}
