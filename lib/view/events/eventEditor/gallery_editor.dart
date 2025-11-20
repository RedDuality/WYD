import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/model/event_details.dart';
import 'package:wyd_front/service/event/event_details_service.dart';
import 'package:wyd_front/service/media/media_retrieve_service.dart';
import 'package:wyd_front/service/media/media_service.dart';
import 'package:wyd_front/service/media/media_selection_service.dart';
import 'package:wyd_front/service/media/media_upload_service.dart';
import 'package:wyd_front/state/event/current_events_provider.dart';
import 'package:wyd_front/state/event/event_details_storage.dart';
import 'package:wyd_front/state/media/cached_media_provider.dart';
import 'package:wyd_front/view/widget/media/card_display.dart';
import 'package:wyd_front/view/widget/media/media_display.dart';

class GalleryEditor extends StatelessWidget {
  final String eventHash;
  const GalleryEditor({super.key, required this.eventHash});

  double _getWidth(double maxWidth, double minWidth, int elementcount) {
    final divider = (maxWidth / minWidth).floor();
    final itemWidth = (maxWidth < minWidth
                ? maxWidth
                : maxWidth /
                    (divider == 0 ? 1 : (elementcount != 0 && elementcount < divider ? elementcount : divider)))
            .floor()
            .toDouble() -
        8; //compensate for card border
    //debugPrint('$maxWidth $minWidth $itemWidth');
    return itemWidth;
  }

  @override
  Widget build(BuildContext context) {
    var hasEventFinished =
        Provider.of<CurrentEventsProvider>(context).get(eventHash)!.startTime!.isAfter(DateTime.now());
    return ChangeNotifierProvider(
      create: (_) => CachedMediaProvider(eventHash),
      child: Builder(
        builder: (context) {
          var eventDetails = EventDetailsProvider().get(eventHash);
          if (eventDetails != null &&
              eventDetails.totalImages > 0 &&
              eventDetails.media.isNotEmpty &&
              (eventDetails.validUntil == null || eventDetails.validUntil!.isBefore(DateTime.now()))) {
            EventDetailsProvider().invalidateMediaCache(eventHash);
          }

          EventDetailsService.retrieveMedia(eventHash);

          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Divider(
              color: Colors.grey,
              thickness: 0.5,
              height: 20,
            ),
            //On Devices, look for images
            if (!kIsWeb && hasEventFinished)
              Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /*
                        ElevatedButton(
                          onPressed: () async {
                            final provider = Provider.of<CachedMediaProvider>(context, listen: false);
                            await MediaRetrieveService.mockRetrieveShootedPhotos(eventHash, provider);
                          },
                          child: Row(
                            children: [
                              Icon(Icons.search),
                              MediaQuery.of(context).size.width > 200
                                  ? const Text("(Test) Cerca foto scattate", style: TextStyle(fontSize: 18))
                                  : Container(),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        */
                        ElevatedButton(
                          onPressed: () async {
                            MediaRetrieveService.retrieveShootedPhotos(eventHash);
                          },
                          child: Row(
                            children: [
                              Icon(Icons.search),
                              MediaQuery.of(context).size.width > 200
                                  ? const Text("Cerca foto scattate", style: TextStyle(fontSize: 18))
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

            Consumer<CachedMediaProvider>(builder: (context, mediaProvider, child) {
              final mediaMap = mediaProvider.get();
              return mediaMap != null && mediaMap.isNotEmpty
                  ? Column(
                      children: [
                        Text('These are the images you took during this event:', style: TextStyle(fontSize: 18)),
                        SizedBox(height: 10),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            var itemWidth = _getWidth(constraints.maxWidth, 303, mediaMap.length);
                            final cachedImagesList = mediaMap.entries.toList();
                            return Center(
                              child: Wrap(
                                children: List.generate(
                                  cachedImagesList.length,
                                  (index) {
                                    final entry = cachedImagesList[index];
                                    final image = entry.key;
                                    final isSelected = entry.value;

                                    return CardDisplay(
                                      maxWidth: itemWidth,
                                      isSelected: isSelected,
                                      onSelected: () {
                                        mediaProvider.select(eventHash, image);
                                      },
                                      onUnSelected: () {
                                        mediaProvider.unselect(eventHash, image);
                                      },
                                      mediaBuilder: ({onLoadingFinished, onError}) {
                                        return MediaDisplay.fromAsset(
                                          assetEntity: image,
                                          fit: BoxFit.cover,
                                          onLoadingFinished: onLoadingFinished,
                                          onError: onError,
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
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
                                  final selectedAssets = mediaMap.entries
                                      .where((entry) => entry.value == true)
                                      .map((entry) => entry.key)
                                      .toList();

                                  if (selectedAssets.isNotEmpty) {
                                    var cachedImages = await MediaSelectionService.dataFromCache(selectedAssets);
                                    await MediaUploadService().uploadImages(eventHash, cachedImages);
                                    // wait for upload to be successful
                                    mediaProvider.removeAll(eventHash);
                                  } else {
                                    mediaProvider.removeAll(eventHash);
                                  }
                                },
                                child: Row(
                                  children: [
                                    Icon(Icons.upload),
                                    MediaQuery.of(context).size.width > 200
                                        ? Text('Confirm and upload', style: TextStyle(fontSize: 18))
                                        : Container(),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () async {
                                  mediaProvider.removeAll(eventHash);
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    MediaQuery.of(context).size.width > 200
                                        ? Text('Remove All', style: TextStyle(color: Colors.red, fontSize: 18))
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
                    )
                  : Container();
            }),

            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      var images = await MediaSelectionService.selectMedia();
                      if (images.isNotEmpty) {
                        await MediaService.uploadImages(eventHash, images);
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

            //Already saved images
            Consumer<EventDetailsProvider>(
              builder: (context, eventProvider, child) {
                final eventDetails = context.select<EventDetailsProvider, EventDetails?>(
                  (provider) => provider.get(eventHash),
                );
                if (eventDetails != null && eventDetails.totalImages > 0 && eventDetails.media.isEmpty) {
                  EventDetailsService.retrieveMedia(eventHash);
                }
                return eventDetails == null
                    ? Container()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LayoutBuilder(builder: (context, constraints) {
                            var media = eventDetails.media;
                            var itemWidth = _getWidth(constraints.maxWidth, 303, media.length);
                            //debugPrint('$maxWidth $divider $itemWidth');
                            return Center(
                              child: Wrap(
                                children: media.map((m) {
                                  return CardDisplay(
                                    maxWidth: itemWidth,
                                    mediaBuilder: ({onLoadingFinished, onError}) {
                                      return MediaDisplay.fromMedia(
                                        parentHash: eventHash,
                                        media: m,
                                        fit: BoxFit.cover,
                                        onLoadingFinished: onLoadingFinished,
                                        onError: onError,
                                      );
                                    },
                                  );
                                }).toList(),
                              ),
                            );
                          })
                        ],
                      );
              },
            ),
          ]);
        },
      ),
    );
  }
}
