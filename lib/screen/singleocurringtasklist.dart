import 'package:flutter/material.dart';
import 'package:to_do_list/models/task.dart';
import 'package:to_do_list/services/task_storage.dart';
import 'package:to_do_list/screen/recurringtasklist.dart';
import 'package:to_do_list/main.dart';

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
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPushNext() {
    // Going forward to another page
    saveTasks();
    print("Saved tasks before leaving page");
  }

  @override
  void didPop() {
    // This page itself is being closed
    saveTasks();
    print("Saved tasks before page closed");
  }

  @override
  void didPopNext() {
    // Coming back from another page
    saveTasks(); // <-- You can also save here if needed
    print("Saved tasks after coming back");
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

  void saveTasks() async => await saveToFile(tasks, "single_occurence_list");

  void loadTasks() async {
    final loaded = await readTasks("single_occurence_list");
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
            return await _buildConfirmationAlertDialog(task);
          }
          setState(() => _showTaskCreationScreen(context, false, index));
          return false;
        },
        child: _buildTaskBoxCheckList(task),
      ),
    );
  }

  Future<bool> _buildConfirmationAlertDialog(Task task) async {
    ScrollController scrollContorler = ScrollController();
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Task"),
        content: Expanded(
          child: SingleChildScrollView(
            controller: scrollContorler,
            scrollDirection: Axis.vertical,
            child: Text("Are you sure you want to delete ${task.task}?"),
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
      ),
    );
  }

  Widget _buildTaskBoxCheckList(Task task) {
    return CheckboxListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            'Task: ${task.task}',
            style: TextStyle(
              color: Colors.white,
              decoration: task.isDone ? TextDecoration.lineThrough : null,
              decorationColor: Color.fromARGB(255, 234, 221, 255),
              decorationThickness: 3.5,
            ),
          ),
          SelectableText(
            "Due: ${task.dateTime.toLocal().toString().split(' ')[0]} ${task.dueWhen == null ? "" : "at: ${task.dueWhen!.format(context)}"}",
            style: TextStyle(
              color: Colors.white,
              decoration: task.isDone ? TextDecoration.lineThrough : null,
              decorationColor: Color.fromARGB(255, 234, 221, 255),
              decorationThickness: 3.5,
            ),
          ),
        ],
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

  void _showTaskCreationScreen(BuildContext context, bool isAdd, int? index) {
    Task? task = index == null ? null : tasks[index];
    bool isTaskNull = task == null;
    DateTime? selectedDate = isTaskNull ? DateTime.now() : task.dateTime;
    TimeOfDay? selectedTime = isTaskNull ? null : task.dueWhen;
    ScrollController scrollContorler = ScrollController();
    TextEditingController controller = TextEditingController(
      text: isTaskNull ? null : task.task,
    );
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
                    controller: controller,
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
              const SizedBox(height: 2.5),
              StatefulBuilder(
                builder: (context, setState) => selectedTime == null
                    ? TextButton.icon(
                        icon: Icon(Icons.add),
                        label: Text("Add the hour due?"),
                        onPressed: () =>
                            setState(() => selectedTime = TimeOfDay.now()),
                      )
                    : TextButton.icon(
                        icon: Icon(Icons.hourglass_bottom),
                        label: Text("Due at: ${selectedTime!.format(context)}"),
                        onPressed: () async {
                          TimeOfDay? pickedHour = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          setState(() {
                            if (pickedHour != null) {
                              selectedTime = pickedHour;
                            }
                          });
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
              final input = controller.text.trim();
              if (input.isNotEmpty) {
                if (isAdd) {
                  setState(() {
                    tasks.add(Task(input, false, selectedDate!, selectedTime));
                    sortTasks(tasks);
                  });
                } else {
                  setState(() {
                    tasks[index!] = Task(
                      input,
                      tasks[index].isDone,
                      selectedDate!,
                      selectedTime,
                    );
                    sortTasks(tasks);
                  });
                }
              }
              //print(tasks);
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
