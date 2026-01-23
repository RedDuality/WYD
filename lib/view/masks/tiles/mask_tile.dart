import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/model/util/iterable_extension.dart';
import 'package:wyd_front/state/mask/mask_cache.dart';

class MaskTile extends StatelessWidget {
  final CalendarEvent<String> event;

  final double opacity;

  const MaskTile({
    super.key,
    required this.event,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final maskCache = Provider.of<MaskCache>(context, listen: false);
    final maskId = event.data;
    final mask = maskCache.allMasks.firstWhereOrNull((m) => m.id == maskId);

    if (mask == null) return const SizedBox.shrink();

    return Opacity(
      opacity: opacity,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blueAccent.withAlpha(200),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.blue, width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: ClipRect(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  mask.title ?? '(Untitled Mask)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
