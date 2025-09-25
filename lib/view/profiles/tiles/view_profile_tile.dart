import 'package:flutter/material.dart';
import 'package:wyd_front/model/profile.dart';
import 'package:wyd_front/service/media/image_provider_service.dart';

class ViewProfileTile extends StatelessWidget {
  final Profile? profile;
  final String? imageUrl;
  const ViewProfileTile({super.key, required this.profile, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (profile == null) {
      return ListTile(
          leading: CircleAvatar(
            backgroundImage: ImageProviderService.getImageProvider(),
          ),
          title: Text('Loading...'));
    } else {
      return ListTile(
        leading: CircleAvatar(
          backgroundImage: ImageProviderService.getProfileImage(profile!.id, profile!.blobHash!),
        ),
        title: Text(profile!.name),
      );
    }
  }
}
