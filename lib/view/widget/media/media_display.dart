import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:wyd_front/model/media/media.dart';

enum MediaSize { mini, big }

class MediaDisplay extends StatelessWidget {
  final AssetEntity? assetEntity;
  final String? parentHash;
  final Media? media;
  final MediaSize? size;
  final BoxFit? fit;
  final VoidCallback? onLoadingFinished;
  final VoidCallback? onError;

  // Private default constructor to prevent direct instantiation
  const MediaDisplay._({
    super.key,
    this.assetEntity,
    this.parentHash,
    this.media,
    this.size,
    this.fit,
    this.onLoadingFinished,
    this.onError,
  });

  // Constructor for a local asset entity
  factory MediaDisplay.fromAsset({
    Key? key,
    required AssetEntity assetEntity,
    MediaSize? size,
    BoxFit? fit,
    VoidCallback? onLoadingFinished,
    VoidCallback? onError,
  }) {
    return MediaDisplay._(
      key: key,
      assetEntity: assetEntity,
      size: size,
      fit: fit,
      onLoadingFinished: onLoadingFinished,
      onError: onError,
    );
  }

  // Constructor for a remote media object
  factory MediaDisplay.fromMedia({
    Key? key,
    required String parentHash,
    required Media media,
    MediaSize? size,
    BoxFit? fit,
    VoidCallback? onLoadingFinished,
    VoidCallback? onError,
  }) {
    return MediaDisplay._(
      key: key,
      parentHash: parentHash,
      media: media,
      size: size,
      fit: fit,
      onLoadingFinished: onLoadingFinished,
      onError: onError,
    );
  }

  Image imageFromAssetEntity() {
    /*
    if (kIsWeb) {
      return Image(image: wydLogo());
    }*/
    return Image(
      image: AssetEntityImageProvider(assetEntity!),
      fit: fit ?? BoxFit.cover,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (frame == null) {
          // Loading state
          return const Center(child: CircularProgressIndicator());
        }
        if (onLoadingFinished != null) {
          onLoadingFinished!();
        }
        return child;
      },
      errorBuilder: (context, error, stackTrace) {
        if (onError != null) {
          onError!();
        }
        return const Center(child: Text('Failed to load local asset'));
      },
    );
  }

  CachedNetworkImage imageFromNetwork() {
    return CachedNetworkImage(
      imageUrl: media!.url!,
      fit: fit ?? BoxFit.cover,
      placeholder: (context, url) {
        return const Center(child: CircularProgressIndicator());
      },
      imageBuilder: (context, imageProvider) {
        if (onLoadingFinished != null) {
          onLoadingFinished!();
        }
        return Image(
          image: imageProvider,
          fit: fit ?? BoxFit.cover,
        );
      },
      errorWidget: (context, url, error) {
        if (onError != null) {
          onError!();
        }
        return _failureMessage('Failed to load image');
      },
    );
  }

  Widget _failureMessage(String message) {
    if (size == MediaSize.mini) {
      return Image(image: wydLogo());
    }
    return Center(child: Text(message));
  }

  ImageProvider wydLogo() {
    String path;
    switch (size) {
      case MediaSize.mini:
        path = 'assets/images/logoimage_mini.png';
        break;
      case MediaSize.big:
      default:
        path = 'assets/images/logoimage.png';
        break;
    }
    return AssetImage(path);
  }

  @override
  Widget build(BuildContext context) {
    if (media == null && assetEntity == null) {
      return _failureMessage('No media to display');
    }

    if (assetEntity != null) {
      return imageFromAssetEntity();
    }

    if (media != null) {
      if (media!.error != null) {
        if (onError != null) {
          onError?.call();
        }
        return Center(child: Text(media!.error!));
      }

      switch (media!.extension) {
        //case '.mp4':
        //case '.pdf':
        case '.jpg':
        case '.png':
        case '.gif':
          return imageFromNetwork();
        default:
          return _failureMessage('Unsupported file type');
      }
    }

    return _failureMessage('There was an error while retrieving the media');
  }
}
