import 'dart:io';

import 'package:flutter/widgets.dart';

class ButtonText extends StatelessWidget {
  final String? data;
  final TextStyle? style;

  const ButtonText(
    this.data, {
    this.style,
    Key? key,
  }) : super(key: key);

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
