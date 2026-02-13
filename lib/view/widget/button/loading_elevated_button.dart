import 'package:flutter/material.dart';

class LoadingElevatedButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final Future<void> Function() action;
  final bool shrink;
  final int shrinkwidth;
  final Color? textColor;
  final Color? iconColor;

  const LoadingElevatedButton({
    super.key,
    required this.text,
    required this.icon,
    required this.action,
    this.shrink = false,
    this.shrinkwidth = 400,
    this.textColor,
    this.iconColor,
  });

  @override
  State<LoadingElevatedButton> createState() => _LoadingElevatedButtonState();
}

class _LoadingElevatedButtonState extends State<LoadingElevatedButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // Determine visibility based on screen width
    bool showText = widget.shrink ? MediaQuery.of(context).size.width > widget.shrinkwidth : true;

    return ElevatedButton(
      onPressed: _isLoading ? null : _handlePress,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(widget.icon, color: widget.iconColor),
          if (showText) ...[
            const SizedBox(width: 8),
            Text(
              widget.text,
              style: TextStyle(fontSize: 18, color: widget.textColor),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handlePress() async {
    setState(() => _isLoading = true);
    try {
      await widget.action();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}