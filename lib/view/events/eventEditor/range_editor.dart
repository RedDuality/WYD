import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RangeEditor extends StatelessWidget {
  final DateTime startTime;
  final DateTime endTime;
  final Function(DateTime, DateTime) onDateChanged;

  const RangeEditor({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.onDateChanged,
  });

  Future<DateTime?> selectDate(BuildContext context, initialDate) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
  }

  Future<DateTime?> selectTime(BuildContext context, initialDate) async {
    var initialTime = TimeOfDay.fromDateTime(initialDate);
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: initialTime);

    if (picked != null && picked != initialTime) {
      return DateTimeField.combine(initialDate, picked);
    }
    return null;
  }

  void checkValues(DateTime start, DateTime end) {
    if (!end.isAfter(start)) {
      end = start.add(const Duration(hours: 1));
    }
    onDateChanged(start, end);
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
                width: constraints.maxWidth > 600 ? constraints.maxWidth / 2 - 4 : constraints.maxWidth,
                child: DateTimeField(
                  key: UniqueKey(),
                  initialValue: startTime,
                  decoration: const InputDecoration(
                    suffixIcon: Icon(Icons.calendar_today),
                    isDense: true, // Ensures a more compact height
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                  format: constraints.maxWidth > 375 ? DateFormat("EEEE, dd MMMM yyyy") : DateFormat("dd/MM/yy"),
                  onChanged: (DateTime? value) {
                    if (value != null) {
                      value = DateTimeField.combine(value, TimeOfDay.fromDateTime(startTime));
                      checkValues(value, endTime);
                    }
                  },
                  onShowPicker: selectDate,
                ),
              ),
              SizedBox(
                width: constraints.maxWidth > 600 ? (constraints.maxWidth / 2) - 4 : constraints.maxWidth,
                child: DateTimeField(
                  key: UniqueKey(),
                  initialValue: startTime,
                  decoration: const InputDecoration(
                    suffixIcon: Icon(Icons.access_time),
                    isDense: true, // Ensures a more compact height
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                  format: DateFormat("HH:mm"),
                  onChanged: (DateTime? value) {
                    if (value != null) {
                      value = DateTimeField.combine(startTime, TimeOfDay.fromDateTime(value));
                      checkValues(value, endTime);
                    }
                  },
                  onShowPicker: selectTime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text("Fine"),
          Wrap(
            spacing: 8.0, // Space between widgets horizontally
            runSpacing: 8.0, // Space between widgets vertically
            children: [
              SizedBox(
                width: constraints.maxWidth > 600 ? (constraints.maxWidth / 2) - 4 : constraints.maxWidth,
                child: DateTimeField(
                  key: UniqueKey(),
                  initialValue: endTime,
                  decoration: const InputDecoration(
                    suffixIcon: Icon(Icons.calendar_today),
                    isDense: true, // Ensures a more compact height
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                  format: constraints.maxWidth > 375 ? DateFormat("EEEE, dd MMMM yyyy") : DateFormat("dd/MM/yy"),
                  onChanged: (DateTime? value) {
                    if (value != null) {
                      value = DateTimeField.combine(value, TimeOfDay.fromDateTime(endTime));
                      checkValues(startTime, value);
                    }
                  },
                  onShowPicker: selectDate,
                ),
              ),
              SizedBox(
                width: constraints.maxWidth > 600 ? (constraints.maxWidth / 2) - 4 : constraints.maxWidth,
                child: DateTimeField(
                  key: UniqueKey(),
                  initialValue: endTime,
                  decoration: const InputDecoration(
                    suffixIcon: Icon(Icons.access_time),
                    isDense: true, // Ensures a more compact height
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                  format: DateFormat("HH:mm"),
                  onChanged: (DateTime? value) {
                    if (value != null) {
                      value = DateTimeField.combine(endTime, TimeOfDay.fromDateTime(value));
                      checkValues(startTime, value);
                    }
                  },
                  onShowPicker: selectTime,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}
