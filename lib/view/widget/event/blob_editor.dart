import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wyd_front/model/DTO/blob_data.dart';
import 'package:wyd_front/service/util/image_service.dart';
import 'package:wyd_front/state/event_detail_provider.dart';

class BlobEditor extends StatelessWidget {
  final EventDetailProvider provider;
  const BlobEditor({super.key, required this.provider});

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
              onPressed: () async {
                var images = await ImageService().pickImages();
                if (images.isNotEmpty) {
                  provider.addNewImages(images);
                }
              },
              child: const Text("Choose Image"),
            ),
            if (!kIsWeb)
              ElevatedButton(
                onPressed: () async {
                  List<BlobData> newImages = await ImageService()
                      .retrieveImages(
                          DateTime.now().subtract(Duration(days: 1)),
                          DateTime.now());
                  if (newImages.isNotEmpty) {
                    provider.addNewImages(newImages);
                  }
                },
                child: const Text("Upload Images"),
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
                const minwidth = 203;
                final divider = (maxWidth / minwidth).floor();
                final itemWidth = (maxWidth < minwidth
                            ? maxWidth
                            : maxWidth / (divider == 0 ? 1 : divider))
                        .floor()
                        .toDouble() -
                    6; //compensate for spacing
                //debugPrint('$maxWidth $divider $itemWidth');
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
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(12.0), // Adjust the radius as needed
        child: image,
      ),
    );
  }
}
