import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RangeEditor extends StatefulWidget {
  final DateTime startTime;
  final DateTime endTime;
  final Function(DateTime, DateTime) onDateChanged;
  final bool viewOnly;
  final double widthThreshold;

  const RangeEditor({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.onDateChanged,
    this.viewOnly = false,
    this.widthThreshold = 450,
  });

  @override
  State<RangeEditor> createState() => _RangeEditorState();
}

class _RangeEditorState extends State<RangeEditor> {
  bool _manuallyExpanded = false;

  // Check if start and end are on the same calendar day
  bool get isSameDay =>
      widget.startTime.year == widget.endTime.year &&
      widget.startTime.month == widget.endTime.month &&
      widget.startTime.day == widget.endTime.day;

  // The UI should show two lines if the dates are different OR the user clicked "+"
  bool get isExpanded => !isSameDay || _manuallyExpanded;

  Future<DateTime?> selectDate(BuildContext context, DateTime? initialDate) async {
    if (widget.viewOnly) return null;
    
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    return picked;
  }

  Future<DateTime?> selectTime(BuildContext context, DateTime? initialDate) async {
    if (widget.viewOnly) return null;
    
    var initialTime = TimeOfDay.fromDateTime(initialDate ?? DateTime.now());
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: initialTime);

    if (picked != null) {
      return DateTimeField.combine(initialDate ?? DateTime.now(), picked);
    }
    return null;
  }

  void _handleStartChange(DateTime? newStart) {
    if (newStart == null) return;
    
    DateTime newEnd = widget.endTime;
    // If we move the start date/time past the end, push the end forward
    if (!newEnd.isAfter(newStart)) {
      newEnd = newStart.add(const Duration(hours: 1));
    }
    widget.onDateChanged(newStart, newEnd);
  }

  void _handleEndChange(DateTime? newEnd) {
    if (newEnd == null) return;

    DateTime finalEnd = newEnd;
    // If the user picked an end date/time before the start, force it to be after
    if (!finalEnd.isAfter(widget.startTime)) {
      finalEnd = widget.startTime.add(const Duration(hours: 1));
    }
    widget.onDateChanged(widget.startTime, finalEnd);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final bool isWide = constraints.maxWidth > widget.widthThreshold;
      final dateFormat = isWide ? DateFormat("EEEE, dd MMMM yyyy") : DateFormat("dd/MM");

      if (isExpanded) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateRow(
              label: "Start:",
              date: widget.startTime,
              dateFormat: dateFormat,
              onChanged: _handleStartChange,
              showDate: true,
            ),
            _buildDateRow(
              label: "End:  ",
              date: widget.endTime,
              dateFormat: dateFormat,
              onChanged: _handleEndChange,
              showDate: true,
              // Show a "-" button to collapse if they are on the same day
              trailing: !widget.viewOnly && isSameDay
                  ? IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                      onPressed: () => setState(() => _manuallyExpanded = false),
                    )
                  : null,
            ),
          ],
        );
      }

      // Single line mode (Same day)
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDateField(widget.startTime, dateFormat, _handleStartChange, true),
          _buildTimeField(widget.startTime, _handleStartChange),
          const Text(" - "),
          _buildTimeField(widget.endTime, _handleEndChange),
          if (!widget.viewOnly)
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.add_circle_outline, size: 20),
              onPressed: () => setState(() => _manuallyExpanded = true),
            ),
        ],
      );
    });
  }

  Widget _buildDateRow({
    required String label,
    required DateTime date,
    required DateFormat dateFormat,
    required Function(DateTime?) onChanged,
    bool showDate = true,
    Widget? trailing,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 45, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
        _buildDateField(date, dateFormat, onChanged, showDate),
        _buildTimeField(date, onChanged),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildDateField(DateTime value, DateFormat format, Function(DateTime?) onChanged, bool visible) {
    if (!visible) return const SizedBox.shrink();
    return IntrinsicWidth(
      child: DateTimeField(
        enabled: !widget.viewOnly,
        key: UniqueKey(),
        initialValue: value,
        decoration: _inputDecoration(Icons.calendar_today),
        format: format,
        onShowPicker: selectDate,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTimeField(DateTime value, Function(DateTime?) onChanged) {
    return IntrinsicWidth(
      child: DateTimeField(
        enabled: !widget.viewOnly,
        key: UniqueKey(),
        initialValue: value,
        decoration: _inputDecoration(Icons.access_time),
        format: DateFormat("HH:mm"),
        onShowPicker: selectTime,
        onChanged: (val) {
          if (val != null) {
            final combined = DateTimeField.combine(value, TimeOfDay.fromDateTime(val));
            onChanged(combined);
          }
        },
      ),
    );
  }

  InputDecoration _inputDecoration(IconData icon) {
    return InputDecoration(
      suffixIcon: const SizedBox.shrink(),
      suffixIconConstraints: const BoxConstraints(minWidth: 4.0, minHeight: 0),
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      prefixIcon: Padding(
        padding: const EdgeInsets.only(right: 4.0),
        child: Icon(icon, size: 18),
      ),
      isDense: true,
      border: OutlineInputBorder(borderSide: BorderSide.none),
    );
  }
}