import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';
import 'package:wyd_front/model/mask/mask.dart';

class MaskTile extends StatelessWidget {
  final CalendarEvent<String> event;
  final Mask maskData;  // Now passed in explicitly
  final double opacity;

  const MaskTile({
    super.key,
    required this.event,
    required this. maskData,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blueAccent. withAlpha(200),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.blue, width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              maskData.title ??  '(Untitled Mask)',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}