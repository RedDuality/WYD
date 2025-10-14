import 'package:flutter/material.dart';

class CardDisplay extends StatefulWidget {
  final BoxFit? fit;
  final double? maxWidth;
  final double? maxHeight;
  final bool? isSelected;
  final VoidCallback? onSelected;
  final VoidCallback? onUnSelected;
  final VoidCallback? onDelete;

  final Widget Function({
    VoidCallback? onLoadingFinished,
    VoidCallback? onError,
  }) mediaBuilder;

  const CardDisplay({
    super.key,
    this.fit,
    this.maxWidth,
    this.maxHeight,
    this.isSelected,
    this.onSelected,
    this.onUnSelected,
    this.onDelete,
    required this.mediaBuilder,
  });

  @override
  CardDisplayState createState() => CardDisplayState();
}

class CardDisplayState extends State<CardDisplay> {
  bool _isLoading = true;
  bool _isError = false;
  bool? _isSelected;

  @override
  void initState() {
    super.initState();
    _isSelected = widget.isSelected;
  }

  @override
  void didUpdateWidget(covariant CardDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      // Update the internal state if the parent widget's property changes
      setState(() {
        _isSelected = widget.isSelected;
      });
    }
  }

  void _onLoadingFinished() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _onError() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isError = true;
          _isSelected = false;
          widget.onUnSelected?.call();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine the size for the image/placeholder
    final double? itemWidth = widget.maxWidth ?? widget.maxHeight;
    final double? itemHeight = widget.maxHeight ?? widget.maxWidth;

    return Card(
      elevation: 3.0,
      clipBehavior: Clip.antiAlias, // Ensures the overlay respects the card's border radius
      child: Stack(
        children: [
          SizedBox(
            width: itemWidth,
            height: itemHeight,
            child: widget.mediaBuilder(
              onLoadingFinished: _onLoadingFinished,
              onError: _onError,
            ),
          ),

          // Gray overlay when not selected and isSelected is not null
          if (!_isLoading && !_isError && _isSelected != null && !_isSelected!)
            Positioned.fill(
              child: Container(
                color: const Color.fromARGB(204, 0, 0, 0), // Gray translucent layer
              ),
            ),

          // Selection Checkbox Button in the upper left
          if (widget.isSelected != null && !_isError)
            Positioned(
              top: 8.0,
              left: 8.0,
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (_isSelected!) {
                      _isSelected = false;
                      widget.onUnSelected?.call();
                    } else {
                      _isSelected = true;
                      widget.onSelected?.call();
                    }
                  });
                },
                child: Container(
                  width: 32.0,
                  height: 32.0,
                  decoration: BoxDecoration(
                    color: _isSelected! ? Colors.grey : Colors.grey.withValues(alpha: 0.7), // Gray background
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.0), // White border
                  ),
                  child: _isSelected!
                      ? const Icon(
                          Icons.check,
                          color: Colors.white, // White checkmark
                          size: 20.0,
                        )
                      : null, // No icon when not selected
                ),
              ),
            ),

          // Delete Button in the upper right
          if (!_isLoading && _isError && widget.onDelete != null)
            Positioned(
              top: 8.0,
              right: 8.0,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: widget.onDelete,
              ),
            ),
        ],
      ),
    );
  }
}
