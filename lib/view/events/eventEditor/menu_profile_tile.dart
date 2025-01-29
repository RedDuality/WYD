import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/service/util/image_service.dart';
import 'package:wyd_front/view/profiles/profiles_notifier.dart';

class MenuProfileTile extends StatelessWidget {
  final String hash;
  final Alignment alignment;
  final double height;
  final double? imageWidth;

  //final String title;
  //final String subtititle;
  final double titleFontSize;
  final double subtitleFontSize;

  const MenuProfileTile({
    super.key,
    required this.hash,
    this.alignment = Alignment.centerLeft,
    this.height = 40,
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
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
              child: Align(
                alignment: alignment,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: height,
                      height: imageWidth ?? height,
                      child: CircleAvatar(
                        backgroundImage: ImageService().getImageProvider(),
                        radius: 30,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notifier.profile!.name,
                          style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          notifier.profile!.tag,
                          style: TextStyle(
                              fontSize: subtitleFontSize,
                              fontWeight: FontWeight.bold),
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
