import 'package:flutter/material.dart';

class IconText extends StatelessWidget {
  const IconText({
    super.key,
    required this.icon,
    required this.label,
    this.padding = const EdgeInsets.all(8),
    this.horizontalPadding = const EdgeInsets.only(left: 8),
    this.brightness,
  });
  final Widget icon;
  final Widget label;
  final EdgeInsets padding;
  final EdgeInsets horizontalPadding;
  final Brightness? brightness;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding,
      child: Row(
        children: [
          icon,
          Expanded(
            child: Padding(
              padding: horizontalPadding,
              child: label,
            ),
          ),
        ],
      ),
    );

    return brightness != null
        ? Theme(data: ThemeData(brightness: brightness), child: content)
        : content;
  }
}
