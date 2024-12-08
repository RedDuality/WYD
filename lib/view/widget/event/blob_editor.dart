import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/API/event_api.dart';
import 'package:wyd_front/API/image_api.dart';
import 'package:wyd_front/model/DTO/blob_data.dart';

class BlobProvider with ChangeNotifier {
  final String _containerHash;
  final List<String> _startingHashes;

  final List<BlobData> _images = [];
  final List<BlobData> _newImages = [];
  final Map<String, bool> _loadingStates = {};
  VoidCallback? onChanged;

  BlobProvider(this._containerHash, this._startingHashes, {this.onChanged}) {
    for (var hash in _startingHashes) {
      _loadingStates[hash] = true; // Initialize all images as loading
    }
  }

  String get containerHash => _containerHash;
  List<String> get startingHashes => _startingHashes;
  List<BlobData> get images => _images;
  List<BlobData> get newImages => _newImages;
  Map<String, bool> get loadingStates => _loadingStates;

  // Method to add a new image to the _images list
  void addImage(String hash, BlobData image) {
    _images.add(image);
    _loadingStates[hash] = false; // Mark image as loaded
    //notifyListeners();
  }

  // Method to add a new image to the _newImages list
  void addNewImage(BlobData image) {
    _newImages.add(image);
    onChanged?.call();
    notifyListeners();
  }
}

class BlobEditor extends StatelessWidget {
  const BlobEditor({super.key});

  Future<void> _pickImage(BlobProvider blobProvider) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      String? mimeType = lookupMimeType(image.name);
      if (mimeType != null) {
        final Uint8List imageData = await image.readAsBytes();

        // Compress the image data
        final Uint8List compressedImageData =
            await FlutterImageCompress.compressWithList(
          imageData,
          minWidth: 800,
          minHeight: 800,
          quality: 85,
        );

        blobProvider.addNewImage(
            BlobData(data: compressedImageData, mimeType: mimeType));
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
                if (blobProvider.newImages.isNotEmpty)
                  ElevatedButton(
                    onPressed: () {
                      EventAPI().addPhoto(2, blobProvider.newImages[0]);
                    },
                    child: const Text("Save Image"),
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
                          imageData: imageData.data, hasError: false);
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Vecchie"),
                const SizedBox(height: 10),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final maxWidth = constraints.maxWidth;
                    const minwidth = 403;
                    final divider = (maxWidth / minwidth).floor();
                    final itemWidth = maxWidth < 200
                        ? maxWidth
                        : maxWidth / (divider == 0 ? 1 : divider);
                    //debugPrint('$maxWidth $divider $minwidth $itemWidth');
                    return Center(
                      child: Wrap(
                        spacing: 8.0, // Space between widgets horizontally
                        runSpacing: 8.0, // Space between widgets vertically
                        children: blobProvider.startingHashes.map((hash) {
                          return SizedBox(
                            width: itemWidth.floor().toDouble() - 6,
                            child: ImageLoader(
                              imageHash: hash,
                              blobProvider: blobProvider,
                            ),
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

  const ImageDisplay({
    required this.imageData,
    required this.hasError,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500, minWidth: 200),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: hasError ? const Icon(Icons.error) : Image.memory(imageData),
      ),
    );
  }
}

class ImageLoader extends StatelessWidget {
  final String imageHash;
  final BlobProvider blobProvider;

  const ImageLoader({
    required this.imageHash,
    required this.blobProvider,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ImageApi().retrieveImage(blobProvider.containerHash, imageHash),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            constraints: const BoxConstraints(maxWidth: 500, minWidth: 200),
            child: const CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return ImageDisplay(
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
              imageData: imageData.data,
              hasError: false,
            );
          } else {
            return ImageDisplay(
              imageData: Uint8List(0), // Empty data for error case
              hasError: true,
            );
          }
        } else {
          return ImageDisplay(
            imageData: Uint8List(0), // Empty data for error case
            hasError: true,
          );
        }
      },
    );
  }
}
