import 'package:flutter/material.dart';
import 'package:wyd_front/model/util/recurrency_config.dart';

class RecurrenceEditor extends StatefulWidget {
  final RecurrenceConfig? initialConfig;
  final ValueChanged<RecurrenceConfig?> onChanged;

  const RecurrenceEditor({
    super.key,
    this.initialConfig,
    required this.onChanged,
  });

  @override
  State<RecurrenceEditor> createState() => _RecurrenceEditorState();
}

class _RecurrenceEditorState extends State<RecurrenceEditor> {
  bool _enabled = false;
  RecurrenceFrequency _frequency = RecurrenceFrequency.weekly;
  int _interval = 1;
  List<int> _byWeekDay = [];
  DateTime? _until;

  @override
  void initState() {
    super.initState();
    if (widget.initialConfig != null) {
      _enabled = true;
      _frequency = widget.initialConfig!.frequency;
      _interval = widget.initialConfig!.interval;
      _byWeekDay = List.from(widget.initialConfig!.byWeekDay);
      _until = widget.initialConfig!.until;
    }
  }

  void _notify() {
    if (!_enabled) {
      widget.onChanged(null);
      return;
    }
    widget.onChanged(RecurrenceConfig(
      frequency: _frequency,
      interval: _interval,
      byWeekDay: _byWeekDay,
      until: _until,
    ));
  }

  void _toggleEnabled(bool value) {
    setState(() => _enabled = value);
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text("Recurrence", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Switch(
              value: _enabled,
              onChanged: _toggleEnabled,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
        if (_enabled) ...[
          const SizedBox(height: 6),
          _buildFrequencyRow(),
          if (_frequency == RecurrenceFrequency.weekly) ...[
            const SizedBox(height: 6),
            _buildWeekDaySelector(),
          ],
          const SizedBox(height: 6),
          _buildUntilRow(),
        ],
      ],
    );
  }

  Widget _buildFrequencyRow() {
    return Row(
      children: [
        const Text("Every "),
        SizedBox(
          width: 48,
          child: TextFormField(
            initialValue: _interval.toString(),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              border: OutlineInputBorder(),
            ),
            onChanged: (v) {
              final parsed = int.tryParse(v);
              if (parsed != null && parsed > 0) {
                setState(() => _interval = parsed);
                _notify();
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        DropdownButton<RecurrenceFrequency>(
          value: _frequency,
          isDense: true,
          items: const [
            DropdownMenuItem(value: RecurrenceFrequency.daily, child: Text("Day(s)")),
            DropdownMenuItem(value: RecurrenceFrequency.weekly, child: Text("Week(s)")),
            DropdownMenuItem(value: RecurrenceFrequency.monthly, child: Text("Month(s)")),
            DropdownMenuItem(value: RecurrenceFrequency.yearly, child: Text("Year(s)")),
          ],
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _frequency = val;
                if (val != RecurrenceFrequency.weekly) _byWeekDay = [];
              });
              _notify();
            }
          },
        ),
      ],
    );
  }

  Widget _buildWeekDaySelector() {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(7, (i) {
        final selected = _byWeekDay.contains(i);
        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (selected) {
                  _byWeekDay.remove(i);
                } else {
                  _byWeekDay.add(i);
                  _byWeekDay.sort();
                }
              });
              _notify();
            },
            child: CircleAvatar(
              radius: 14,
              backgroundColor: selected ? Colors.blue : Colors.grey.shade300,
              child: Text(
                labels[i],
                style: TextStyle(
                  fontSize: 12,
                  color: selected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildUntilRow() {
    return Row(
      children: [
        const Text("Until: "),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _until ?? DateTime.now().add(const Duration(days: 30)),
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              setState(() => _until = picked);
              _notify();
            }
          },
          child: Text(
            _until != null
                ? "${_until!.day.toString().padLeft(2, '0')}/${_until!.month.toString().padLeft(2, '0')}/${_until!.year}"
                : "No end date",
            style: TextStyle(
              color: _until != null ? Colors.black87 : Colors.grey,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        if (_until != null) ...[
          const SizedBox(width: 4),
          InkWell(
            onTap: () {
              setState(() => _until = null);
              _notify();
            },
            child: const Icon(Icons.clear, size: 16, color: Colors.grey),
          ),
        ],
      ],
    );
  }
}