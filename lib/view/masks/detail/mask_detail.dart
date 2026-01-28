import 'package:flutter/material.dart';
import 'package:wyd_front/API/Mask/create_mask_request_dto.dart';
import 'package:wyd_front/model/mask/mask.dart';
import 'package:wyd_front/service/mask/mask_service.dart';
import 'package:wyd_front/view/widget/util/range_editor.dart';

class MaskDetail extends StatefulWidget {
  final bool edit;
  final Mask? originalMask;
  final DateTimeRange? initialDateRange;

  const MaskDetail({
    super.key,
    this.edit = false,
    this.originalMask,
    this.initialDateRange,
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

    if (widget.originalMask != null && widget.originalMask! .title != null) {
      _titleController.text = widget. originalMask!.title!;
    }

    if (widget.originalMask != null) {
      _startTime = widget.originalMask! .startTime;
      _endTime = widget.originalMask! .endTime;
    } else if (widget.initialDateRange != null) {
      _startTime = widget.initialDateRange!.start. toUtc();
      _endTime = widget.initialDateRange!.end.toUtc();
    } else {
      final now = DateTime.now().toUtc();
      _startTime = now;
      _endTime = now. add(const Duration(hours: 1));
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
        title: _titleController.text. isEmpty ? null : _titleController.text,
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
                padding:  const EdgeInsets.all(8.0),
                child: TextFormField(
                  style:  const TextStyle(fontSize: 14),
                  controller: _titleController,
                  onChanged:  (value) => _checkChanges(),
                  decoration: const InputDecoration(
                    hintText: 'No title',
                    contentPadding: EdgeInsets.symmetric(vertical: 4),
                    isDense:  true,
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                ),
              ),
              RangeEditor(
                startTime: _startTime,
                endTime: _endTime,
                onDateChanged:  _setDates,
              ),
              const SizedBox(height:  5),
              // Buttons
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed:  _isLoading
                      ? null
                      :  () async {
                          await _create();
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isLoading)
                        const SizedBox(
                          width:  16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      else
                        const Icon(Icons.save),
                      const SizedBox(width: 8),
                      if (MediaQuery.of(context).size.width > 400)
                        Text(
                          widget.originalMask != null ? 'Update' : 'Create',
                          style: const TextStyle(fontSize: 18),
                        ),
                    ],
                  ),
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
        foregroundColor:  Colors.grey,
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