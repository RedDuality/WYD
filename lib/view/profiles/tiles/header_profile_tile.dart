import 'package:flutter/material.dart';
import 'package:wyd_front/model/profile.dart';
import 'package:wyd_front/service/util/image_service.dart';

class HeaderProfileTile extends StatelessWidget {
  final Profile? profile;
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
          backgroundImage: ImageService.getImageProvider(),
          radius: circleSize,
        ),
      ),
    );
  }
}
