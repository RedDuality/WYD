import 'package:flutter/material.dart';

class OverlayListButton extends StatefulWidget {
  final Widget child;
  final String title;

  const OverlayListButton(
      {super.key, required this.child, required this.title});

  @override
  _OverlayListButtonState createState() => _OverlayListButtonState();
}

class _OverlayListButtonState extends State<OverlayListButton> {
  OverlayEntry? _overlayEntry;
  bool _isOverlayVisible = false;

  void _toggleOverlay(BuildContext context) {
    if (_isOverlayVisible) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isOverlayVisible = false;
    } else {
      _overlayEntry = _createOverlayEntry(context);
      Overlay.of(context).insert(_overlayEntry!);
      _isOverlayVisible = true;
    }
  }

  OverlayEntry _createOverlayEntry(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    

    var isWideScreen = MediaQuery.of(context).size.width > 450;
    double width = isWideScreen ? 300 : 250;

    double leftPosition;
    if (!isWideScreen) {
      // Button is on the left side
      leftPosition = position.dx;
    } else {
      // Button is on the right side
      leftPosition = position.dx + size.width - width;
    }

    return OverlayEntry(
      builder: (context) => Positioned(
        left: leftPosition,
        top: position.dy + size.height + 4,
        width: width,
        height: 300,
        child: Material(
          color: Colors.transparent,
          child: ListScreen(
            child: widget.child,
            onClose: () {
              _overlayEntry?.remove();
              _overlayEntry = null;
              _isOverlayVisible = false;
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _toggleOverlay(context)),
      child: Text("${widget.title}Confirmed"),
    );
  }
}

class ListScreen extends StatelessWidget {
  final Widget child;
  final Function? onClose;

  const ListScreen({required this.child, this.onClose, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5.0,
            spreadRadius: 2.0,
          ),
        ],
      ),
      child: Column(
        children: [
          if (onClose != null)
            ElevatedButton(
              onPressed: () {
                onClose!();
              },
              child: Text('Close'),
            ),
          SizedBox(height: 10),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  child,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
