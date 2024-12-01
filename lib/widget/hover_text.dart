
import 'package:flutter/material.dart';

class HoverText extends StatefulWidget {
  final String text;
  final Color hoverColor;
  final Color defaultColor;
  final double fontSize;

  const HoverText({
    super.key,
    required this.text,
    this.hoverColor = Colors.blue,
    this.defaultColor = Colors.black,
    this.fontSize = 18.0,
  });

  @override
  State<HoverText> createState() => _HoverTextState();
}

class _HoverTextState extends State<HoverText> {
  late Color _textColor;

  @override
  void initState() {
    super.initState();
    _textColor = widget.defaultColor;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) => setState(() {
        _textColor = widget.hoverColor;
      }),
      onExit: (event) => setState(() {
        _textColor = widget.defaultColor;
      }),
      child: Text(
        widget.text,
        style: TextStyle(color: _textColor, fontSize: widget.fontSize),
      ),
    );
  }
}