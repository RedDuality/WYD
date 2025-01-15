import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/service/util/image_service.dart';
import 'package:wyd_front/view/profiles/profiles_notifier.dart';

class ProfileTile extends StatelessWidget {
  final String hash;

  const ProfileTile({super.key, required this.hash});

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
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
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
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(notifier.profile!.tag),
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
