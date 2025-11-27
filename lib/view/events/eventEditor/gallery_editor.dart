import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/model/events/event_details.dart';
import 'package:wyd_front/service/event/event_details_service.dart';
import 'package:wyd_front/service/media/media_retrieve_service.dart';
import 'package:wyd_front/service/media/media_service.dart';
import 'package:wyd_front/service/media/media_selection_service.dart';
import 'package:wyd_front/service/media/media_upload_service.dart';
import 'package:wyd_front/state/event/events_cache.dart';
import 'package:wyd_front/state/event/event_details_storage.dart';
import 'package:wyd_front/state/media/cached_media_cache.dart';
import 'package:wyd_front/state/media/cached_media_storage.dart';
import 'package:wyd_front/state/profileEvent/profile_events_cache.dart';
import 'package:wyd_front/view/widget/media/card_display.dart';
import 'package:wyd_front/view/widget/media/media_display.dart';

class GalleryEditor extends StatelessWidget {
  final String eventId;

  const GalleryEditor({super.key, required this.eventId});

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
    final eventsCache = Provider.of<EventsCache>(context, listen: false);
    final profileEventCache = Provider.of<ProfileEventsCache>(context, listen: false);

    final hasEventFinished = eventsCache.get(eventId)!.hasEventFinished();
    final atLeastOneConfirmed = profileEventCache.atLeastOneConfirmed(eventId);

    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
      child: ChangeNotifierProvider(
        create: (_) => CachedMediaCache(eventId),
        child: Builder(
          builder: (context) {
            var eventDetails = EventDetailsStorage().get(eventId);
            if (eventDetails != null &&
                eventDetails.totalImages > 0 &&
                eventDetails.media.isNotEmpty &&
                (eventDetails.validUntil == null || eventDetails.validUntil!.isBefore(DateTime.now()))) {
              EventDetailsStorage().invalidateMediaCache(eventId);
            }

            EventDetailsService.retrieveMediaFromServer(eventId);

            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _greyDivider(),
              //On Devices, look for images
              if (!kIsWeb && hasEventFinished && atLeastOneConfirmed) _autoRetrieveButton(context),

              _imageSelection(),
              _uploadRelatedFilesButton(context),
              _alreadySavedImages(),
            ]);
          },
        ),
      ),
    );
  }

  Widget _autoRetrieveButton(BuildContext context) {
    return Column(
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
                      await MediaRetrieveService.mockRetrieveShootedPhotos(eventId, provider);
                    },
                    child: Row(
                      children: [
                        Icon(Icons.search),
                        MediaQuery.of(context).size.width > 200
                            ? const Text("(Test) Cerca foto scattate", style: TextStyle(fontSize: 18))
                            : Container(),
                      ],
                    ),
                  ),*/
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () async {
                  final event = Provider.of<EventsCache>(context, listen: false).get(eventId);
                  if (event != null) MediaRetrieveService.retrieveShootedPhotos(event);
                },
                child: Row(
                  children: [
                    Icon(Icons.search),
                    MediaQuery.of(context).size.width > 200
                        ? const Text("Ritrova foto scattate", style: TextStyle(fontSize: 18))
                        : Container(),
                  ],
                ),
              ),
            ],
          ),
        ),
        _greyDivider(),
      ],
    );
  }

  Widget _imageSelection() {
    return Consumer<CachedMediaCache>(builder: (context, mediaProvider, child) {
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
                                CachedMediaStorage().updateSelection(eventId, image, true);
                              },
                              onUnSelected: () {
                                CachedMediaStorage().updateSelection(eventId, image, false);
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
                _selectionButtons(
                  mediaProvider,
                  mediaMap,
                  context,
                ),
                _greyDivider(),
              ],
            )
          : Container();
    });
  }

  Widget _selectionButtons(CachedMediaCache mediaProvider, Map<AssetEntity, bool> mediaMap, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                final selectedAssets =
                    mediaMap.entries.where((entry) => entry.value == true).map((entry) => entry.key).toList();

                if (selectedAssets.isNotEmpty) {
                  var cachedImages = await MediaSelectionService.dataFromCache(selectedAssets);
                  await MediaUploadService().uploadImages(eventId, cachedImages);
                }
                CachedMediaStorage().removeAllMedia(eventId);
              },
              icon: const Icon(Icons.upload),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (MediaQuery.of(context).size.width > 200)
                    const Text('Confirm and upload', style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                CachedMediaStorage().removeAllMedia(eventId);
              },
              icon: const Icon(Icons.delete, color: Colors.red),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (MediaQuery.of(context).size.width > 200)
                    const Text('Ignore All', style: TextStyle(color: Colors.red, fontSize: 18)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _uploadRelatedFilesButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            onPressed: () async {
              var images = await MediaSelectionService.selectMedia();
              if (images.isNotEmpty) {
                await MediaService.uploadImages(eventId, images);
              }
            },
            icon: Icon(Icons.upload),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (MediaQuery.of(context).size.width > 200) Text('Upload files', style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _alreadySavedImages() {
    return Consumer<EventDetailsStorage>(
      builder: (context, eventProvider, child) {
        final eventDetails = context.select<EventDetailsStorage, EventDetails?>(
          (provider) => provider.get(eventId),
        );
        if (eventDetails != null && eventDetails.totalImages > 0 && eventDetails.media.isEmpty) {
          EventDetailsService.retrieveMediaFromServer(eventId);
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
                                parentHash: eventId,
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
    );
  }

  Widget _greyDivider() {
    return const Divider(
      color: Colors.grey,
      thickness: 0.5,
      height: 20,
    );
  }
}
