import 'package:flutter/material.dart';

class TitleEditor extends StatefulWidget {
  final TextEditingController controller;
  final bool isCollapsed;

  const TitleEditor({
    super.key,
    required this.controller,
    required this.isCollapsed,
  });

  @override
  State<TitleEditor> createState() => _TitleEditorState();
}

class _TitleEditorState extends State<TitleEditor> {
  bool isEditing = false;

  void _startEditing() => setState(() => isEditing = true);
  void _stopEditing() => setState(() => isEditing = false);

  @override
  Widget build(BuildContext context) {
    final showAsText = widget.isCollapsed || !isEditing;

    return Container(
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.only(left: 16.0, right: 16),
      child: showAsText
          ? GestureDetector(
              onTap: widget.isCollapsed ? null : _startEditing,
              child: Padding(
                padding: widget.isCollapsed
                    ? const EdgeInsets.only(right: 35.0, bottom: 16.0)
                    : const EdgeInsets.only(bottom: 14.0),
                child: Text(
                  widget.controller.text.isNotEmpty
                      ? widget.controller.text
                      : "Evento senza nome",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
              ),
            )
          : Focus(
              onFocusChange: (hasFocus) {
                if (!hasFocus) _stopEditing();
              },
              child: TextFormField(
                controller: widget.controller,
                maxLines: 1,
                autofocus: true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
            ),
    );
  }
}
