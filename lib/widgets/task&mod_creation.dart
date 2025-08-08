// ignore_for_file: file_names

/*import 'package:flutter/material.dart';
import 'package:to_do_list/models/task.dart';
class TaskCreationScreen extends StatefulWidget {
  const TaskCreationScreen({super.key});
  @override
  State<TaskCreationScreen> createState() => _TaskCreationScreen();
}
class _TaskCreationScreen extends State<TaskCreationScreen>{
  List<Task> tasks = [];
  bool isAdd = false;
  int? index;
  @override
  Widget build(BuildContext context)
    return Card(child:_showTaskCreationScreen());
  }
}
void _showTaskCreationScreen(BuildContext context, List<Task> tasks, bool isAdd, int? index) {
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
                        onPressed: () =>setState(() => selectedTime = TimeOfDay.now()),
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
List<Task> sortTasks(List<Task> tasks) {
  tasks.sort((a, b) => a.dateTime.compareTo(b.dateTime));
  return tasks;
}*/