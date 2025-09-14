import 'package:flutter/material.dart';
import 'package:wyd_front/model/profile.dart';
import 'package:wyd_front/service/media/image_provider_service.dart';
import 'package:wyd_front/state/user/user_provider.dart';
import 'package:wyd_front/view/profiles/profile_editor.dart';
import 'package:wyd_front/view/widget/view/custom_page.dart';

class MainProfileTile extends StatelessWidget {
  final Profile? profile;
  final Alignment alignment;
  final double height;
  final double maxWidth;

  const MainProfileTile({
    super.key,
    required this.profile,
    this.alignment = Alignment.center,
    this.height = 100,
    this.maxWidth = 700,
  });

  @override
  Widget build(BuildContext context) {
    var exists = profile != null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: Align(
        alignment: alignment,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
            minHeight: height,
          ),
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (exists) {
                      showCustomPage(
                          context, ProfileEditor(profile: profile!));
                    }
                  },
                  child: Row(
                    children: [
                      SizedBox(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: profile?.color ?? Colors.green,
                              width: 5.0,
                            ),
                          ),
                          child: CircleAvatar(
                            backgroundImage: ImageProviderService.getImageProvider(),
                            radius: 40,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exists ? profile!.name : "Loading...",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              exists ? profile!.tag : "Loading...",
                              style: TextStyle(fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              if (exists) actions(profile!.hash),
            ],
          ),
        ),
      ),
    );
  }

  Widget actions(String profileHash) {
    return Row(
      children: [
        if (profileHash != UserProvider().getCurrentProfileHash())
          const SizedBox(width: 10),
        if (profileHash != UserProvider().getCurrentProfileHash())
          ElevatedButton(onPressed: () => {}, child: Text("Switch")),
        const SizedBox(width: 10),
        ElevatedButton(onPressed: () => {}, child: Text("Hide")),
      ],
    );
  }
}
