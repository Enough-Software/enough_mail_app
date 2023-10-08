import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';

class EmptyMessage extends StatelessWidget {
  const EmptyMessage({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.all(8),
        child: SelectablePlatformListTile(
          visualDensity: VisualDensity.compact,
          title: Text('...'),
          subtitle: Text('-'),
        ),
      );
}
