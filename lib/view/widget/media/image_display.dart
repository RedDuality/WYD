import 'package:flutter/material.dart';

enum ImageState {
  loading,
  loaded,
  error,
}

class ImageDisplay extends StatefulWidget {
  final ImageProvider? image;
  final BoxFit? fit;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final VoidCallback? onLoadingFinished;
  final VoidCallback? onError;

  const ImageDisplay({
    super.key,
    required this.image,
    this.fit,
    this.loadingWidget,
    this.errorWidget,
    this.onLoadingFinished,
    this.onError,
  });

  @override
  ImageDisplayState createState() => ImageDisplayState();
}

class ImageDisplayState extends State<ImageDisplay> {
  ImageState _imageState = ImageState.loading;

  @override
  void initState() {
    super.initState();

    _resolveImage();
  }

  @override
  void didUpdateWidget(covariant ImageDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.image != oldWidget.image) {
      _resolveImage();
    }
  }

  void _resolveImage() {
    if (widget.image != null) {
      final ImageStream stream = widget.image!.resolve(const ImageConfiguration());
      final listener = ImageStreamListener(
        (ImageInfo image, bool synchronousCall) {
          if (mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _imageState = ImageState.loaded;
              });
              widget.onLoadingFinished?.call();
            });
          }
        },
        onError: (Object error, StackTrace? stackTrace) {
          if (mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _imageState = ImageState.error;
              });
              widget.onError?.call();
            });
          }
        },
      );
      stream.addListener(listener);
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_imageState) {
      case ImageState.loading:
        return widget.loadingWidget ??
            const Center(
              child: CircularProgressIndicator(),
            );
      case ImageState.loaded:
        return Image(
          image: widget.image!,
          fit: widget.fit,
        );
      case ImageState.error:
        return widget.errorWidget ??
            const Center(
              child: Text('Failed to load image'),
            );
    }
  }
}
