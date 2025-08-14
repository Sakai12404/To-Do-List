import 'package:flutter/material.dart';
import 'package:to_do_list/models/task.dart';

class CheckBoxlist extends StatefulWidget {
  final Task task;
  final bool isRecurring;
  const CheckBoxlist({
    super.key,
    required this.task,
    required this.isRecurring,
  });
  @override
  State<CheckBoxlist> createState() => _CheckBoxlist();
}

class _CheckBoxlist extends State<CheckBoxlist> {
  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            'Task: ${widget.task.task}',
            style: TextStyle(
              color: Colors.white,
              decoration: widget.task.isDone
                  ? TextDecoration.lineThrough
                  : null,
              decorationColor: Color.fromARGB(255, 234, 221, 255),
              decorationThickness: 3.5,
            ),
          ),
          SelectableText(
            widget.isRecurring ? 
            widget.task.dueWhen != null ? "Due: ${widget.task.dueWhen!.hourOfPeriod}:${widget.task.dueWhen!.minute} ${widget.task.dueWhen!.period.toString().substring(10, 12)}": "" 
            : "Due: ${widget.task.dateTime.toLocal().toString().split(' ')[0]} ${widget.task.dueWhen == null ? "" : "at: ${widget.task.dueWhen!.format(context)}"}",
            style: TextStyle(
              color: Colors.white,
              decoration: widget.task.isDone
                  ? TextDecoration.lineThrough
                  : null,
              decorationColor: Color.fromARGB(255, 234, 221, 255),
              decorationThickness: 3.5,
            ),
          ),
        ],
      ),
      value: widget.task.isDone,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: Colors.white,
      checkColor: Color.fromARGB(255, 79, 57, 140),
      onChanged: (bool? value) {
        setState(() {
          widget.task.isDone = value ?? false;
        });
      },
    );
  }
}
