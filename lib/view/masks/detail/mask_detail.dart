import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wyd_front/API/Mask/create_mask_request_dto.dart';
import 'package:wyd_front/model/mask/mask.dart';
import 'package:wyd_front/service/mask/mask_service.dart';
import 'package:wyd_front/view/widget/button/exit_button.dart';
import 'package:wyd_front/view/widget/util/range_editor.dart';

class MaskDetail extends StatefulWidget {
  final Mask? originalMask;
  final DateTimeRange? initialDateRange;

  final bool edit;
  final bool propose; // TODO

  const MaskDetail({
    super.key,
    this.originalMask,
    this.initialDateRange,
    this.edit = false,
    this.propose = false,
  });

  @override
  State<MaskDetail> createState() => _MaskDetailState();
}

class _MaskDetailState extends State<MaskDetail> {
  final _titleController = TextEditingController();

  late DateTime _startTime;
  late DateTime _endTime;
  bool _isLoading = false;

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
              ),
              const SizedBox(height: 5),
              if (_canEdit)
                Align(
                  alignment: Alignment.bottomRight,
                  child: _actionButton(),
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

  Widget _actionButton() {
    return FloatingActionButton.extended(
      onPressed: _isLoading ? null : _handleSave,
      label: Text(_eventExists ? 'Update' : 'Create'),
      icon: _isLoading
          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator())
          : const Icon(Icons.save),
    );
  }

/*
 1. Create
 2. create and Share
 3. nothing to update yet
 4. update
 */ 
  Future<void> _handleSave() async {
    // TODO create a shared event
    if (_eventExists) {
      //TODO
      await _update(); 
    } else {
      await _create();
    }

    if (mounted) Navigator.of(context).pop();
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
      }
    }
  }

  void _checkChanges() {
    debugPrint("checkChanges");
  }

  Future<void> _update() async {
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
      }
    }
  }

  Future<void> _createAndShare() async {
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
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}
