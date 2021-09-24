import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/models/contact.dart';
import 'package:enough_mail_app/util/validator.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';

class RecipientInputField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final TextEditingController? controller;
  final Widget? additionalSuffixIcon;
  final bool autofocus;
  final List<MailAddress> addresses;
  final ContactManager? contactManager;

  RecipientInputField({
    Key? key,
    this.labelText,
    this.hintText,
    this.controller,
    this.additionalSuffixIcon,
    this.autofocus = false,
    required this.addresses,
    required this.contactManager,
  }) : super(key: key);

  @override
  _RecipientInputFieldState createState() => _RecipientInputFieldState();
}

class _RecipientInputFieldState extends State<RecipientInputField> {
  final _focusNode = FocusNode();
  late TextEditingController _controller;

  @override
  void initState() {
    _controller = widget.controller ?? TextEditingController();
    super.initState();
    _focusNode.addListener(_update);
  }

  void _update() {
    if (!_focusNode.hasFocus) {
      checkEmail(_controller.text);
    }
    setState(() {});
  }

  @override
  dispose() {
    super.dispose();
    _focusNode.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(children: [
      if (widget.addresses.isNotEmpty && widget.labelText != null) ...{
        Padding(
          padding: EdgeInsets.only(top: 8.0, right: 8.0),
          child: Text(
            widget.labelText!,
            style: TextStyle(
              color: _focusNode.hasFocus
                  ? theme.colorScheme.secondary
                  : theme.hintColor,
            ),
          ),
        ),
      },
      for (final address in widget.addresses) ...{
        PlatformChip(
          label: Column(
            children: [
              if (address.hasPersonalName) ...{
                Text(address.personalName!),
              },
              Text(address.email, style: theme.textTheme.caption),
            ],
          ),
          deleteIcon: Icon(Icons.close),
          onDeleted: () {
            widget.addresses.remove(address);
            setState(() {});
          },
        ),
      },
      buildInput(theme, context),
    ]);
  }

  Widget buildInput(ThemeData theme, BuildContext context) {
    return RawAutocomplete<MailAddress>(
      focusNode: _focusNode,
      textEditingController: _controller,
      optionsBuilder: (textEditingValue) {
        final search = textEditingValue.text.toLowerCase();
        if (search.length < 2) {
          return [];
        }
        if (search.endsWith(' ') ||
            search.endsWith(';') ||
            search.endsWith(';')) {
          // check if this is a complete email address
          final email = textEditingValue.text.substring(0, search.length - 1);
          checkEmail(email);
        }
        final contactManager = widget.contactManager;
        if (contactManager == null) {
          return [];
        }
        final matches = contactManager.find(search).toList();
        // do not suggest recipients that are already added:
        for (final existing in widget.addresses) {
          matches.remove(existing);
        }
        return matches;
      },
      displayStringForOption: (option) => option.toString(),
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
        return DecoratedPlatformTextField(
          controller: textEditingController,
          focusNode: focusNode,
          autofocus: widget.autofocus,
          onSubmitted: (text) {
            onFieldSubmitted();
          },
          onEditingComplete: () => checkEmail(_controller.text),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: widget.addresses.isNotEmpty ? null : widget.labelText,
            hintText: widget.hintText,
            suffixIcon: widget.additionalSuffixIcon == null
                ? PlatformIconButton(
                    icon: Icon(Icons.contacts),
                    onPressed: () => _pickContact(textEditingController),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      widget.additionalSuffixIcon!,
                      PlatformIconButton(
                        icon: Icon(Icons.contacts),
                        onPressed: () => _pickContact(textEditingController),
                      ),
                    ],
                  ),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Material(
          child: Align(
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(8.0),
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final MailAddress option = options.elementAt(index);
                  return PlatformActionChip(
                    label: Column(
                      children: [
                        if (option.hasPersonalName) ...{
                          Text(option.personalName!),
                        },
                        Text(option.email, style: theme.textTheme.caption),
                      ],
                    ),
                    onPressed: () {
                      final currentTextInput = _controller.text;
                      onSelected(option);
                      if (!widget.addresses.contains(option)) {
                        widget.addresses.add(option);
                        setState(() {});
                        _controller.text = '';
                      } else {
                        _controller.value = TextEditingValue(
                          selection: TextSelection.collapsed(
                              offset: currentTextInput.length),
                          text: currentTextInput,
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void checkEmail(String input) {
    if (Validator.validateEmail(input)) {
      final address = MailAddress(null, input);
      widget.addresses.add(address);
      _controller.text = '';
      setState(() {});
    }
  }

  void _pickContact(TextEditingController controller) async {
    try {
      final contact =
          await FlutterContactPicker.pickEmailContact(askForPermission: true);
      widget.addresses
          .add(MailAddress(contact.fullName, contact.email!.email!));
      setState(() {});
      // if (controller.text.isNotEmpty) {
      //   controller.text += '; ' + contact.email.email;
      // } else {
      //   controller.text = contact.email.email;
      // }
      // controller.selection =
      //     TextSelection.collapsed(offset: controller.text.length);
    } catch (e, s) {
      print('Unable to pick contact $e $s');
    }
  }
}
