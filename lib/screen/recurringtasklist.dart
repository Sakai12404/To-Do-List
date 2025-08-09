import 'package:flutter/material.dart';
import 'package:to_do_list/models/task.dart';
import 'package:to_do_list/services/task_storage.dart';
import 'package:day_picker/day_picker.dart';

class RecurringTaskList extends StatefulWidget {
  const RecurringTaskList({super.key});
  @override
  State<RecurringTaskList> createState() => _RecuringTaskList();
}

class _RecuringTaskList extends State<RecurringTaskList> {
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
  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Daily tasks")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 7,
              itemBuilder: (context, index) {
                final day = indexToDay[index];
                return Column(
                  children: [
                    Text(day,style: TextStyle(fontSize: 25.0, color: Colors.black,fontWeight: FontWeight.bold)),
                    sortedTasksbyDay[day]!.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: sortedTasksbyDay[day]!.length,
                            itemBuilder: (context, a) {
                              final task = sortedTasksbyDay[day]![a];
                              return _createCard(task, a);
                            },
                          )
                        : Text("Nothing in $day"),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        child: Icon(Icons.add),
        onPressed: () async =>
            await _showTaskCreationScreen(context, true, null),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
      ),
    );
  }

  Future<void> _showTaskCreationScreen(
    BuildContext context,
    bool isAdd,
    int? index,
  ) async {
    Task? task = isAdd ? null : tasks[index!];
    ScrollController scrollContorler = ScrollController();
    TextEditingController controller = TextEditingController(
      text: isAdd ? null : task!.task,
    );
    TimeOfDay? selectedTime = isAdd ? null : task!.dueWhen;
    List<DayInWeek> days = [
      DayInWeek("Mon", dayKey: "monday"),
      DayInWeek("Tues", dayKey: "tuesday"),
      DayInWeek("Wens", dayKey: "wednesday"),
      DayInWeek("Thurs", dayKey: "thursday"),
      DayInWeek("Fri", dayKey: "friday"),
      DayInWeek("Sat", dayKey: "saturday"),
      DayInWeek("Sun", dayKey: "sunday"),
    ];
    FocusNode textFieldFocusNode = FocusNode();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Task"),
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
                    controller: controller,
                    scrollController: scrollContorler,
                    focusNode: textFieldFocusNode,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("task"),
                    ),
                  ),
                ),
              ),

              Text("Select days when task is needed to be complete"),
              SelectWeekDays(
                days: days,
                onSelect: (days) => print(days),
                backgroundColor: Colors.black87,
                boxDecoration: BoxDecoration(
                  color: Colors.black,
                  border: BoxBorder.all(width: 8.0),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
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
                    tasks.add(
                      Task(
                        input,
                        false,
                        DateTime.now(),
                        selectedTime,
                        convertDaysOfWeek(days),
                      ),
                    );
                    sortTasks(tasks);
                    sortedTasksbyDay = formatMultipleOcurrenceTasks(tasks);
                  });
                } else {
                  setState(() {
                    tasks[index!] = Task(
                      input,
                      tasks[index].isDone,
                      DateTime.now(),
                      selectedTime,
                      convertDaysOfWeek(days),
                    );
                    sortTasks(tasks);
                    sortedTasksbyDay = formatMultipleOcurrenceTasks(tasks);
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

  Widget _createCard(Task task, int index) {
    return Card(
      color: Colors.black,
      child: CheckboxListTile(
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
            task.dueWhen == null
                ? Text("")
                : SelectableText(
                    "Due: ${task.dueWhen!.hour}",
                    style: TextStyle(
                      color: Colors.white,
                      decoration: task.isDone
                          ? TextDecoration.lineThrough
                          : null,
                      decorationColor: Color.fromARGB(255, 234, 221, 255),
                      decorationThickness: 3.5,
                    ),
                  ),
          ],
        ),
        controlAffinity: ListTileControlAffinity.leading,
        value: task.isDone,
        activeColor: Colors.white,
        checkColor: Color.fromARGB(255, 79, 57, 140),
        onChanged: (bool? value) =>
            setState(() => task.isDone = value ?? false),
      ),
    );
  }

  void loadTasks() async {
    tasks = await readTasks("multiple_occurence_list");
    sortedTasksbyDay = formatMultipleOcurrenceTasks(tasks);
  }

  void saveTasks() async => saveToFile(tasks, "multiple_occurence_list");
}

List<bool> convertDaysOfWeek(List<DayInWeek> days) {
  List<bool> daysInWeek = [];
  for (var i in days) {
    daysInWeek.add(i.isSelected);
  }
  return daysInWeek;
}
