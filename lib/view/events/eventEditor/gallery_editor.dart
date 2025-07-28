import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/service/model/event_service.dart';
import 'package:wyd_front/service/util/image_service.dart';
import 'package:wyd_front/service/util/photo_retriever_service.dart';
import 'package:wyd_front/state/eventEditor/blob_provider.dart';
import 'package:wyd_front/view/widget/image_display.dart';

class GalleryEditor extends StatefulWidget {
  const GalleryEditor({super.key});

  @override
  State<GalleryEditor> createState() => _GalleryEditorState();
}

class _GalleryEditorState extends State<GalleryEditor> {
  bool ciao = false;

  double _getWidth(double maxWidth, double minWidth, int elementcount) {
    final divider = (maxWidth / minWidth).floor();
    final itemWidth = (maxWidth < minWidth
                ? maxWidth
                : maxWidth /
                    (divider == 0
                        ? 1
                        : (elementcount != 0 && elementcount < divider ? elementcount : divider)))
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
          : Builder(builder: (context) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (imageProvider.exists())
                    const Divider(
                      color: Colors.grey,
                      thickness: 0.5,
                      height: 20,
                    ),
                  //if (!kIsWeb)
                  if (!ciao)
                    Column(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  /*
                                PhotoRetrieverService.retrieveShootedPhotos(
                                    imageProvider.eventHash);*/
                                  var images = await ImageService.pickImageReferencesForWeb();
                                  imageProvider.setCachedFiles(images);
                                  ciao = true;
                                },
                                child: Row(
                                  children: [
                                    Icon(Icons.search),
                                    //TODO: show only if after the event
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
                        SizedBox(height: 10),
                      ],
                    ),

                  if (imageProvider.cachedImages.isNotEmpty ||
                      imageProvider.cacheHashBeenModified ||
                      imageProvider.cachedFiles.isNotEmpty)
                    Builder(builder: (context) {
                      return Column(
                        children: [
                          Text('Immagini scattate durante questo evento:',
                              style: TextStyle(fontSize: 18)),
                          SizedBox(height: 10),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              var itemWidth = _getWidth(
                                  constraints.maxWidth, 303, imageProvider.cachedImages.length);
                              return Center(
                                child: Wrap(children: [
                                  ...List.generate(imageProvider.cachedImages.length, (index) {
                                    var image = imageProvider.cachedImages[index];

                                    return ImageDisplay(
                                      maxWidth: itemWidth,
                                      image: ImageService.getImageFromAssetEntity(image),
                                      onDelete: () => imageProvider.removeCachedImage(image),
                                    );
                                  }),
                                  ...List.generate(imageProvider.cachedFiles.length, (index) {
                                    var xFile = imageProvider.cachedFiles[index];

                                    // You'll need a way to get an ImageProvider from an XFile.
                                    // This is typically done by reading its bytes.
                                    // Since `ImageDisplay` expects an ImageProvider, we'll use `MemoryImage`.
                                    // Note: This reads the bytes *immediately* for display.
                                    // If you want true lazy loading, you might need a custom ImageDisplay.
                                    return FutureBuilder<Uint8List>(
                                      future: xFile.readAsBytes(), // Read bytes from XFile
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.done &&
                                            snapshot.hasData) {
                                          return ImageDisplay(
                                            maxWidth: itemWidth,
                                            image: MemoryImage(
                                                snapshot.data!), // Use MemoryImage for bytes
                                            onDelete: () => imageProvider
                                                .removeCachedFile(xFile), // You'll need this method
                                          );
                                        } else if (snapshot.hasError) {
                                          return Text('Error loading image: ${snapshot.error}');
                                        }
                                        // While loading, show a placeholder or loading indicator
                                        return SizedBox(
                                          width: itemWidth,
                                          height: itemWidth, // Assuming square, adjust as needed
                                          child: Center(child: CircularProgressIndicator()),
                                        );
                                      },
                                    );
                                  }),
                                ]),
                              );
                            },
                          ),
                          SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    var realImages = await ImageService.dataFromAssetEntities(
                                        imageProvider.cachedImages);

                                    realImages.isEmpty
                                        ? EventService.clearCachedImages(imageProvider.eventHash)
                                        : await EventService.uploadCachedImages(
                                            imageProvider.eventHash, realImages);
                                  },
                                  child: Row(
                                    children: [
                                      Icon(Icons.thumb_up_alt),
                                      MediaQuery.of(context).size.width > 200
                                          ? Text('Conferma', style: TextStyle(fontSize: 18))
                                          : Container(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(
                            color: Colors.grey,
                            thickness: 0.5,
                            height: 20,
                          ),
                        ],
                      );
                    }),
                  //Already saved images
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //uploadImages
                      Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                //var images = await ImageService.pickImages();
                                var images = await ImageService.pickImageReferencesForWeb();
                                if (images.isNotEmpty) {
                                  imageProvider.addUploadedFiles(images);
                                  //await EventService.uploadImages(imageProvider.eventHash, images);
                                }
                              },
                              icon: Icon(Icons.upload),
                              label: Row(
                                children: [
                                  if (MediaQuery.of(context).size.width > 200)
                                    Text('Upload New Images', style: TextStyle(fontSize: 18)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      //loadImages
                      LayoutBuilder(
                        builder: (context, constraints) {
                          var itemWidth = _getWidth(
                              constraints.maxWidth, 303, imageProvider.imageHashes.length);
                          //debugPrint('$maxWidth $divider $itemWidth');
                          return Center(
                            child: Wrap(children: [
                              ...imageProvider.imageHashes.map((imageHash) {
                                return ImageDisplay(
                                  maxWidth: itemWidth,
                                  image: ImageService.getEventImage(
                                      imageProvider.eventHash, imageHash),
                                );
                              }),
                              ...List.generate(imageProvider.uploadedFiles.length, (index) {
                                var xFile = imageProvider.uploadedFiles[index];

                                // You'll need a way to get an ImageProvider from an XFile.
                                // This is typically done by reading its bytes.
                                // Since `ImageDisplay` expects an ImageProvider, we'll use `MemoryImage`.
                                // Note: This reads the bytes *immediately* for display.
                                // If you want true lazy loading, you might need a custom ImageDisplay.
                                return FutureBuilder<Uint8List>(
                                  future: xFile.readAsBytes(), // Read bytes from XFile
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.done &&
                                        snapshot.hasData) {
                                      return ImageDisplay(
                                        maxWidth: itemWidth,
                                        image: MemoryImage(
                                            snapshot.data!), // Use MemoryImage for bytes
                                        onDelete: () => imageProvider
                                            .removeCachedFile(xFile), // You'll need this method
                                      );
                                    } else if (snapshot.hasError) {
                                      return Text('Error loading image: ${snapshot.error}');
                                    }
                                    // While loading, show a placeholder or loading indicator
                                    return SizedBox(
                                      width: itemWidth,
                                      height: itemWidth, // Assuming square, adjust as needed
                                      child: Center(child: CircularProgressIndicator()),
                                    );
                                  },
                                );
                              }),
                            ]),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              );
            });
    });
  }
}
