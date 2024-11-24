import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RangeEditor extends StatefulWidget {
  final DateTime initialStartDate;
  final DateTime initialEndDate;
  final ValueChanged<Map<String, DateTime>> onDateChanged;

  const RangeEditor({
    super.key,
    required this.initialStartDate,
    required this.initialEndDate,
    required this.onDateChanged,
  });

  @override
  State<RangeEditor> createState() => _RangeEditorState();
}

class _RangeEditorState extends State<RangeEditor> {
  late DateTime startDate;
  late DateTime endDate;

  @override
  void initState() {
    super.initState();
    startDate = widget.initialStartDate;
    endDate = widget.initialEndDate;
  }

  Future<DateTime?> selectDate(context, initialDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != initialDate) {
      return picked;
    }
    return null;
  }

  Future<DateTime?> selectTime(context, initialDate) async {
    var initialTime = TimeOfDay.fromDateTime(initialDate);
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: initialTime);
    if (picked != null && picked != initialTime) {
      return DateTimeField.combine(initialDate, picked);
    }
    return null;
  }

  void checkValues() {
    if (endDate.isBefore(startDate)) {
      endDate = startDate.add(const Duration(hours: 1));
    }
    widget.onDateChanged({
      'startDate': startDate,
      'endDate': endDate,
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Inizio"),
          Wrap(
            spacing: 8.0, // Space between widgets horizontally
            runSpacing: 8.0, // Space between widgets vertically
            children: [
              SizedBox(
                width: constraints.maxWidth > 600
                    ? constraints.maxWidth / 2 - 4
                    : constraints.maxWidth,
                child: DateTimeField(
                  initialValue: startDate,
                  decoration: const InputDecoration(
                    suffixIcon: Icon(Icons.calendar_today),
                    isDense: true, // Ensures a more compact height
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                  format: DateFormat("EEEE, dd MMMM yyyy"),
                  onChanged: (DateTime? value) {
                    if (value != null) {
                      startDate = value;
                      checkValues();
                    }
                  },
                  onShowPicker: selectDate,
                ),
              ),
              SizedBox(
                  width: constraints.maxWidth > 600
                      ? constraints.maxWidth / 2 - 4
                      : constraints.maxWidth,
                  child: DateTimeField(
                    initialValue: startDate,
                    decoration: const InputDecoration(
                      suffixIcon: Icon(Icons.access_time),
                      isDense: true, // Ensures a more compact height
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                    format: DateFormat("HH:mm"),
                    onChanged: (DateTime? value) {
                      if (value != null) {
                        startDate = value;
                        checkValues();
                      }
                    },
                    onShowPicker: selectTime,
                  )),
            ],
          ),
          const SizedBox(height: 8),
          const Text("Fine"),
          Wrap(
            spacing: 8.0, // Space between widgets horizontally
            runSpacing: 8.0, // Space between widgets vertically
            children: [
              SizedBox(
                width: constraints.maxWidth > 600
                    ? constraints.maxWidth / 2 - 4
                    : constraints.maxWidth,
                child: DateTimeField(
                  initialValue: endDate,
                  decoration: const InputDecoration(
                    suffixIcon: Icon(Icons.calendar_today),
                    isDense: true, // Ensures a more compact height
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                  format: DateFormat("EEEE, dd MMMM yyyy"),
                  onChanged: (DateTime? value) {
                    if (value != null) {
                      endDate = value;
                      checkValues();
                    }
                  },
                  onShowPicker: selectDate,
                ),
              ),
              SizedBox(
                  width: constraints.maxWidth > 600
                      ? constraints.maxWidth / 2 - 4
                      : constraints.maxWidth,
                  child: DateTimeField(
                    initialValue: endDate,
                    decoration: const InputDecoration(
                      suffixIcon: Icon(Icons.access_time),
                      isDense: true, // Ensures a more compact height
                      border: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                    format: DateFormat("HH:mm"),
                    onChanged: (DateTime? value) {
                      if (value != null) {
                        endDate = value;
                        checkValues();
                      }
                    },
                    onShowPicker: selectTime,
                  )),
            ],
          )
        ],
      );
    });
  }
}
