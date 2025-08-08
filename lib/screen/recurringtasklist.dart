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
  List<Task> todayTasks = [];
  final List<DayInWeek> _days = [
    DayInWeek("Mon", dayKey: "monday"),
    DayInWeek("Tues", dayKey: "tuesday"),
    DayInWeek("Wens", dayKey: "wednesday"),
    DayInWeek("Thurs", dayKey: "thursday"),
    DayInWeek("Fri", dayKey: "friday"),
    DayInWeek("Sat", dayKey: "saturday"),
    DayInWeek("Sun", dayKey: "sunday"),
  ];
  List<String> selected = [];
  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Daily tasks"),
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder:(context, index) {
          final task = tasks[index];
          _createCard(task,index);
        } ,
      ),
    );
  }

  Widget _createCard(Task task, int index) {
    return Card(
      child: CheckboxListTile(
        value: task.isDone,
        onChanged:(bool? value) => setState(()=>task.isDone = value ?? false)
      ),
    );
  }
  void loadTasks() async  {
    tasks = await readTasks("multiple_occurence_list");
  }
  void saveTasks() async => saveToFile(tasks, "multiple_occurence_list");
}
