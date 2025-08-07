import 'package:flutter/material.dart';

class Task {
  String task;
  bool isDone;
  DateTime dateTime;
  TimeOfDay? dueWhen;
  Task(this.task, this.isDone, this.dateTime, [this.dueWhen]);
}