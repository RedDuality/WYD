import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/API/image_api.dart';
import 'package:wyd_front/model/DTO/blob_data.dart';

class BlobProvider with ChangeNotifier {
  final String _containerHash;

  final Map<String, BlobData> _images = {};
  final Map<String, bool> _loadingStates = {};

  final List<BlobData> _newImages = [];
  VoidCallback? onChanged;

  BlobProvider(this._containerHash, startingHashes, {this.onChanged}) {
    for (var hash in startingHashes) {
      _loadingStates[hash] = true; // Initialize all images as loading
    }
  }

  String get containerHash => _containerHash;
  Map<String, BlobData> get images => _images;
  List<BlobData> get newImages => _newImages;
  Map<String, bool> get loadingStates => _loadingStates;

  // Method to add a new image to the _images list
  void addImage(String hash, BlobData image) {
    _images[hash] = image;
    _loadingStates[hash] = false;
  }

  // Method to add a new image to the _newImages list
  void addNewImage(BlobData image) {
    _newImages.add(image);
    onChanged?.call();
    notifyListeners();
  }

  // Method to update images based on a new hash list
  void updateImages(List<String> newHashes) {
    _newImages.clear();
    for (var hash in newHashes) {
      if (!_loadingStates.containsKey(hash)) {
        _loadingStates[hash] = true;
      }
    }

    //deleted images
    _loadingStates.keys.toList().forEach((hash) {
      if (!newHashes.contains(hash)) {
        _loadingStates.remove(hash);
        _images.remove(hash);
      }
    });

    notifyListeners();
  }
}

class BlobEditor extends StatelessWidget {
  const BlobEditor({super.key});

  Future<void> _pickImage(BlobProvider blobProvider) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final Uint8List imageData = await image.readAsBytes();

      // Compress the image data
      if (imageData.isNotEmpty) {
        try {
          // Compress the image data
          final compressedImageData =
              await FlutterImageCompress.compressWithList(
            imageData,
            minWidth: 403,
            quality: 85,
          );

          blobProvider.addNewImage(
              BlobData(data: compressedImageData, mimeType: "image/jpeg"));
        } catch (e) {
          debugPrint(e.toString());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BlobProvider>(
      builder: (context, blobProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text("Immagini"),
                const SizedBox(
                  height: 10,
                  width: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    _pickImage(blobProvider);
                  },
                  child: const Text("Choose Image"),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (blobProvider._newImages.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Nuove"),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8.0, // Space between widgets horizontally
                    runSpacing: 8.0, // Space between widgets vertically
                    children: blobProvider._newImages.map((imageData) {
                      return ImageDisplay(
                          maxWidth: 403,
                          imageData: imageData.data,
                          hasError: false);
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(
                  color: Colors.grey,
                  thickness: 0.5,
                ),
                const SizedBox(height: 10),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final maxWidth = constraints.maxWidth;
                    const minwidth = 403;
                    final divider = (maxWidth / minwidth).floor();
                    final itemWidth = (maxWidth < 200
                                ? maxWidth
                                : maxWidth / (divider == 0 ? 1 : divider))
                            .floor()
                            .toDouble() -
                        6;
                    //debugPrint('$maxWidth $divider $minwidth $itemWidth');
                    return Center(
                      child: Wrap(
                        spacing: 8.0, // Space between widgets horizontally
                        runSpacing: 8.0, // Space between widgets vertically
                        children:
                            blobProvider.loadingStates.entries.map((entry) {
                          return ImageLoader(
                            maxWidth: itemWidth,
                            imageHash: entry.key,
                            loading: entry.value,
                            blobProvider: blobProvider,
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class ImageDisplay extends StatelessWidget {
  final Uint8List imageData;
  final bool hasError;
  final double maxWidth;

  const ImageDisplay({
    required this.maxWidth,
    required this.imageData,
    required this.hasError,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
      ),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(12.0), // Adjust the radius as needed
      ),
      child: hasError
          ? const Icon(Icons.error)
          : ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.memory(
                imageData,
                fit: BoxFit.cover,
              ),
            ),
    );
  }
}

class ImageLoader extends StatelessWidget {
  final String imageHash;
  final bool loading;
  final BlobProvider blobProvider;
  final double maxWidth;

  const ImageLoader({
    required this.maxWidth,
    required this.imageHash,
    required this.loading,
    required this.blobProvider,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return !loading
        ? ImageDisplay(
            maxWidth: maxWidth,
            imageData: blobProvider.images[imageHash]!.data,
            hasError: false,
          )
        : FutureBuilder(
            future:
                ImageApi().retrieveImage(blobProvider.containerHash, imageHash),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: const CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return ImageDisplay(
                  maxWidth: maxWidth,
                  imageData: Uint8List(0), // Empty data for error case
                  hasError: true,
                );
              } else if (snapshot.hasData) {
                final response = snapshot.data as Response;

                if (response.statusCode == 200) {
                  final imageData = BlobData(
                    data: response.bodyBytes,
                    mimeType: lookupMimeType(imageHash)!,
                  );
                  blobProvider.addImage(imageHash, imageData);
                  return ImageDisplay(
                    maxWidth: maxWidth,
                    imageData: blobProvider.images[imageHash]!.data,
                    hasError: false,
                  );
                } else {
                  return ImageDisplay(
                    maxWidth: maxWidth,
                    imageData: Uint8List(0), // Empty data for error case
                    hasError: true,
                  );
                }
              } else {
                return ImageDisplay(
                  maxWidth: maxWidth,
                  imageData: Uint8List(0), // Empty data for error case
                  hasError: true,
                );
              }
            },
          );
  }
}
