import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../localization/extension.dart';
import '../models/compose_data.dart';
import '../routes.dart';

/// Visualize a button to compose a new mail message
///
/// This is done as a [FloatingActionButton]
class NewMailMessageButton extends StatelessWidget {
  /// Creates a [NewMailMessageButton]
  const NewMailMessageButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) => FloatingActionButton(
        onPressed: () => context.push(
          Routes.mailCompose,
          extra: ComposeData(
            null,
            MessageBuilder(),
            ComposeAction.newMessage,
          ),
        ),
        tooltip: context.text.homeFabTooltip,
        elevation: 2,
        child: const Icon(Icons.add),
      );
}
