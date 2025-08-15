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
    for (var i in decoded) {
      i as Map<String, dynamic>;
      loadedData.add(
        Task(
          i["task"],
          i["complete"],
          fileName == "single_occurence_list"
              ? DateTime.parse(i["due"])
              : DateTime.now(),
          i["hour"] == null
              ? null
              : convertJSONtoTimeofDay(Map<String, int>.from(i["hour"])),
          fileName == "single_occurence_list"
              ? null
              : List<bool>.from(i["week"].map((e) => e as bool).toList()),
          i["id"],
        ),
      );
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
      "due": fileName == "single_occurence_list"
          ? i.dateTime.toIso8601String()
          : null,
      "hour": i.dueWhen == null ? null : convertTimeOfDayToJSON(i.dueWhen!),
      "week": fileName == "single_occurence_list" ? null : i.whenInWeek,
      "id": i.id,
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

List<Task> sortTasks(List<Task> tasks) {
  tasks.sort((a, b) => a.dateTime.compareTo(b.dateTime));
  return tasks;
}

Map<String, List<Task>> formatMultipleOcurrenceTasks(List<Task> tasks) {
  Map<int, String> dayToIndex = {
    0: "monday",
    1: "tuesday",
    2: "wensday",
    3: "thursday",
    4: "friday",
    5: "saturday",
    6: "sunday",
  };
  Map<String, List<Task>> formating = {
    "monday": [],
    "tuesday": [],
    "wensday": [],
    "thursday": [],
    "friday": [],
    "saturday": [],
    "sunday": [],
  };
  for (Task i in tasks) {
    List<bool> whenInWeek = i.whenInWeek!;
    for (int a = 0; a < whenInWeek.length; a++) {
      if (!whenInWeek[a]) continue;
      formating[dayToIndex[a]!]!.add(
        Task(i.task, i.isDone, DateTime.now(), i.dueWhen, i.whenInWeek),
      );
    }
  }
  return formating;
}
