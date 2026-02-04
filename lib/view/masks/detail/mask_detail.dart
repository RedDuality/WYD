import 'package:flutter/material.dart';
import 'package:wyd_front/API/Event/create_event_request_dto.dart';
import 'package:wyd_front/API/Mask/create_mask_request_dto.dart';
import 'package:wyd_front/API/Mask/update_mask_request_dto.dart';
import 'package:wyd_front/model/mask/mask.dart';
import 'package:wyd_front/service/event/event_actions_service.dart';
import 'package:wyd_front/service/mask/mask_service.dart';
import 'package:wyd_front/view/widget/button/exit_button.dart';
import 'package:wyd_front/view/widget/util/range_editor.dart';

class MaskDetail extends StatefulWidget {
  final Mask? originalMask;
  final DateTimeRange? initialDateRange;
  final List<String>? profileIds;

  final bool edit;

  const MaskDetail({
    super.key,
    this.originalMask,
    this.initialDateRange,
    this.profileIds,
    this.edit = false,
  });

  @override
  State<MaskDetail> createState() => _MaskDetailState();
}

class _MaskDetailState extends State<MaskDetail> {
  final _titleController = TextEditingController();

  late DateTime _startTime;
  late DateTime _endTime;
  bool _isLoading = false;
  bool hasBeenChanged = false;

  @override
  void initState() {
    super.initState();

    _initTitle();

    _initDates();
  }

  void _initTitle() {
    if (widget.originalMask != null && widget.originalMask!.title != null) {
      _titleController.text = widget.originalMask!.title!;
    }
  }

  void _initDates() {
    if (widget.originalMask != null) {
      _startTime = widget.originalMask!.startTime;
      _endTime = widget.originalMask!.endTime;
    } else if (widget.initialDateRange != null) {
      _startTime = widget.initialDateRange!.start.toUtc();
      _endTime = widget.initialDateRange!.end.toUtc();
    } else {
      final now = DateTime.now().toUtc();
      _startTime = now;
      _endTime = now.add(const Duration(hours: 1));
    }
  }

  void _setDates(DateTime startTime, DateTime endTime) {
    setState(() {
      _startTime = startTime;
      _endTime = endTime;
    });
    _checkChanges();
  }

  void _checkChanges() {
    if (!_eventExists) return;

    final startTimeChanged = _startTime != widget.originalMask!.startTime;
    final endTimeChanged = _endTime != widget.originalMask!.endTime;
    final titleChanged = _titleController.text != widget.originalMask!.title;

    final changed = startTimeChanged || endTimeChanged || titleChanged;

    if (changed != hasBeenChanged) {
      setState(() {
        hasBeenChanged = changed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Title"),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  style: const TextStyle(fontSize: 14),
                  controller: _titleController,
                  onChanged: (value) => _checkChanges(),
                  decoration: const InputDecoration(
                    hintText: 'No title',
                    contentPadding: EdgeInsets.symmetric(vertical: 4),
                    isDense: true,
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                ),
              ),
              RangeEditor(
                startTime: _startTime,
                endTime: _endTime,
                onDateChanged: _setDates,
                viewOnly: !widget.edit,
              ),
              const SizedBox(height: 5),
              if (_canEdit)
                Align(
                  alignment: Alignment.bottomRight,
                  child: _saveButton(),
                ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: ExitButton(),
          ),
        ],
      ),
    );
  }

  bool get _eventExists => widget.originalMask != null;

  bool get _canEdit => widget.edit;
  bool get _proposing => widget.profileIds != null && widget.profileIds!.isNotEmpty;

  Widget _saveButton() {
    if (!_eventExists && !_proposing) {
      return _actionButton('Create', _create);
    } else if (!_eventExists && _proposing) {
      return _actionButton('Create and share', _proposeEvent);
    } else if (_eventExists && hasBeenChanged) {
      return _actionButton('Update', _update);
    }

    return SizedBox.shrink();
  }

  Widget _actionButton(String text, VoidCallback handleFunction) {
    return TextButton.icon(
      onPressed: _isLoading ? null : handleFunction,
      icon: _isLoading
          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator())
          : const Icon(Icons.event, size: 30, color: Colors.white),
      label: Text(
        text,
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10),
      ),
    );
  }

  Future<void> _create() async {
    setState(() => _isLoading = true);
    try {
      var createDto = CreateMaskRequestDto(
        title: _titleController.text.isEmpty ? null : _titleController.text,
        startTime: _startTime,
        endTime: _endTime,
      );
      await MaskService.create(createDto);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mask created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error:  $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _update() async {
    setState(() => _isLoading = true);
    try {
      var updateDto = UpdateMaskRequestDto(
        maskId: widget.originalMask!.id,
        title: _titleController.text.isEmpty ? null : _titleController.text,
        startTime: _startTime,
        endTime: _endTime,
      );
      await MaskService.update(updateDto);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mask updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error:  $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _proposeEvent() async {
    setState(() => _isLoading = true);
    try {
      var createDto = CreateEventRequestDto(
        title: _titleController.text.isEmpty ? 'Proposed event' : _titleController.text,
        startTime: _startTime,
        endTime: _endTime,
        invitedProfileIds: widget.profileIds!,
      );
      await EventActionsService.create(createDto);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event proposed successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error:  $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}
