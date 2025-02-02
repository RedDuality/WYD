import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/service/util/image_service.dart';
import 'package:wyd_front/view/profiles/profiles_notifier.dart';

class MenuProfileTile extends StatelessWidget {
  final String hash;
  final Alignment alignment;
  final double imageHeight;
  final double? imageWidth;

  //final String title;
  //final String subtititle;
  final double titleFontSize;
  final double subtitleFontSize;

  const MenuProfileTile({
    super.key,
    required this.hash,
    this.alignment = Alignment.centerLeft,
    this.imageHeight = 30,
    this.imageWidth,
    this.titleFontSize = 18,
    this.subtitleFontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfilesNotifier>(context);
    var notifier = provider.getNotifier(hash);

    return ChangeNotifierProvider.value(
      value: notifier,
      child: Consumer<ProfileNotifier>(
        builder: (context, notifier, child) {
          if (notifier.profile == null) {
            return ListTile(title: Text('Loading...'));
          } else {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 0.0, horizontal: 7.0),
              child: Align(
                alignment: alignment,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: imageHeight,
                      width: imageWidth ?? imageHeight,
                      child: CircleAvatar(
                        backgroundImage: ImageService().getImageProvider(),
                        radius: imageHeight,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notifier.profile!.name,
                          style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          notifier.profile!.tag,
                          style: TextStyle(
                              color: Colors.grey, fontSize: subtitleFontSize),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
