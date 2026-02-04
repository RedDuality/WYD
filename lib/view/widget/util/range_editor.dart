import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RangeEditor extends StatelessWidget {
  // TODO add a view-only bool option

  final DateTime startTime;
  final DateTime endTime;
  final Function(DateTime, DateTime) onDateChanged;
  final bool viewOnly;

  const RangeEditor({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.onDateChanged,
    this.viewOnly = false,
  });

  Future<DateTime?> selectDate(BuildContext context,initialDate) async {
    if (viewOnly) return null;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != startTime) {
      final start = DateTimeField.combine(picked, TimeOfDay.fromDateTime(startTime));
      checkValues(start, endTime);
    }
    return picked;
  }

  Future<DateTime?> selectTime(BuildContext context, initialDate) async {
    if (viewOnly) return null;

    var initialTime = TimeOfDay.fromDateTime(initialDate );
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: initialTime);

    if (picked != null && picked != initialTime) {
      return DateTimeField.combine(initialDate , picked);
    }
    return null;
  }

  void checkValues(DateTime start, DateTime end) {
    if (!end.isAfter(start)) {
      end = start.add(const Duration(hours: 1));
    }
    onDateChanged(start, end);
  }

// Helper to centralize the "disabled" decoration style
  InputDecoration _getDecoration({required IconData? icon, bool showIcon = true}) {
    return InputDecoration(
      suffixIcon: const SizedBox.shrink(),
      suffixIconConstraints: const BoxConstraints(minWidth: 4.0, minHeight: 0),
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      prefixIcon: showIcon && icon != null
          ? Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: Icon(icon, size: 18),
            )
          : null,
      isDense: true,
      border: viewOnly ? InputBorder.none : const OutlineInputBorder(borderSide: BorderSide.none),
      // Ensures the text doesn't look grayed out if you want it readable
      enabled: !viewOnly,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IntrinsicWidth(
            child: DateTimeField(
              enabled: !viewOnly,
              initialValue: startTime,
              decoration: _getDecoration(icon: Icons.calendar_today),
              format: constraints.maxWidth > 400 ? DateFormat("EEEE, dd MMMM yyyy") : DateFormat("dd/MM"),
              onShowPicker: viewOnly ? (context, currentValue) async => currentValue : selectDate,
            ),
          ),
          IntrinsicWidth(
            child: DateTimeField(
              enabled: !viewOnly,
              initialValue: startTime,
              decoration: _getDecoration(icon: Icons.access_time),
              format: DateFormat("HH:mm"),
              onChanged: viewOnly
                  ? null
                  : (DateTime? value) {
                      if (value != null) {
                        final start = DateTimeField.combine(startTime, TimeOfDay.fromDateTime(value));
                        checkValues(start, endTime);
                      }
                    },
              onShowPicker: viewOnly ? (context, currentValue) async => currentValue : selectTime,
            ),
          ),
          const Text("- "),
          IntrinsicWidth(
            child: DateTimeField(
              enabled: !viewOnly,
              initialValue: endTime,
              decoration: _getDecoration(icon: null, showIcon: false),
              format: DateFormat("HH:mm"),
              onChanged: viewOnly
                  ? null
                  : (DateTime? value) {
                      if (value != null) {
                        final end = DateTimeField.combine(endTime, TimeOfDay.fromDateTime(value));
                        checkValues(startTime, end);
                      }
                    },
              onShowPicker: viewOnly ? (context, currentValue) async => currentValue : selectTime,
            ),
          ),
        ],
      );
    });
  }
}
