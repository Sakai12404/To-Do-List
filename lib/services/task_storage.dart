import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:to_do_list/models/task.dart';
import 'dart:io';
import 'dart:convert';

Future<File> getLocalFile(String fileName) async {
  final directory = await getApplicationDocumentsDirectory(); // Safe for mobile
  return File('${directory.path}/$fileName.json');
}

Future<List<Task>> readTasks(String fileName) async {
  try {
    final file = await getLocalFile(fileName);
    if (!await file.exists()) {
      await file.create(recursive: true);
      return [];
    }

    final contents = await file.readAsString();
    final List<dynamic> decoded = jsonDecode(contents);
    List<Task> loadedData = [];
    if (fileName == 'single_occurence_list.json') {
      for (var i in decoded) {
        i as Map<String, dynamic>;
        loadedData.add(
          Task(
            i["task"],
            i["complete"],
            fileName ==  "single_occurence_list" ? DateTime.parse(i["due"]) : DateTime.now(),
            i["hour"] == null ? null : convertJSONtoTimeofDay(i["hour"]),
            fileName == "single_occurence_list" ? null : i["week"]
          ),
        );
      }
    }
    return loadedData;
  } catch (e) {
    return [];
  }
}

Future<void> saveToFile(List<Task> tasks, String fileName) async {
  final File file = await getLocalFile(fileName);
  List<Map<String, dynamic>> toWrite = [];
  for (var i in tasks) {
    toWrite.add({
      "task": i.task,
      "complete": i.isDone,
      "due": fileName ==  "single_occurence_list" ? i.dateTime.toIso8601String():null,
      "hour": i.dueWhen == null ? null : convertTimeOfDayToJSON(i.dueWhen!),
      "week": fileName ==  "single_occurence_list" ? null : i.whenInWeek,
    });
  }
  await file.writeAsString(jsonEncode(toWrite));
}

Map<String, int> convertTimeOfDayToJSON(TimeOfDay timeOfDay) => {
  'hour': timeOfDay.hour,
  'minute': timeOfDay.minute,
};
TimeOfDay convertJSONtoTimeofDay(Map<String, int> jsonTimeofDay) =>
    TimeOfDay(hour: jsonTimeofDay['hour']!, minute: jsonTimeofDay['minute']!);
