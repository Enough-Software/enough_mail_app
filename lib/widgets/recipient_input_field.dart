import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/models/contact.dart';
import 'package:enough_mail_app/util/validator.dart';
import 'package:flutter/material.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';

class RecipientInputField extends StatefulWidget {
  final String labelText;
  final String hintText;
  final TextEditingController controller;
  final Widget additionalSuffixIcon;
  final bool autofocus;
  final List<MailAddress> addresses;
  final ContactManager contactManager;

  RecipientInputField({
    Key key,
    this.labelText,
    this.hintText,
    this.controller,
    this.additionalSuffixIcon,
    this.autofocus = false,
    @required this.addresses,
    @required this.contactManager,
  }) : super(key: key);

  @override
  _RecipientInputFieldState createState() => _RecipientInputFieldState();
}

class _RecipientInputFieldState extends State<RecipientInputField> {
  final focusNode = FocusNode();
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(_update);
  }

  void _update() {
    if (!focusNode.hasFocus) {
      checkEmail(controller.text);
    }
    setState(() {});
  }

  @override
  dispose() {
    super.dispose();
    focusNode.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(children: [
      if (widget.addresses.isNotEmpty && widget.labelText != null) ...{
        Text(
          widget.labelText,
          style: TextStyle(
              color: focusNode.hasFocus ? theme.accentColor : theme.hintColor),
        ),
      },
      for (final address in widget.addresses) ...{
        Chip(
          label: Column(
            children: [
              if (address.hasPersonalName) ...{
                Text(address.personalName),
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
      focusNode: focusNode,
      textEditingController: controller,
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
        if (widget.contactManager == null) {
          return [];
        }
        return widget.contactManager.find(search);
      },
      displayStringForOption: (option) => option.toString(),
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          autofocus: widget.autofocus,
          onSubmitted: (text) {
            onFieldSubmitted();
          },
          onEditingComplete: () => checkEmail(controller.text),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: widget.addresses.isNotEmpty ? null : widget.labelText,
            hintText: widget.hintText,
            suffixIcon: widget.additionalSuffixIcon == null
                ? IconButton(
                    icon: Icon(Icons.contacts),
                    onPressed: () => _pickContact(textEditingController),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      widget.additionalSuffixIcon,
                      IconButton(
                        icon: Icon(Icons.contacts),
                        onPressed: () => _pickContact(textEditingController),
                      ),
                    ],
                  ),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(8.0),
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final MailAddress option = options.elementAt(index);
                  return ActionChip(
                    label: Column(
                      children: [
                        if (option.hasPersonalName) ...{
                          Text(option.personalName),
                        },
                        Text(option.email, style: theme.textTheme.caption),
                      ],
                    ),
                    onPressed: () {
                      if (!widget.addresses.contains(option)) {
                        widget.addresses.add(option);
                        controller.text = '';
                        setState(() {});
                      }
                      onSelected(null);
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
      controller.text = '';
      setState(() {});
    }
  }

  void _pickContact(TextEditingController controller) async {
    try {
      final contact =
          await FlutterContactPicker.pickEmailContact(askForPermission: true);
      if (contact != null) {
        widget.addresses
            .add(MailAddress(contact.fullName, contact.email.email));
        setState(() {});
        // if (controller.text.isNotEmpty) {
        //   controller.text += '; ' + contact.email.email;
        // } else {
        //   controller.text = contact.email.email;
        // }
        // controller.selection =
        //     TextSelection.collapsed(offset: controller.text.length);
      }
    } catch (e, s) {
      print('Unable to pick contact $e $s');
    }
  }
}
