import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wyd_front/model/DTO/blob_data.dart';
import 'package:wyd_front/service/util/image_service.dart';
import 'package:wyd_front/state/event_detail_provider.dart';

class BlobEditor extends StatelessWidget {
  final EventDetailProvider provider;
  const BlobEditor({super.key, required this.provider});

  Future<void> _pickImage(EventDetailProvider provider) async {
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

          provider.addNewImage(
              BlobData(data: compressedImageData, mimeType: "image/jpeg"));
        } catch (e) {
          debugPrint(e.toString());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                _pickImage(provider);
              },
              child: const Text("Choose Image"),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (provider.newImages.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Nuove"),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8.0, // Space between widgets horizontally
                runSpacing: 8.0, // Space between widgets vertically
                children: provider.newImages.map((imageData) {
                  return ImageDisplay(
                    image: Image.memory(imageData.data),
                  );
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
                    children: provider.imageHashes.map((imageHash) {
                      return ImageDisplay(
                        maxWidth: itemWidth,
                        image: ImageService()
                            .getEventImage(provider.hash!, imageHash),
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
  }
}

class ImageDisplay extends StatelessWidget {
  final double? maxWidth;
  final Image image;

  const ImageDisplay({
    super.key,
    this.maxWidth,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? double.infinity,
      ),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(12.0), // Adjust the radius as needed
      ),
      child: image,
    );
  }
}
