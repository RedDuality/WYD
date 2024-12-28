import 'package:flutter/material.dart';

class ImageDisplay extends StatefulWidget {
  final ImageProvider image;
  final double? maxWidth;
  final double? maxHeight;
  final VoidCallback? onDelete;

  const ImageDisplay(
      {super.key,
      required this.image,
      this.maxWidth,
      this.maxHeight,
      this.onDelete});

  @override
  ImageDisplayState createState() => ImageDisplayState();
}

class ImageDisplayState extends State<ImageDisplay> {
  bool _isLoading = true;
  bool _isError = false;

  @override
  void initState() {
    super.initState();

    // Listen to the ImageProvider and update the loading state when the image is resolved.
    widget.image.resolve(const ImageConfiguration()).addListener(
          ImageStreamListener(
            (ImageInfo image, bool synchronousCall) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            onError: (Object error, StackTrace? stackTrace) {
              if (mounted) {
                setState(() {
                  _isError = true;
                  _isLoading = false;
                });
              }
            },
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    
    return Card(
      elevation: 3.0,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: _isLoading || _isLoading
                ? SizedBox(
                    width: widget.maxWidth ?? widget.maxHeight,
                    height: widget.maxHeight ?? widget.maxWidth,
                    child: Center(
                      child: _isError
                          ? Text('Failed to load image')
                          : CircularProgressIndicator(),
                    ),
                  )
                : SizedBox(
                    width: widget.maxWidth,
                    height: widget.maxHeight,
                    child: _isError
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : Image(
                            image: widget.image,
                            fit: BoxFit.contain,
                          ),
                  ),
          ),
          if (!_isLoading && !_isError && widget.onDelete != null)
            Positioned(
              top: 8.0,
              right: 8.0,
              child: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  widget.onDelete;
                },
              ),
            ),
        ],
      ),
    );
  }
}
