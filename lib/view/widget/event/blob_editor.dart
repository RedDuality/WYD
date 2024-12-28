import 'package:flutter/material.dart';
import 'package:wyd_front/service/util/image_service.dart';
import 'package:wyd_front/state/event_detail_provider.dart';
import 'package:wyd_front/view/widget/event/image_display.dart';

class BlobEditor extends StatelessWidget {
  final EventDetailProvider provider;
  const BlobEditor({super.key, required this.provider});

  double _getWidth(double maxWidth, double minWidth, int elementcount) {
    final divider = (maxWidth / minWidth).floor();
    final itemWidth = (maxWidth < minWidth
                ? maxWidth
                : maxWidth /
                    (divider == 0
                        ? 1
                        : (elementcount != 0 && elementcount < divider
                            ? elementcount
                            : divider)))
            .floor()
            .toDouble() -
        8; //compensate for card border
    //debugPrint('$maxWidth $minWidth $itemWidth');
    return itemWidth;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (provider.newImages.isNotEmpty)
          Column(
            children: [
              /*if (!kIsWeb)
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
                  ),*/

              Text('These are the images you took during this event:',
                  style: TextStyle(fontSize: 18)),
              SizedBox(
                height: 8,
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  var itemWidth = _getWidth(
                      constraints.maxWidth, 303, provider.newImages.length);
                  return Center(
                    child: Wrap(
                      children: List.generate(
                        provider.newImages.length,
                        (index) => ImageDisplay(
                          maxWidth: itemWidth,
                          image: ImageService()
                              .getImageFromXFile(provider.newImages[index]),
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(
                height: 8,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        var images = await ImageService().pickImages();
                        if (images.isNotEmpty) {
                          provider.addNewImages(images);
                        }
                      },
                      icon: Icon(Icons.thumb_up_alt),
                      label: Row(
                        children: [
                          if (MediaQuery.of(context).size.width > 200)
                            Text('Approve', style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 8,
              ),
              const Divider(
                color: Colors.grey,
                thickness: 0.5,
              ),
            ],
          ),
        //Old Images
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 8,
            ),
            //uploadImages
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      var images = await ImageService().pickImages();
                      if (images.isNotEmpty) {
                        provider.addNewImages(images);
                      }
                    },
                    icon: Icon(Icons.upload),
                    label: Row(
                      children: [
                        if (MediaQuery.of(context).size.width > 200)
                          Text('Upload New Images',
                              style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            LayoutBuilder(
              builder: (context, constraints) {
                var itemWidth = _getWidth(
                    constraints.maxWidth, 303, provider.imageHashes.length);
                //debugPrint('$maxWidth $divider $itemWidth');
                return Center(
                  child: Wrap(
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

