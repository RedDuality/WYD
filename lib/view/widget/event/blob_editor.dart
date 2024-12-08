import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/API/image_api.dart';
import 'package:wyd_front/model/DTO/blob_data.dart';

class BlobProvider with ChangeNotifier {
  final String _containerHash;
  final List<String> _startingHashes;

  final List<BlobData> _images = [];
  final List<BlobData> _newImages = [];
  VoidCallback? onChanged;

  BlobProvider(this._containerHash, this._startingHashes, {this.onChanged});

  // Getters for the private fields
  String get containerHash => _containerHash;
  List<String> get startingHashes => _startingHashes;
  List<BlobData> get images => _images;
  List<BlobData> get newImages => _newImages;

  // Method to add a new image to the _images list
  void addImage(BlobData image) {
    _images.add(image);
    notifyListeners();
    onChanged?.call();
  }

  // Method to add a new image to the _newImages list
  void addNewImage(BlobData image) {
    _newImages.add(image);
    notifyListeners();
    onChanged?.call();
  }
}

class BlobEditor extends StatelessWidget {
  const BlobEditor({super.key});

  Future<void> _getImages(BlobProvider blobProvider) async {
    for (String imageName in blobProvider.startingHashes) {
      final response = await ImageApi()
          .retrieveImage(blobProvider.containerHash, imageName);

      if (response.statusCode == 200) {
        blobProvider.addNewImage(BlobData(
            data: response.bodyBytes, mimeType: lookupMimeType(imageName)!));
      } else {
        debugPrint('Failed to load image: $imageName');
      }
    }
  }

  Future<void> _pickImage(BlobProvider blobProvider) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      String? mimeType = lookupMimeType(image.name);
      if (mimeType != null) {
        final Uint8List imageData = await image.readAsBytes();
        blobProvider.addNewImage(BlobData(data: imageData, mimeType: mimeType));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BlobProvider>(
      builder: (context, blobProvider, child) {
        if (blobProvider.startingHashes.isNotEmpty) {
          _getImages(blobProvider);
        }
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
                      return Container(
                        constraints: const BoxConstraints(maxWidth: 200),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: Image.memory(imageData.data),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            if (blobProvider._startingHashes.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Vecchie"),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8.0, // Space between widgets horizontally
                    runSpacing: 8.0, // Space between widgets vertically
                    children: blobProvider._images.map((imageData) {
                      return Container(
                        constraints: const BoxConstraints(maxWidth: 200),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.memory(imageData.data),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }
}
