import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wyd_front/state/detail_provider.dart';

class RangeEditor extends StatelessWidget {
  final DetailProvider provider;
  const RangeEditor({super.key, required this.provider});

  Future<DateTime?> selectDate(context, initialDate) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
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

  void checkValues(DetailProvider provider, DateTime start, DateTime end) {
    if (!end.isAfter(start)) {
      end = start.add(const Duration(hours: 1));
    }
    provider.updateDates(start, end);
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
                  key: UniqueKey(),
                  initialValue: provider.startTime,
                  decoration: const InputDecoration(
                    suffixIcon: Icon(Icons.calendar_today),
                    isDense: true, // Ensures a more compact height
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                  format: constraints.maxWidth > 375
                      ? DateFormat("EEEE, dd MMMM yyyy")
                      : DateFormat("dd/MM/yy"),
                  onChanged: (DateTime? value) {
                    if (value != null) {
                      value = DateTimeField.combine(value,
                          TimeOfDay.fromDateTime(provider.startTime));
                      checkValues(
                          provider, value, provider.endTime);
                    }
                  },
                  onShowPicker: selectDate,
                ),
              ),
              SizedBox(
                width: constraints.maxWidth > 600
                    ? (constraints.maxWidth / 2) - 4
                    : constraints.maxWidth,
                child: DateTimeField(
                  key: UniqueKey(),
                  initialValue: provider.startTime,
                  decoration: const InputDecoration(
                    suffixIcon: Icon(Icons.access_time),
                    isDense: true, // Ensures a more compact height
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                  format: DateFormat("HH:mm"),
                  onChanged: (DateTime? value) {
                    if (value != null) {
                      value = DateTimeField.combine(provider.startTime,
                          TimeOfDay.fromDateTime(value));
                      checkValues(
                          provider, value, provider.endTime);
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
                width: constraints.maxWidth > 600
                    ? (constraints.maxWidth / 2) - 4
                    : constraints.maxWidth,
                child: DateTimeField(
                  key: UniqueKey(),
                  initialValue: provider.endTime,
                  decoration: const InputDecoration(
                    suffixIcon: Icon(Icons.calendar_today),
                    isDense: true, // Ensures a more compact height
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                  format: constraints.maxWidth > 375
                      ? DateFormat("EEEE, dd MMMM yyyy")
                      : DateFormat("dd/MM/yy"),
                  onChanged: (DateTime? value) {
                    if (value != null) {
                      value = DateTimeField.combine(value,
                          TimeOfDay.fromDateTime(provider.endTime));
                      checkValues(provider,
                          provider.startTime, value);
                    }
                  },
                  onShowPicker: selectDate,
                ),
              ),
              SizedBox(
                width: constraints.maxWidth > 600
                    ? (constraints.maxWidth / 2) - 4
                    : constraints.maxWidth,
                child: DateTimeField(
                  key: UniqueKey(),
                  initialValue: provider.endTime,
                  decoration: const InputDecoration(
                    suffixIcon: Icon(Icons.access_time),
                    isDense: true, // Ensures a more compact height
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                  format: DateFormat("HH:mm"),
                  onChanged: (DateTime? value) {
                    if (value != null) {
                      value = DateTimeField.combine(provider.endTime,
                          TimeOfDay.fromDateTime(value));
                      checkValues(provider,
                          provider.startTime, value);
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
