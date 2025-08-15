import 'package:flutter/material.dart';
import 'package:to_do_list/models/task.dart';
import 'package:to_do_list/services/task_storage.dart';
import 'package:to_do_list/screen/recurringtasklist.dart';
import 'package:to_do_list/main.dart';
import 'package:to_do_list/widgets/checkboxlist.dart';
import 'package:to_do_list/widgets/taskcreation.dart';
import 'package:uuid/uuid.dart';

class SingleOcurringCheckList extends StatefulWidget {
  const SingleOcurringCheckList({super.key});
  @override
  State<SingleOcurringCheckList> createState() =>
      _SingleOcurringCheckListState();
}

class _SingleOcurringCheckListState extends State<SingleOcurringCheckList>
    with WidgetsBindingObserver, RouteAware {
  List<Task> tasks = [];
  @override
  void initState() {
    super.initState();
    //loadTasks();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
        title: Text("To Do List", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            padding: EdgeInsets.all(10.0),
            icon: Icon(Icons.next_plan_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RecurringTaskList()),
            ),
          ),
        ],
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
            _showTaskCreationScreen(context, true, null);
          });
        },
        child: const Icon(Icons.add),
      ),
    );
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
        key: Key(task.id!),
        onDismissed: (DismissDirection direction) => setState(() {
          tasks.removeWhere((t) => t.id == task.id);
          saveTasks();
        }),
        confirmDismiss: (DismissDirection direction) async {
          if (direction == DismissDirection.startToEnd) {
            return await _buildConfirmationAlertDialog(task);
          }
          _showTaskCreationScreen(context, false, index);
          return false;
        },
        child: CheckBoxlist(task: task, isRecurring: false),
      ),
    );
  }

  Future<bool> _buildConfirmationAlertDialog(Task task) async {
    ScrollController scrollContorler = ScrollController();
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Task"),
        content: SingleChildScrollView(
            controller: scrollContorler,
            scrollDirection: Axis.vertical,
            child: Text("Are you sure you want to delete ${task.task}?"),
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
      ),
    );
  }

  void _showTaskCreationScreen(BuildContext context, bool isAdd, int? index) {
    Task? task = index == null ? null : tasks[index];
    String id = isAdd ? Uuid().v4() : task!.id!; 
    showDialog(
      context: context,
      builder: (context) => TaskCreation(
        isAdd: isAdd,
        isRecurring: false,
        task: isAdd ? null : task!,
        onSubmit: (task) {
          setState(() {
            if (isAdd) {
              task.id = id;
              tasks.add(task);
              sortTasks(tasks);
            } else {
              task.id = id;
              tasks[index!] = task;
              sortTasks(tasks);
            }
          });
        },
      ),
    );
  }

  void saveTasks() async => await saveToFile(tasks, "single_occurence_list");

  void loadTasks() async {
    final loaded = await readTasks("single_occurence_list");
    setState(() {
      tasks = loaded;
    });
  }
}
