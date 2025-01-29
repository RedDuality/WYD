import 'package:flutter/material.dart';

class OverlayListButton extends StatefulWidget {
  final Widget child;
  final String title;

  const OverlayListButton(
      {super.key, required this.child, required this.title});

  @override
  OverlayListButtonState createState() => OverlayListButtonState();
}

class OverlayListButtonState extends State<OverlayListButton> {
  OverlayEntry? _overlayEntry;
  bool _isOverlayVisible = false;
    final GlobalKey _overlayKey = GlobalKey();

  void _closeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isOverlayVisible = false;
  }

  void _toggleOverlay(BuildContext context) {
    if (_isOverlayVisible) {
      _closeOverlay();
    } else {
      _overlayEntry = _createOverlayEntry(context);
      Overlay.of(context).insert(_overlayEntry!);
      _isOverlayVisible = true;
    }
  }

  void _updateOverlayPosition(BuildContext context) {
    if (_isOverlayVisible) {
      _overlayEntry?.remove();
      _overlayEntry = _createOverlayEntry(context);
      Overlay.of(context).insert(_overlayEntry!);
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
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              //closes on tap outside
              onTap: () {
                _closeOverlay();
              },
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          Positioned(
            left: leftPosition,
            top: position.dy + size.height + 4,
            width: width,
            height: 300,
            child: Material(
              color: Colors.transparent,
              child: ListScreen(
                key: _overlayKey,
                child: widget.child,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateOverlayPosition(context);
        });
        return GestureDetector(
          onTap: () => setState(() => _toggleOverlay(context)),
          child: Text(widget.title),
        );
      },
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
            blurRadius: 4.0,
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
