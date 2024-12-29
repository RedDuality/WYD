import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/service/model/event_service.dart';
import 'package:wyd_front/service/util/image_service.dart';
import 'package:wyd_front/state/blob_provider.dart';
import 'package:wyd_front/view/widget/event/image_display.dart';

class ImageDetail extends StatelessWidget {
  const ImageDetail({super.key});

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
    return Consumer<BlobProvider>(builder: (context, imageProvider, child) {
      return !imageProvider.exists()
          ? Container()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageProvider.exists())
                  const Divider(
                    color: Colors.grey,
                    thickness: 0.5,
                  ),
                if (imageProvider.cachedImages.isNotEmpty)
                  Column(
                    children: [
                      if (!kIsWeb)
                        ElevatedButton(
                          onPressed: () async {
                            List<AssetEntity> newImages = await ImageService()
                                .retrieveImagesByTime(
                                    DateTime.now().subtract(Duration(days: 1)),
                                    DateTime.now());
                            if (newImages.isNotEmpty) {
                              imageProvider.cachedImages.addAll(newImages);
                            }
                          },
                          child: const Text("Trigger Test Upload Images"),
                        ),
                      Text('These are the images you took during this event:',
                          style: TextStyle(fontSize: 18)),
                      SizedBox(
                        height: 8,
                      ),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          var itemWidth = _getWidth(constraints.maxWidth, 303,
                              imageProvider.cachedImages.length);
                          return Center(
                            child: Wrap(
                              children: List.generate(
                                  imageProvider.cachedImages.length, (index) {
                                var image = imageProvider.cachedImages[index];

                                return ImageDisplay(
                                  maxWidth: itemWidth,
                                  image: ImageService()
                                      .getImageFromAssetEntity(image),
                                  onDelete: () =>
                                      imageProvider.removeNewImage(image),
                                );
                              }),
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
                                var cachedImages = await ImageService()
                                    .dataFromAssetEntities(
                                        imageProvider.cachedImages);
                                await EventService().uploadImages(
                                    imageProvider.hash!, cachedImages);
                                //EventProvider's event's CachedImages are already cleared by the EventProvider.updateEvent
                                imageProvider.clearNewImages();
                              },
                              icon: Icon(Icons.thumb_up_alt),
                              label: Row(
                                children: [
                                  if (MediaQuery.of(context).size.width > 200)
                                    Text('Approve',
                                        style: TextStyle(fontSize: 18)),
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
                                EventService()
                                    .uploadImages(imageProvider.hash!, images);
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
                        var itemWidth = _getWidth(constraints.maxWidth, 303,
                            imageProvider.imageHashes.length);
                        //debugPrint('$maxWidth $divider $itemWidth');
                        return Center(
                          child: Wrap(
                            children:
                                imageProvider.imageHashes.map((imageHash) {
                              return ImageDisplay(
                                maxWidth: itemWidth,
                                image: ImageService().getEventImage(
                                    imageProvider.hash!, imageHash),
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
    });
  }
}
