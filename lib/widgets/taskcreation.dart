import 'package:flutter/material.dart';
import 'package:to_do_list/models/task.dart';
import 'package:day_picker/day_picker.dart';

class TaskCreation extends StatefulWidget {
  final bool isAdd;
  final bool isRecurring;
  final Task? task;
  final Function(Task) onSubmit;

  const TaskCreation({
    super.key,
    required this.isAdd,
    required this.isRecurring,
    this.task,
    required this.onSubmit,
  });
  @override
  State<TaskCreation> createState() => _TaskCreation();
}

class _TaskCreation extends State<TaskCreation> {
  late TextEditingController _controller;
  final ScrollController _scrollController = ScrollController();
  final FocusNode textFieldFocusNode = FocusNode();
  late List<DayInWeek> days;
  late DateTime selectedDate;
  TimeOfDay? selectedTime;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.isAdd ? "" : widget.task!.task,
    );
    days = [
      DayInWeek("Mon", dayKey: "monday"),
      DayInWeek("Tues", dayKey: "tuesday"),
      DayInWeek("Wens", dayKey: "wednesday"),
      DayInWeek("Thurs", dayKey: "thursday"),
      DayInWeek("Fri", dayKey: "friday"),
      DayInWeek("Sat", dayKey: "saturday"),
      DayInWeek("Sun", dayKey: "sunday"),
    ];
    selectedDate = widget.isAdd ? DateTime.now() : widget.task!.dateTime;
    selectedTime = widget.isAdd ? null : widget.task!.dueWhen;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Your task"),
      content: IntrinsicHeight(
        child: Column(
          children: [
            GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: Scrollbar(
                controller: _scrollController,
                child: TextField(
                  minLines: 1,
                  maxLines: 5,
                  scrollController: _scrollController,
                  controller: _controller,
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
            widget.isRecurring
                ? Column(
                    children: [
                      Text("Select days when task is needed to be complete"),
                      SelectWeekDays(
                        days: days,
                        onSelect: (days) => print(days),
                        backgroundColor: Colors.black87,
                        fontSize: 10.25,
                        fontWeight: FontWeight.bold,
                        boxDecoration: BoxDecoration(
                          color: Colors.black,
                          border: BoxBorder.all(width: 8.0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  )
                : StatefulBuilder(
                    builder: (context, setState) => TextButton.icon(
                      icon: Icon(Icons.calendar_today_rounded),
                      label: Text(
                        "Due: ${selectedDate.toLocal().toString().split(' ')[0]}",
                      ),
                      onPressed: () async {
                        DateTime? datePicked = await showDatePicker(
                          context: context,
                          initialDate: widget.isAdd
                              ? selectedDate
                              : widget.task!.dateTime,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        datePicked ??= widget.isAdd
                            ? selectedDate
                            : widget.task!.dateTime;
                        setState(() => selectedDate = datePicked!);
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
            String input = _controller.text.trim();
            if (input.isNotEmpty) {
              widget.onSubmit(
                Task(
                  input,
                  widget.isAdd ? false : widget.task!.isDone,
                  selectedDate,
                  selectedTime,
                  widget.isRecurring ? convertDaysOfWeek(days) : null,
                ),
              );
            }
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: Text("cancel"),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}

List<bool> convertDaysOfWeek(List<DayInWeek> days) {
  List<bool> daysInWeek = [];
  for (var i in days) {
    daysInWeek.add(i.isSelected);
  }
  return daysInWeek;
}
