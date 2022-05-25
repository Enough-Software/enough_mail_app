import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  const PasswordField({
    Key? key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.onChanged,
    this.autofocus = false,
    this.cupertinoShowLabel = true,
  }) : super(key: key);

  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final void Function(String text)? onChanged;
  final bool autofocus;
  final bool cupertinoShowLabel;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return DecoratedPlatformTextField(
      controller: widget.controller,
      obscureText: _obscureText,
      onChanged: widget.onChanged,
      autofocus: widget.autofocus,
      cupertinoShowLabel: widget.cupertinoShowLabel,
      decoration: InputDecoration(
        hintText: widget.hintText,
        labelText: widget.labelText,
        suffixIcon: PlatformIconButton(
          icon: Icon(_obscureText ? Icons.lock_open : Icons.lock),
          onPressed: () {
            setState(
              () => _obscureText = !_obscureText,
            );
          },
          cupertino: (context, platform) => CupertinoIconButtonData(
            padding: const EdgeInsets.fromLTRB(0, 0, 5, 2),
            icon: Icon(
              _obscureText ? Icons.lock_open : Icons.lock,
              color: CupertinoColors.secondaryLabel,
              size: 20.0,
            ),
          ),
        ),
      ),
    );
  }
}
