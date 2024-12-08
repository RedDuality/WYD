import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DateRangeProvider with ChangeNotifier {
  DateTime _startDate;
  DateTime _endDate;
  VoidCallback? onChanged;

  DateRangeProvider(this._startDate, this._endDate, {this.onChanged});

  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;

  void updateStartDate(DateTime newStartDate) {
    _startDate = newStartDate;
    notifyListeners();
    onChanged?.call();
  }

  void updateEndDate(DateTime newEndDate) {
    _endDate = newEndDate;
    notifyListeners();
    onChanged?.call();
  }

  void updateDates(DateTime newStartDate, DateTime newEndDate) {
    _startDate = newStartDate;
    _endDate = newEndDate;
    notifyListeners();
    onChanged?.call();
  }
}

class RangeEditor extends StatelessWidget {
  const RangeEditor({super.key});

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

  void checkValues(dateRangeProvider, start, end) {
    if (end.isBefore(start)) {
      end = start.add(const Duration(hours: 1));
    }
    dateRangeProvider.updateDates(start, end);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DateRangeProvider>(
      builder: (context, dateRangeProvider, child) {
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
                      initialValue: dateRangeProvider.startDate,
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
                          value = DateTimeField.combine(
                              value,
                              TimeOfDay.fromDateTime(
                                  dateRangeProvider.startDate));
                          checkValues(dateRangeProvider, value,
                              dateRangeProvider.endDate);
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
                      key: UniqueKey(),
                      initialValue: dateRangeProvider.startDate,
                      decoration: const InputDecoration(
                        suffixIcon: Icon(Icons.access_time),
                        isDense: true, // Ensures a more compact height
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                      ),
                      format: DateFormat("HH:mm"),
                      onChanged: (DateTime? value) {
                        if (value != null) {
                          value = DateTimeField.combine(
                              dateRangeProvider.startDate,
                              TimeOfDay.fromDateTime(value));
                          checkValues(dateRangeProvider, value,
                              dateRangeProvider.endDate);
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
                        ? constraints.maxWidth / 2 - 4
                        : constraints.maxWidth,
                    child: DateTimeField(
                      key: UniqueKey(),
                      initialValue: dateRangeProvider.endDate,
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
                          value = DateTimeField.combine(
                              value,
                              TimeOfDay.fromDateTime(
                                  dateRangeProvider.endDate));
                          checkValues(dateRangeProvider,
                              dateRangeProvider.startDate, value);
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
                      key: UniqueKey(),
                      initialValue: dateRangeProvider.endDate,
                      decoration: const InputDecoration(
                        suffixIcon: Icon(Icons.access_time),
                        isDense: true, // Ensures a more compact height
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                      ),
                      format: DateFormat("HH:mm"),
                      onChanged: (DateTime? value) {
                        if (value != null) {
                          value = DateTimeField.combine(
                              dateRangeProvider.endDate,
                              TimeOfDay.fromDateTime(value));
                          checkValues(dateRangeProvider,
                              dateRangeProvider.startDate, value);
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
      },
    );
  }

}
