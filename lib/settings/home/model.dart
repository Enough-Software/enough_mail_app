import 'package:flutter/widgets.dart';

/// Standard setting entries
enum UiSettingsType {
  divider,
  security,
  accounts,
  swipe,
  signature,
  defaultSender,
  design,
  language,
  folders,
  readReceipts,
  reply,
  feedback,
  about,
  welcome,
  development,
}

/// A UI element for the settings screen
class UiSettingsElement {
  /// Creates a new [UiSettingsElement]
  const UiSettingsElement({
    required this.title,
    required this.onTap,
    this.type,
    this.subtitle,
    this.icon,
  });

  /// Creates a new [UiSettingsElement] as a divider
  UiSettingsElement.divider()
      : this(
          title: '',
          onTap: null,
          type: UiSettingsType.divider,
        );

  /// The title of the element
  final String title;

  /// The standard type of the element
  final UiSettingsType? type;

  /// The subtitle of the element
  final String? subtitle;

  /// The icon of the element
  final IconData? icon;

  /// The action when the element is tapped
  final VoidCallback? onTap;

  /// Is this element a divider?
  bool get isDivider => type == UiSettingsType.divider;
}

/// Eases custom elements
extension UiSettingsElementsExtension on List<UiSettingsElement> {
  /// Inserts an element after the element with the given type
  void insertAfter(UiSettingsType type, UiSettingsElement element) {
    final index = indexWhere((e) => e.type == type);
    if (index == -1) {
      add(element);
    } else {
      insert(index + 1, element);
    }
  }

  /// Inserts an element before the element with the given type
  void insertBefore(UiSettingsType type, UiSettingsElement element) {
    final index = indexWhere((e) => e.type == type);
    if (index == -1) {
      insert(0, element);
    } else {
      insert(index, element);
    }
  }

  /// Removes the element with the given type
  void removeType(UiSettingsType type) {
    removeWhere((e) => e.type == type);
  }
}
