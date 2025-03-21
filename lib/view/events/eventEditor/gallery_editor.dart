import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/service/model/event_service.dart';
import 'package:wyd_front/service/util/image_service.dart';
import 'package:wyd_front/service/util/photo_retriever_service.dart';
import 'package:wyd_front/state/eventEditor/blob_provider.dart';
import 'package:wyd_front/state/event_provider.dart';
import 'package:wyd_front/view/widget/image_display.dart';

class GalleryEditor extends StatelessWidget {
  const GalleryEditor({super.key});

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
                if (!kIsWeb)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            PhotoRetrieverService()
                                .retrieveShootedPhotos(imageProvider.hash);
                          },
                          child: Row(
                            children: [
                              Icon(Icons.search),
                              MediaQuery.of(context).size.width > 200
                                  ? const Text("(Test) Cerca foto scattate",
                                      style: TextStyle(fontSize: 18))
                                  : Container(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                if (imageProvider.cachedImages.isNotEmpty ||
                    imageProvider.cacheHashBeenModified)
                  Column(
                    children: [
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
                                      imageProvider.removeCachedImage(
                                          hash: imageProvider.hash, image),
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
                            ElevatedButton(
                              onPressed: () async {
                                var cachedImages = await ImageService()
                                    .dataFromAssetEntities(
                                        imageProvider.cachedImages);
                                var event = EventProvider()
                                    .retrieveEventByHash(imageProvider.hash);
                                cachedImages.isNotEmpty
                                    ? await EventService()
                                        .uploadCachedImages(event, cachedImages)
                                    : EventService().clearCachedImages(event);
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.thumb_up_alt),
                                  MediaQuery.of(context).size.width > 200
                                      ? Text('Confirm',
                                          style: TextStyle(fontSize: 18))
                                      : Container(),
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
                                var event = EventProvider()
                                    .retrieveEventByHash(imageProvider.hash);
                                await EventService()
                                    .uploadImages(event, images);
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
                                    imageProvider.hash, imageHash),
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
