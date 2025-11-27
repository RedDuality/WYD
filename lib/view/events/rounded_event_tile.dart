import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';

class RoundedEventTile extends StatelessWidget {
  final String title;

  final String? description;

  final Color backgroundColor;

  final int totalEvents;

  final EdgeInsets padding;

  final EdgeInsets margin;

  final BorderRadius borderRadius;

  final TextStyle titleStyle;

  final TextStyle? descriptionStyle;

  final List<Color> sideBarColors;

  final double sideBarWidth;

  const RoundedEventTile({
    super.key,
    required this.title,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.description,
    this.borderRadius = BorderRadius.zero,
    this.totalEvents = 1,
    this.backgroundColor = Colors.blue,
    this.sideBarColors = const [Colors.blue],
    this.sideBarWidth = 4,
    required this.titleStyle,
    this.descriptionStyle,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          color: backgroundColor,
        ),
        child: Row(
          children: [
            SizedBox(
              width: sideBarWidth,
              child: Column(
                children: sideBarColors.map((color) {
                  return Expanded(
                    child: Container(
                      color: color,
                    ),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: Padding(
                padding: padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title.isNotEmpty)
                      Expanded(
                        child: Text(
                          title,
                          style: titleStyle,
                          softWrap: true,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    /* 
                    // description
                    if (description?.isNotEmpty ?? false)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: Text(
                            description!,
                            style: descriptionStyle ??
                                TextStyle(
                                  fontSize:12,
                                  color: backgroundColor.accent.withAlpha(200),
                                ),
                          ),
                        ),
                      ),*/
                    if (totalEvents > 1)
                      Expanded(
                        child: Text(
                          "+${totalEvents - 1} more",
                          style: (descriptionStyle ??
                                  TextStyle(
                                    color:
                                        backgroundColor.accent.withAlpha(200),
                                  ))
                              .copyWith(fontSize: 17),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
