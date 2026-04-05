import 'package:flutter/material.dart';
import 'package:rrule/rrule.dart';
import 'package:wyd_front/model/util/recurrency_config.dart';

class RecurrenceEditor extends StatefulWidget {
  final RecurrenceRule? initialRule;
  final ValueChanged<RecurrenceRule?> onChanged;
  final bool viewOnly;
  final double widthThreshold;

  const RecurrenceEditor({
    super.key,
    this.initialRule,
    required this.onChanged,
    this.viewOnly = false,
    this.widthThreshold = 450,
  });

  @override
  State<RecurrenceEditor> createState() => _RecurrenceEditorState();
}

class _RecurrenceEditorState extends State<RecurrenceEditor> {
  bool _enabled = false;
  Frequency _frequency = Frequency.weekly;
  int _interval = 1;
  List<int> _byWeekDay = [];
  DateTime? _until;

  @override
  void initState() {
    super.initState();
    final rule = widget.initialRule;
    if (rule != null) {
      _enabled = true;
      _frequency = rule.frequency;
      _interval = rule.interval ?? 1;
      final days = rule.byWeekDays.map((e) => e.day - 1).toList();
      days.sort();
      _byWeekDay = days;
      _until = rule.until;
    } else {
      final int currentDayIndex = DateTime.now().weekday - 1;
      _byWeekDay = [currentDayIndex];
    }
  }

  RecurrenceRule _buildRule() {
    return RecurrenceRule(
      frequency: _frequency,
      interval: _interval > 1 ? _interval : null,
      byWeekDays: _frequency == Frequency.weekly && _byWeekDay.isNotEmpty
          ? _byWeekDay.map((d) => ByWeekDayEntry(d + 1)).toList()
          : [],
      until: _until,
    );
  }

  void _notify() => widget.onChanged(_enabled ? _buildRule() : null);

  void _toggleEnabled(bool value) {
    setState(() => _enabled = value);
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.viewOnly) {
      if (widget.initialRule == null) {
        return const SizedBox.shrink(); // Show nothing if no recurrence
      }
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          children: [
            const Icon(Icons.repeat, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.initialRule!.toHumanReadable(),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth >= widget.widthThreshold;

        // Common toggle widget
        Widget toggleSection = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                "Does repeat",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Transform.scale(
              scale: 0.63,
              child: Switch(
                value: _enabled,
                onChanged: _toggleEnabled,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        );

        if (!_enabled) return toggleSection;

        if (isWide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Repeat | Every
              Row(
                children: [
                  toggleSection,
                  const SizedBox(width: 35),
                  _buildFrequencyRow(),
                ],
              ),
              // Row 2: Until | Weekdays
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Sized to match the toggleSection width (100 + switch width)
                  // to ensure vertical alignment of the second column
                  SizedBox(width: 180, child: _buildUntilRow()),
                  const SizedBox(width: 20),
                  if (_frequency == Frequency.weekly) _buildWeekDaySelector() else const SizedBox.shrink(),
                ],
              ),
              const SizedBox(height: 10),
            ],
          );
        } else {
          // --- NARROW LAYOUT: Vertical Stack ---
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              toggleSection,
              _buildFrequencyRow(),
              if (_frequency == Frequency.weekly) ...[
                const SizedBox(height: 10),
                _buildWeekDaySelector(),
              ],
              const SizedBox(height: 10),
              _buildUntilRow(),
              const SizedBox(height: 10),
            ],
          );
        }
      },
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
        DropdownButton<Frequency>(
          value: _frequency,
          isDense: true,
          items: const [
            DropdownMenuItem(value: Frequency.daily, child: Text("Day(s)")),
            DropdownMenuItem(value: Frequency.weekly, child: Text("Week(s)")),
            DropdownMenuItem(value: Frequency.monthly, child: Text("Month(s)")),
            DropdownMenuItem(value: Frequency.yearly, child: Text("Year(s)")),
          ],
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _frequency = val;
                if (val != Frequency.weekly) _byWeekDay = [];
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
        Text("Ends: "),
        _buildUntilPicker(),
      ],
    );
  }

  Widget _buildUntilPicker() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _until ?? DateTime.now().add(const Duration(days: 30)),
              firstDate: DateTime.now(),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              setState(() => _until = picked.toUtc());
              _notify();
            }
          },
          child: Text(
            (_until != null && _until!.isBefore(DateTime(9999, 1, 1)))
                ? "${_until!.day.toString().padLeft(2, '0')}/${_until!.month.toString().padLeft(2, '0')}/${_until!.year}"
                : "Never",
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
