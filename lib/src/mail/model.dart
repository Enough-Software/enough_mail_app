import 'package:enough_mail/enough_mail.dart';

import '../localization/app_localizations.g.dart';
import '../models/message_source.dart';
import '../settings/model.dart';

/// Retrieves the localized name for the given mailbox flag
extension _MailboxFlagExtensions on MailboxFlag {
  /// Retrieves the localized name for the given mailbox flag
  String localizedName(
    AppLocalizations localizations,
    Settings settings,
    Mailbox? mailbox,
  ) {
    final identityFlag = this;
    final folderNameSetting = settings.folderNameSetting;
    final isVirtual = mailbox?.isVirtual ?? true;
    switch (folderNameSetting) {
      case FolderNameSetting.server:
        return mailbox?.name ?? name;
      case FolderNameSetting.localized:
        switch (identityFlag) {
          case MailboxFlag.inbox:
            return isVirtual
                ? localizations.unifiedFolderInbox
                : localizations.folderInbox;
          case MailboxFlag.drafts:
            return isVirtual
                ? localizations.unifiedFolderDrafts
                : localizations.folderDrafts;
          case MailboxFlag.sent:
            return isVirtual
                ? localizations.unifiedFolderSent
                : localizations.folderSent;
          case MailboxFlag.trash:
            return isVirtual
                ? localizations.unifiedFolderTrash
                : localizations.folderTrash;
          case MailboxFlag.archive:
            return isVirtual
                ? localizations.unifiedFolderArchive
                : localizations.folderArchive;
          case MailboxFlag.junk:
            return isVirtual
                ? localizations.unifiedFolderJunk
                : localizations.folderJunk;
          // ignore: no_default_cases
          default:
            return mailbox?.name ?? name;
        }
      case FolderNameSetting.custom:
        final customNames = settings.customFolderNames ??
            (isVirtual
                ? [
                    localizations.unifiedFolderInbox,
                    localizations.unifiedFolderDrafts,
                    localizations.unifiedFolderSent,
                    localizations.unifiedFolderTrash,
                    localizations.unifiedFolderArchive,
                    localizations.unifiedFolderJunk,
                  ]
                : [
                    localizations.folderInbox,
                    localizations.folderDrafts,
                    localizations.folderSent,
                    localizations.folderTrash,
                    localizations.folderArchive,
                    localizations.folderJunk,
                  ]);
        switch (identityFlag) {
          case MailboxFlag.inbox:
            return customNames[0];
          case MailboxFlag.drafts:
            return customNames[1];
          case MailboxFlag.sent:
            return customNames[2];
          case MailboxFlag.trash:
            return customNames[3];
          case MailboxFlag.archive:
            return customNames[4];
          case MailboxFlag.junk:
            return customNames[5];
          // ignore: no_default_cases
          default:
            return mailbox?.name ?? name;
        }
    }
  }
}

/// Allows to translate mailbox names
extension MailboxExtensions on Mailbox {
  /// Retrieves the translated name
  String localizedName(AppLocalizations localizations, Settings settings) =>
      identityFlag?.localizedName(localizations, settings, this) ?? name;
}

/// Allows to translate mailbox names
extension MessageSourceExtensions on MessageSource {
  /// Retrieves the translated name
  String localizedName(AppLocalizations localizations, Settings settings) {
    final source = this;
    if (source is MailboxMessageSource) {
      return source.mailbox.localizedName(localizations, settings);
    }
    if (source is MultipleMessageSource) {
      return source.flag.localizedName(localizations, settings, null);
    }

    return source.name ?? source.parentName ?? localizations.folderUnknown;
  }
}
