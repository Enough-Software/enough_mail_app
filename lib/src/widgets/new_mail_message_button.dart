import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../localization/extension.dart';
import '../models/compose_data.dart';
import '../routes/routes.dart';

/// Visualize a button to compose a new mail message
///
/// This is done as a [FloatingActionButton]
class NewMailMessageButton extends ConsumerWidget {
  /// Creates a [NewMailMessageButton]
  const NewMailMessageButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => FloatingActionButton(
        onPressed: () => context.pushNamed(
          Routes.mailCompose,
          extra: ComposeData(
            null,
            MessageBuilder(),
            ComposeAction.newMessage,
          ),
        ),
        tooltip: ref.text.homeFabTooltip,
        elevation: 2,
        child: const Icon(Icons.add),
      );
}
