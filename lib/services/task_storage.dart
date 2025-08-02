import 'package:path_provider/path_provider.dart';
import 'package:to_do_list/models/task.dart';
import 'dart:io';
import 'dart:convert';
Future<File> getLocalFile() async {
  final directory = await getApplicationDocumentsDirectory(); // Safe for mobile
  return File('${directory.path}/to_do_list.json');
}

Future<List<Task>> readTasks() async {
  try {
    final file = await getLocalFile();
    if (!await file.exists()) {
      await file.create(recursive: true);
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
