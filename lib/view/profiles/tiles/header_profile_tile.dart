import 'package:flutter/material.dart';
import 'package:wyd_front/model/users/detailed_profile.dart';
import 'package:wyd_front/service/media/image_provider_service.dart';

class HeaderProfileTile extends StatelessWidget {
  final DetailedProfile? profile;
  final double circleSize;
  final double borderSize;
  final double padding;
 

  const HeaderProfileTile({
    super.key,
    required this.profile,
    this.borderSize = 3.5,
    this.circleSize = 20,
    this.padding = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: profile?.color ?? Colors.green,
            width: borderSize,
          ),
        ),
        child: CircleAvatar(
          backgroundImage: ImageProviderService.getImageProvider(),
          radius: circleSize,
        ),
      ),
    );
  }
}
