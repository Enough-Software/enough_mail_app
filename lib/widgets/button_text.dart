import 'dart:io';

import 'package:flutter/widgets.dart';

class ButtonText extends StatelessWidget {
  const ButtonText(
    this.data, {
    this.style,
    super.key,
  });
  final String? data;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    var text = data;
    if (Platform.isAndroid) {
      text = text!.toUpperCase();
    }
    return Text(
      text!,
      style: style,
    );
  }
}
