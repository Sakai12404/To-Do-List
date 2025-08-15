import 'package:flutter/material.dart';
import 'package:to_do_list/models/task.dart';
import 'package:to_do_list/services/task_storage.dart';
import 'package:to_do_list/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_list/widgets/checkboxlist.dart';
import 'package:to_do_list/widgets/taskcreation.dart';

class RecurringTaskList extends StatefulWidget {
  const RecurringTaskList({super.key});
  @override
  State<RecurringTaskList> createState() => _RecuringTaskList();
}

class _RecuringTaskList extends State<RecurringTaskList>
    with RouteAware, WidgetsBindingObserver {
  List<Task> tasks = [];
  Map<String, List<Task>> sortedTasksbyDay = {
    "monday": [],
    "tuesday": [],
    "wensday": [],
    "thursday": [],
    "friday": [],
    "saturday": [],
    "sunday": [],
  };
  List<String> indexToDay = [
    "monday",
    "tuesday",
    "wensday",
    "thursday",
    "friday",
    "saturday",
    "sunday",
  ];
  bool viewingToday = false;
  @override
  void initState() {
    super.initState();
    loadTasks();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    //WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPushNext() {
    // Going forward to another page
    saveTasks();
    //print("Saved tasks before leaving page");
  }

  @override
  void didPop() {
    // This page itself is being closed
    saveTasks();
    //print("Saved tasks before page closed");
  }

  @override
  void didPopNext() {
    // Coming back from another page
    saveTasks(); // <-- You can also save here if needed
    //print("Saved tasks after coming back");
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
        title: Text("Daily tasks"),
        actions: [
          IconButton(
            icon: Icon(Icons.today),
            onPressed: () {
              setState(() => viewingToday = !viewingToday);
            },
            tooltip: "View todays tasks and opposite",
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            viewingToday
                ? _dailyBuilder(indexToDay[DateTime.now().weekday - 1])
                : Expanded(
                    child: ListView.builder(
                      itemCount: 7,
                      itemBuilder: (context, index) {
                        final day = indexToDay[index];
                        return _dailyBuilder(day);
                      },
                    ),
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        child: Icon(Icons.add),
        onPressed: () => _showTaskCreationScreen(context, true, null),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniStartDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
      ),
    );
  }

  Widget _dailyBuilder(String day) {
    return Padding(
      padding: EdgeInsetsGeometry.all(6),
      child: Column(
        children: [
          Card(
            color: Colors.black,
            child: Padding(
              padding: EdgeInsetsGeometry.all(8),
              child: Text(
                "${day[0].toUpperCase()}${day.substring(1, day.length)}",
                style: TextStyle(
                  fontSize: 25.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          sortedTasksbyDay[day]!.isNotEmpty
              ? ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: sortedTasksbyDay[day]!.length,
                  itemBuilder: (context, a) {
                    final task = sortedTasksbyDay[day]![a];
                    return _createCard(task, a);
                  },
                )
              : Text(
                  "Nothing in $day",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
        ],
      ),
    );
  }

  void _showTaskCreationScreen(BuildContext context, bool isAdd, int? index) {
    Task? task = isAdd ? null : tasks[index!];
    showDialog(
      context: context,
      builder: (context) => TaskCreation(
        isAdd: isAdd,
        isRecurring: true,
        task: isAdd ? null : task!,
        onSubmit: (task) {
          setState(() {
            if (isAdd) {
              tasks.add(task);
              sortTasks(tasks);
              sortedTasksbyDay = formatMultipleOcurrenceTasks(tasks);
            } else {
              tasks[index!] = task;
              sortTasks(tasks);
              sortedTasksbyDay = formatMultipleOcurrenceTasks(tasks);
            }
          });
        },
      ),
    );
  }

  Widget _createCard(Task task, int index) {
    return Card(
      color: Colors.black,
      child: CheckBoxlist(task: task, isRecurring: true),
    );
  }

  void loadTasks() async {
    //bool differentDay = false;
    tasks = await readTasks("multiple_occurence_list");
    final prefs = await SharedPreferences.getInstance();
    final lastOpenedStr = prefs.getString("last_opened_app");
    final today = DateTime.now();
    if (lastOpenedStr != null) {
      final lastOpened = DateTime.parse(lastOpenedStr);
      if (lastOpened.day != today.day ||
          lastOpened.month != today.month ||
          lastOpened.year != today.year) {
        for (Task i in tasks) {
          i.isDone = false;
        }
      }
    }
    setState(() => sortedTasksbyDay = formatMultipleOcurrenceTasks(tasks));
  }

  void saveTasks() async {
    await saveToFile(tasks, "multiple_occurence_list");
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("last_opened_app", DateTime.now().toIso8601String());
  }
}
