import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/widgets/icon_text.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';

import '../l10n/app_localizations.g.dart';

import 'package:enough_mail_app/models/contact.dart';
import 'package:enough_mail_app/util/validator.dart';

class RecipientInputField extends StatefulWidget {
  const RecipientInputField({
    Key? key,
    this.labelText,
    this.hintText,
    this.controller,
    this.additionalSuffixIcon,
    this.autofocus = false,
    required this.addresses,
    required this.contactManager,
  }) : super(key: key);

  final String? labelText;
  final String? hintText;
  final TextEditingController? controller;
  final Widget? additionalSuffixIcon;
  final bool autofocus;
  final List<MailAddress> addresses;
  final ContactManager? contactManager;

  @override
  State<RecipientInputField> createState() => _RecipientInputFieldState();
}

enum _AddressAction {
  copy,
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
    final localizations = AppLocalizations.of(context)!;
    return DragTarget<MailAddress>(
      builder: (context, candidateData, rejectedData) {
        final labelText = widget.labelText;
        return Container(
          color: candidateData.isEmpty ? null : theme.hoverColor,
          child: Wrap(
            children: [
              if (widget.addresses.isNotEmpty && labelText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                  child: Text(
                    labelText,
                    style: TextStyle(
                      color: _focusNode.hasFocus
                          ? theme.colorScheme.secondary
                          : theme.hintColor,
                    ),
                  ),
                ),
              for (final address in widget.addresses)
                Draggable(
                  data: address,
                  feedback: Opacity(
                    opacity: 0.8,
                    child: Material(
                      child: _AddressChip(
                        address: address,
                      ),
                    ),
                  ),
                  feedbackOffset: const Offset(10.0, 10.0),
                  childWhenDragging: Opacity(
                    opacity: 0.6,
                    child: _AddressChip(
                      address: address,
                    ),
                  ),
                  child: _AddressChip<_AddressAction>(
                    address: address,
                    onDeleted: () {
                      widget.addresses.remove(address);
                      setState(() {});
                    },
                    menuItems: [
                      PlatformPopupMenuItem(
                        value: _AddressAction.copy,
                        child: IconText(
                          icon: Icon(CommonPlatformIcons.copy),
                          label: Text(localizations.actionAddressCopy),
                        ),
                      ),
                    ],
                    onMenuItemSelected: (action) {
                      switch (action) {
                        case _AddressAction.copy:
                          Clipboard.setData(ClipboardData(text: address.email));
                          break;
                      }
                    },
                  ),
                ),
              buildInput(theme, context),
            ],
          ),
        );
      },
      onAccept: (mailAddress) {
        widget.addresses.add(mailAddress);
      },
      onLeave: (mailAddress) {
        widget.addresses.remove(mailAddress);
      },
    );
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
                    icon: const Icon(Icons.contacts),
                    onPressed: () => _pickContact(textEditingController),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      widget.additionalSuffixIcon!,
                      PlatformIconButton(
                        icon: const Icon(Icons.contacts),
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
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(8.0),
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final MailAddress option = options.elementAt(index);
                  return PlatformActionChip(
                    label: Column(
                      children: [
                        if (option.hasPersonalName) Text(option.personalName!),
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
      widget.addresses.add(
        MailAddress(
          contact.fullName,
          contact.email!.email!,
        ),
      );
      setState(() {});

      // final contact =
      //     await FlutterContactPicker.pickEmailContact(askForPermission: true);
      // widget.addresses
      //     .add(MailAddress(contact.fullName, contact.email!.email!));
      // setState(() {});
      // if (controller.text.isNotEmpty) {
      //   controller.text += '; ' + contact.email.email;
      // } else {
      //   controller.text = contact.email.email;
      // }
      // controller.selection =
      //     TextSelection.collapsed(offset: controller.text.length);
    } catch (e, s) {
      if (kDebugMode) {
        print('Unable to pick contact $e $s');
      }
    }
  }
}

class _AddressChip<T> extends StatelessWidget {
  const _AddressChip({
    Key? key,
    required this.address,
    this.onDeleted,
    this.menuItems,
    this.onMenuItemSelected,
  }) : super(key: key);
  final MailAddress address;
  final VoidCallback? onDeleted;

  /// Compare [onMenuItemSelected]
  final List<PlatformPopupMenuItem<T>>? menuItems;

  /// Compare [menuItems]
  final void Function(T value)? onMenuItemSelected;

  @override
  Widget build(BuildContext context) {
    final content = PlatformChip(
        label: Column(
          children: [
            Text(address.personalName ?? ''),
            Text(address.email, style: Theme.of(context).textTheme.caption),
          ],
        ),
        deleteIcon: const Icon(Icons.close),
        onDeleted: onDeleted);
    final menuItems = this.menuItems;
    if (menuItems == null) {
      return content;
    }
    final theme = Theme.of(context);
    return PlatformPopupMenuButton<T>(
      cupertinoButtonPadding: EdgeInsets.zero,
      title: address.hasPersonalName ? Text(address.personalName!) : null,
      message: Text(address.email, style: theme.textTheme.caption),
      itemBuilder: (context) => menuItems,
      onSelected: onMenuItemSelected,
      child: content,
    );
  }
}
