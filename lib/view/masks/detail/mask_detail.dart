import 'package:flutter/material.dart';
import 'package:wyd_front/API/Mask/create_mask_request_dto.dart';
import 'package:wyd_front/model/mask/mask.dart';
import 'package:wyd_front/service/mask/mask_service.dart';
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

  void _checkChanges() {
    debugPrint("checkChanges");
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

  bool get _isUpdate => widget.originalMask != null;

  Future<void> _handleSave() async {
    // TODO create a shared event
    if (_isUpdate) {
      //TODO
      // await _update(); // You'll need to implement this
    } else {
      await _create();
    }

    if (mounted) Navigator.of(context).pop();
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
              if (widget.edit)
                // Buttons
                Align(
                  alignment: Alignment.bottomRight,
                  child: FloatingActionButton.extended(
                    onPressed: _isLoading ? null : _handleSave,
                    label: Text(_isUpdate ? 'Update' : 'Create'),
                    icon: _isLoading
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator())
                        : const Icon(Icons.save),
                  ),
                ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: _exitButton(),
          ),
        ],
      ),
    );
  }

  Widget _exitButton() {
    return TextButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      style: TextButton.styleFrom(
        foregroundColor: Colors.grey,
      ),
      child: const Icon(
        Icons.close,
        size: 36,
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}
