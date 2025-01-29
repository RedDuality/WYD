import 'package:flutter/material.dart';
import 'package:wyd_front/model/profile.dart';
import 'package:wyd_front/service/util/image_service.dart';

class ViewProfileTile extends StatelessWidget {
  final Profile? profile;
  final String? imageUrl;
  const ViewProfileTile({super.key, required this.profile, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (profile == null) {
      return ListTile(
          leading: CircleAvatar(
            backgroundImage: ImageService().getImageProvider(),
          ),
          title: Text('Loading...'));
    } else {
      return ListTile(
        leading: CircleAvatar(
          backgroundImage: ImageService().getImageProvider(imageUrl: imageUrl),
        ),
        title: Text(profile!.name),
      );
    }
  }
}
