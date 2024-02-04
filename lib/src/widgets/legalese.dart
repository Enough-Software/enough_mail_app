import 'package:flutter/material.dart';

import '../localization/extension.dart';
import 'text_with_links.dart';

class Legalese extends StatelessWidget {
  const Legalese({super.key});
  static const String urlPrivacyPolicy =
      'https://www.enough.de/privacypolicy/maily-pp.html';
  static const String urlTermsAndConditions =
      'https://github.com/Enough-Software/enough_mail_app/blob/main/LICENSE';

  @override
  Widget build(BuildContext context) {
    final localizations = context.text;
    final legaleseUsage = localizations.legaleseUsage;
    final privacyPolicy = localizations.legalesePrivacyPolicy;
    final termsAndConditions = localizations.legaleseTermsAndConditions;
    final ppIndex = legaleseUsage.indexOf('[PP]');
    final tcIndex = legaleseUsage.indexOf('[TC]');
    final legaleseParts = [
      TextLink(legaleseUsage.substring(0, ppIndex)),
      TextLink(privacyPolicy, urlPrivacyPolicy),
      TextLink(legaleseUsage.substring(ppIndex + '[PP]'.length, tcIndex)),
      TextLink(termsAndConditions, urlTermsAndConditions),
      TextLink(legaleseUsage.substring(tcIndex + '[TC]'.length)),
    ];

    return TextWithNamedLinks(
      parts: legaleseParts,
    );
  }
}
