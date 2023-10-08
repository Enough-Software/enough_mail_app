import 'package:intl/intl.dart' as intl;

import 'app_localizations.g.dart';

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get signature => 'Mit Maily gesendet';

  @override
  String get actionCancel => 'Abbrechen';

  @override
  String get actionOk => 'OK';

  @override
  String get actionDone => 'Fertig';

  @override
  String get actionNext => 'Weiter';

  @override
  String get actionSkip => 'Überspringen';

  @override
  String get actionUndo => 'Rückgängig';

  @override
  String get actionDelete => 'Löschen';

  @override
  String get actionAccept => 'Akzeptieren';

  @override
  String get actionDecline => 'Ablehnen';

  @override
  String get actionEdit => 'Bearbeiten';

  @override
  String get actionAddressCopy => 'Kopieren';

  @override
  String get actionAddressCompose => 'Neue Nachricht';

  @override
  String get actionAddressSearch => 'Suchen';

  @override
  String get splashLoading1 => 'Maily startet...';

  @override
  String get splashLoading2 => 'Maily fängt an zu arbeiten...';

  @override
  String get splashLoading3 => 'Maily startet in 10, 9, 8...';

  @override
  String get welcomePanel1Title => 'Maily';

  @override
  String get welcomePanel1Text => 'Willkommen zu Maily, deinem freundlichen und schnellen E-Mail Helferlein!';

  @override
  String get welcomePanel2Title => 'Konten';

  @override
  String get welcomePanel2Text => 'Verwalte beliebig viele E-Mail Konten. Lese und suche Mails in allen Konten gleichzeitig';

  @override
  String get welcomePanel3Title => 'Wisch und drück mich!';

  @override
  String get welcomePanel3Text => 'Wische eine E-Mail um sie zu löschen oder als gelesen zu markieren. Halte eine E-Mail lange um mehrere gleichzeitig zu bearbeiten.';

  @override
  String get welcomePanel4Title => 'Halte Deinen Posteingang sauber';

  @override
  String get welcomePanel4Text => 'Melde Dich von Newslettern mit einem Klick ab.';

  @override
  String get welcomeActionSignIn => 'Melde dich bei deinem E-Mail Konto an';

  @override
  String get homeSearchHint => 'Deine Suche';

  @override
  String get homeActionsShowAsStack => 'Stapel Modus';

  @override
  String get homeActionsShowAsList => 'Listen Modus';

  @override
  String get homeEmptyFolderMessage => 'Alles fertig!\n\nEs gibt keine E-Mails in diesem Ordner.';

  @override
  String get homeEmptySearchMessage => 'Keine E-Mails gefunden.';

  @override
  String get homeDeleteAllTitle => 'Bestätigung';

  @override
  String get homeDeleteAllQuestion => 'Wirklich alle E-Mails löschen?';

  @override
  String get homeDeleteAllAction => 'Alle löschen';

  @override
  String get homeDeleteAllScrubOption => 'Endgültig löschen';

  @override
  String get homeDeleteAllSuccess => 'Alle E-Mails gelöscht.';

  @override
  String get homeMarkAllSeenAction => 'Gelesen';

  @override
  String get homeMarkAllUnseenAction => 'Ungelesen';

  @override
  String get homeFabTooltip => 'Neue E-Mail';

  @override
  String get homeLoadingMessageSourceTitle => 'Lade Daten...';

  @override
  String homeLoading(String name) {
    return 'Lade $name...';
  }

  @override
  String get swipeActionToggleRead => 'Gelesen / ungelesen';

  @override
  String get swipeActionDelete => 'Löschen';

  @override
  String get swipeActionMarkJunk => 'Als Spam markieren';

  @override
  String get swipeActionArchive => 'Archivieren';

  @override
  String get swipeActionFlag => 'Markieren';

  @override
  String multipleMovedToJunk(int number) {
    final intl.NumberFormat numberNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
      
    );
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$numberString Nachrichten als Spam markiert',
      one: 'Eine Nachricht als Spam markiert',
    );
    return '$_temp0';
  }

  @override
  String multipleMovedToInbox(int number) {
    final intl.NumberFormat numberNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
      
    );
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$numberString Nachrichten in Inbox geschoben',
      one: 'Eine Nachricht in Inbox geschoben',
    );
    return '$_temp0';
  }

  @override
  String multipleMovedToArchive(int number) {
    final intl.NumberFormat numberNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
      
    );
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$numberString Nachrichten archiviert',
      one: 'Eine Nachricht archiviert',
    );
    return '$_temp0';
  }

  @override
  String multipleMovedToTrash(int number) {
    final intl.NumberFormat numberNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
      
    );
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$numberString Nachrichten gelöscht',
      one: 'Eine Nachricht gelöscht',
    );
    return '$_temp0';
  }

  @override
  String get multipleSelectionNeededInfo => 'Wähle mindestens eine Nachricht aus.';

  @override
  String multipleMoveTitle(int number) {
    final intl.NumberFormat numberNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
      
    );
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$numberString Nachrichten verschieben',
      one: 'Nachricht verschieben',
    );
    return '$_temp0';
  }

  @override
  String get messageActionMultipleMarkSeen => 'Als gelesen markieren';

  @override
  String get messageActionMultipleMarkUnseen => 'Als ungelesen markieren';

  @override
  String get messageActionMultipleMarkFlagged => 'Markieren';

  @override
  String get messageActionMultipleMarkUnflagged => 'Markierung entfernen';

  @override
  String get messageActionViewInSafeMode => 'Ohne externe Inhalte anzeigen';

  @override
  String get emailSenderUnknown => '<unbekannt>';

  @override
  String get dateRangeFuture => 'Zukunft';

  @override
  String get dateRangeTomorrow => 'morgen';

  @override
  String get dateRangeToday => 'heute';

  @override
  String get dateRangeYesterday => 'gestern';

  @override
  String get dateRangeCurrentWeek => 'diese Woche';

  @override
  String get dateRangeLastWeek => 'letzte Woche';

  @override
  String get dateRangeCurrentMonth => 'diesen Monat';

  @override
  String get dateRangeLastMonth => 'letzten Monat';

  @override
  String get dateRangeCurrentYear => 'dieses Jahr';

  @override
  String get dateRangeLongAgo => 'lange her';

  @override
  String get dateUndefined => 'undefiniert';

  @override
  String get dateDayToday => 'heute';

  @override
  String get dateDayYesterday => 'gestern';

  @override
  String dateDayLastWeekday(String day) {
    return 'letzten $day';
  }

  @override
  String get drawerEntryAbout => 'Über Maily';

  @override
  String get drawerEntrySettings => 'Einstellungen';

  @override
  String drawerAccountsSectionTitle(int number) {
    final intl.NumberFormat numberNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
      
    );
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$numberString Konten',
      one: '1 Konto',
    );
    return '$_temp0';
  }

  @override
  String get drawerEntryAddAccount => 'Konto hinzufügen';

  @override
  String get unifiedAccountName => 'Alle Konten';

  @override
  String get unifiedFolderInbox => 'Alle Posteingänge';

  @override
  String get unifiedFolderSent => 'Alle Gesendeten';

  @override
  String get unifiedFolderDrafts => 'Alle Entwürfe';

  @override
  String get unifiedFolderTrash => 'Alle Gelöschten';

  @override
  String get unifiedFolderArchive => 'Alle Archivierten';

  @override
  String get unifiedFolderJunk => 'Alle Spam Nachrichten';

  @override
  String get folderInbox => 'Posteingang';

  @override
  String get folderSent => 'Gesendete Nachrichten';

  @override
  String get folderDrafts => 'Entwürfe';

  @override
  String get folderTrash => 'Papierkorb';

  @override
  String get folderArchive => 'Archiv';

  @override
  String get folderJunk => 'Spam Nachrichten';

  @override
  String get viewContentsAction => 'Inhalt anzeigen';

  @override
  String get viewSourceAction => 'Sourcecode anzeigen';

  @override
  String get detailsErrorDownloadInfo => 'E-Mail konnte nicht geladen werden.';

  @override
  String get detailsErrorDownloadRetry => 'wiederholen';

  @override
  String get detailsHeaderFrom => 'Von';

  @override
  String get detailsHeaderTo => 'An';

  @override
  String get detailsHeaderCc => 'CC';

  @override
  String get detailsHeaderBcc => 'BCC';

  @override
  String get detailsHeaderDate => 'Datum';

  @override
  String get subjectUndefined => '<ohne Betreff>';

  @override
  String get detailsActionShowImages => 'Bilder anzeigen';

  @override
  String get detailsNewsletterActionUnsubscribe => 'Abbestellen';

  @override
  String get detailsNewsletterActionResubscribe => 'Neu abbonieren';

  @override
  String get detailsNewsletterStatusUnsubscribed => 'Abbestellt';

  @override
  String get detailsNewsletterUnsubscribeDialogTitle => 'Abbestellen';

  @override
  String detailsNewsletterUnsubscribeDialogQuestion(String listName) {
    return 'Möchtest du die Mailingliste $listName abbestellen?';
  }

  @override
  String get detailsNewsletterUnsubscribeDialogAction => 'Abbestellen';

  @override
  String get detailsNewsletterUnsubscribeSuccessTitle => 'Abbestellt';

  @override
  String detailsNewsletterUnsubscribeSuccessMessage(String listName) {
    return 'Du hast dich von der Mailingliste $listName erfolgreich abgemeldet.';
  }

  @override
  String get detailsNewsletterUnsubscribeFailureTitle => 'Nicht abbestellt';

  @override
  String detailsNewsletterUnsubscribeFailureMessage(String listName) {
    return 'Entschuldige, ich konnte dich nicht automatisch von $listName abmelden.';
  }

  @override
  String get detailsNewsletterResubscribeDialogTitle => 'Abonnieren';

  @override
  String detailsNewsletterResubscribeDialogQuestion(String listName) {
    return 'Möchtest du die Mailingliste $listName wieder abonnieren?';
  }

  @override
  String get detailsNewsletterResubscribeDialogAction => 'Abonnieren';

  @override
  String get detailsNewsletterResubscribeSuccessTitle => 'Aboniert';

  @override
  String detailsNewsletterResubscribeSuccessMessage(String listName) {
    return 'Du hast wieder die Mailingliste $listName abonniert.';
  }

  @override
  String get detailsNewsletterResubscribeFailureTitle => 'Nicht abonniert';

  @override
  String detailsNewsletterResubscribeFailureMessage(String listName) {
    return 'Entschuldige, ich konnte dich leider nicht automatisch bei der Mailingliste $listName anmelden.';
  }

  @override
  String get detailsSendReadReceiptAction => 'Lesebestätigung senden';

  @override
  String get detailsReadReceiptSentStatus => 'Lesebestätigung gesendet ✔';

  @override
  String get detailsReadReceiptSubject => 'Lesebestätigung';

  @override
  String get attachmentActionOpen => 'Öffnen';

  @override
  String get messageActionReply => 'Antworten';

  @override
  String get messageActionReplyAll => 'Allen antworten';

  @override
  String get messageActionForward => 'Weiterleiten';

  @override
  String get messageActionForwardAsAttachment => 'Als Anhang weiterleiten';

  @override
  String messageActionForwardAttachments(int number) {
    final intl.NumberFormat numberNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
      
    );
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$numberString Anhänge weiterleiten',
      one: 'Anhang weiterleiten',
    );
    return '$_temp0';
  }

  @override
  String get messagesActionForwardAttachments => 'Anhänge weiterleiten';

  @override
  String get messageActionDelete => 'Löschen';

  @override
  String get messageActionMoveToInbox => 'In Posteingang verschieben';

  @override
  String get messageActionMove => 'Verschieben';

  @override
  String get messageStatusSeen => 'Ist gelesen';

  @override
  String get messageStatusUnseen => 'Ist ungelesen';

  @override
  String get messageStatusFlagged => 'Ist markiert';

  @override
  String get messageStatusUnflagged => 'Ist nicht markiert';

  @override
  String get messageActionMarkAsJunk => 'Als Spam markieren';

  @override
  String get messageActionMarkAsNotJunk => 'Als nicht-Spam markieren';

  @override
  String get messageActionArchive => 'Archivieren';

  @override
  String get messageActionUnarchive => 'In Posteingang verschieben';

  @override
  String get messageActionRedirect => 'Umleiten';

  @override
  String get messageActionAddNotification => 'Benachrichtigung hinzufügen';

  @override
  String get resultDeleted => 'Gelöscht';

  @override
  String get resultMovedToJunk => 'Als Spam markiert';

  @override
  String get resultMovedToInbox => 'In Posteingang verschoben';

  @override
  String get resultArchived => 'Archiviert';

  @override
  String get resultRedirectedSuccess => 'Nachricht umgeleitet 👍';

  @override
  String resultRedirectedFailure(String details) {
    return 'Nachricht konnte nicht umgeleitet werden.\n\nDer Server meldet folgende Details: \"$details\"';
  }

  @override
  String get redirectTitle => 'Umleiten';

  @override
  String get redirectInfo => 'Leite diese Nachricht an folgende Empfänger:innen um. Umleiten verändert nicht die Nachricht.';

  @override
  String get redirectEmailInputRequired => 'Bitte gebe mindestens eine gültige E-Mail-Adresse ein.';

  @override
  String searchQueryDescription(String folder) {
    return 'Suche in $folder...';
  }

  @override
  String searchQueryTitle(String query) {
    return 'Suche \"$query\"';
  }

  @override
  String get legaleseUsage => 'Durch die Nutzung von Maily stimmst du unserer [PP] und unseren [TC] zu.';

  @override
  String get legalesePrivacyPolicy => 'Datenschutzerlärung';

  @override
  String get legaleseTermsAndConditions => 'Bedingungen';

  @override
  String get aboutApplicationLegalese => 'Maily ist freie Software unter der GPL GNU General Public License lizensiert.';

  @override
  String get feedbackActionSuggestFeature => 'Feature vorschlagen';

  @override
  String get feedbackActionReportProblem => 'Problem berichten';

  @override
  String get feedbackActionHelpDeveloping => 'Hilf Maily zu entwickeln';

  @override
  String get feedbackTitle => 'Feedback';

  @override
  String get feedbackIntro => 'Danke dass du Maily testest!';

  @override
  String get feedbackProvideInfoRequest => 'Bitte teile folgende Information mit, wenn du ein Problem berichtest:';

  @override
  String get feedbackResultInfoCopied => 'kopiert';

  @override
  String get accountsTitle => 'Konten';

  @override
  String get accountsActionReorder => 'Konten Reihenfolge ändern';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsSecurityBlockExternalImages => 'Externe Bilder blockieren';

  @override
  String get settingsSecurityBlockExternalImagesDescriptionTitle => 'Externe Bilder';

  @override
  String get settingsSecurityBlockExternalImagesDescriptionText => 'E-Mails können Bilder enthalten, die entweder in der Nachricht integriert sind oder die von externen Servern bereitgestellt werden. Solche externe Bilder können Daten zu dem Absender der Nachricht freigeben, zum Beispiel dass die Nachricht geöffnet wurde. Diese Option erlaubt es solche externen Bilder zu blockieren, um solche Datenlecks zu minimieren. Beim Lesen einer E-Mail kannst für jede Nachricht individual externe Bilder nachladen.';

  @override
  String get settingsSecurityMessageRenderingHtml => 'Gesamte Nachricht anzeigen';

  @override
  String get settingsSecurityMessageRenderingPlainText => 'Nur den Text der Nachricht anzeigen';

  @override
  String get settingsSecurityLaunchModeLabel => 'Wie soll Maily Links öffnen?';

  @override
  String get settingsSecurityLaunchModeExternal => 'Öffne Links extern';

  @override
  String get settingsSecurityLaunchModeInApp => 'Öffne Links in Maily';

  @override
  String get settingsActionAccounts => 'Konten verwalten';

  @override
  String get settingsActionDesign => 'Darstellung';

  @override
  String get settingsActionFeedback => 'Feedback geben';

  @override
  String get settingsActionWelcome => 'Willkommen anzeigen';

  @override
  String get settingsReadReceipts => 'Lesebestätigungen';

  @override
  String get readReceiptsSettingsIntroduction => 'Sollen Lesebestätigungs-Anforderungen angezeigt werden?';

  @override
  String get readReceiptOptionAlways => 'Immer';

  @override
  String get readReceiptOptionNever => 'Nie';

  @override
  String get settingsFolders => 'Ordner';

  @override
  String get folderNamesIntroduction => 'Welche Ordner-Namen möchtest du nutzen?';

  @override
  String get folderNamesSettingLocalized => 'Von Maily vorgegebene Namen';

  @override
  String get folderNamesSettingServer => 'Vom Maildienst gegebene Namen';

  @override
  String get folderNamesSettingCustom => 'Meine eigenen Namen';

  @override
  String get folderNamesEditAction => 'Eigene Ordner Namen ändern';

  @override
  String get folderNamesCustomTitle => 'Eigene Namen';

  @override
  String get folderAddAction => 'Ordner erstellen';

  @override
  String get folderAddTitle => 'Ordner erstellen';

  @override
  String get folderAddNameLabel => 'Name';

  @override
  String get folderAddNameHint => 'Name des Ordners';

  @override
  String get folderAccountLabel => 'Konto';

  @override
  String get folderMailboxLabel => 'Erstelle in';

  @override
  String get folderAddResultSuccess => 'Ordner erstellt 😊';

  @override
  String folderAddResultFailure(String details) {
    return 'Der Ordner konnte nicht erstellt werden.\n\nDer Server antwortete mit \"$details\".';
  }

  @override
  String get folderDeleteAction => 'Löschen';

  @override
  String get folderDeleteConfirmTitle => 'Bestätigen';

  @override
  String folderDeleteConfirmText(String name) {
    return 'Möchtest Du den Ordner $name wirklich löschen?';
  }

  @override
  String get folderDeleteResultSuccess => 'Ordner gelöscht.';

  @override
  String folderDeleteResultFailure(String details) {
    return 'Der Ordner konnte nicht gelöscht werden.\n\nDer Server antwortete mit \"$details\".';
  }

  @override
  String get settingsDevelopment => 'Entwicklungs-Einstellungen';

  @override
  String get developerModeTitle => 'Entwicklungs-Modus';

  @override
  String get developerModeIntroduction => 'Mit einem aktivierten Entwicklungs-Modus kannst du den Sourcecode von Mails einsehen, siehst alle Fehler-Details und Text Anhänge in eine Mail Nachricht umwandeln.';

  @override
  String get developerModeEnable => 'Entwicklungs-Modus aktivieren';

  @override
  String get developerShowAsEmail => 'Text zu E-Mail konvertieren';

  @override
  String get developerShowAsEmailFailed => 'Dieser Text kann nicht in einer MIME Nachricht umgewandelt werden.';

  @override
  String get designTitle => 'Design Einstellungen';

  @override
  String get designSectionThemeTitle => 'Modus';

  @override
  String get designThemeOptionLight => 'Hell';

  @override
  String get designThemeOptionDark => 'Dunkel';

  @override
  String get designThemeOptionSystem => 'System';

  @override
  String get designThemeOptionCustom => 'Selbst definieren';

  @override
  String get designSectionCustomTitle => 'Der dunkle Modus wird aktiviert';

  @override
  String designThemeCustomStart(String time) {
    return 'von $time';
  }

  @override
  String designThemeCustomEnd(String time) {
    return 'bis $time';
  }

  @override
  String get designSectionColorTitle => 'Farbschema';

  @override
  String get securitySettingsTitle => 'Sicherheit';

  @override
  String get securitySettingsIntro => 'Passe die Sicherheitseinstellungen deinen persönlichen Ansprüchen an.';

  @override
  String get securityUnlockWithFaceId => 'Entsicher Maily mit Face ID.';

  @override
  String get securityUnlockWithTouchId => 'Entsicher Maily mit Touch ID.';

  @override
  String get securityUnlockReason => 'Entsicher Maily.';

  @override
  String get securityUnlockDisableReason => 'Entsicher Maily um die Sicherung zu deaktvieren.';

  @override
  String get securityUnlockNotAvailable => 'Dein Gerät unterstützt keine Biometrie-Absicherung. Vielleicht musst du zuerst die Displaysperre in den Geräteeinstellungen aktivieren.';

  @override
  String get securityUnlockLabel => 'Maily Absichern';

  @override
  String get securityUnlockDescriptionTitle => 'Maily Absichern';

  @override
  String get securityUnlockDescriptionText => 'Du kannst Maily absichern, so dass anderen deine E-Mails auch dann nicht lesen können, wenn sie Zugang zu deinem Gerät haben.';

  @override
  String get securityLockImmediately => 'Sofort absichern';

  @override
  String get securityLockAfter5Minutes => 'Nach 5 Minuten absichern';

  @override
  String get securityLockAfter30Minutes => 'Nach 30 Minuten absichern';

  @override
  String get lockScreenTitle => 'Maily ist gesichert';

  @override
  String get lockScreenIntro => 'Maily ist gesichert, bitte authentifiziere dich um weiter zu machen.';

  @override
  String get lockScreenUnlockAction => 'Entsichern';

  @override
  String get addAccountTitle => 'Konto hinzufügen';

  @override
  String get addAccountEmailLabel => 'E-Mail';

  @override
  String get addAccountEmailHint => 'Deine E-Mail Adresse';

  @override
  String addAccountResolvingSettingsLabel(String email) {
    return 'Suche $email Einstellungen...';
  }

  @override
  String addAccountResolvedSettingsWrongAction(String provider) {
    return 'Nicht bei $provider?';
  }

  @override
  String addAccountResolvingSettingsFailedInfo(String email) {
    return 'Ich konte die Einstellungen für $email nicht finden. Bitte gehe zurück und ändere die E-Mail Adresse oder gebe die Einstellungen manuell an.';
  }

  @override
  String get addAccountEditManuallyAction => 'Manuell bearbeiten';

  @override
  String get addAccountPasswordLabel => 'Passwort';

  @override
  String get addAccountPasswordHint => 'Dein Passwort';

  @override
  String get addAccountApplicationPasswordRequiredInfo => 'Dieser Anbieter verlangt ein Applikations-spezifisches Passwort.';

  @override
  String get addAccountApplicationPasswordRequiredButton => 'App Passwort erstellen';

  @override
  String get addAccountApplicationPasswordRequiredAcknowledged => 'Verstanden';

  @override
  String get addAccountVerificationStep => 'Überprüfen';

  @override
  String get addAccountSetupAccountStep => 'Konto Einrichten';

  @override
  String addAccountVerifyingSettingsLabel(String email) {
    return 'Überprüfe $email...';
  }

  @override
  String addAccountVerifyingSuccessInfo(String email) {
    return 'Erfolgreich mit $email angemeldet.';
  }

  @override
  String addAccountVerifyingFailedInfo(String email) {
    return 'Leider konnte ich dich nicht anmelden. Überprüfe deine E-Mail $email und dein Passwort.';
  }

  @override
  String addAccountOauthOptionsText(String provider) {
    return 'Melde dich mit $provider an oder erstelle ein Applikations-spezifisches Passwort.';
  }

  @override
  String addAccountOauthSignIn(String provider) {
    return 'Mit $provider einloggen';
  }

  @override
  String get addAccountOauthSignInGoogle => 'Mit Google einloggen';

  @override
  String get addAccountOauthSignInWithAppPassword => 'Oder erstelle ein Applikations-Passwort:';

  @override
  String get accountAddImapAccessSetupMightBeRequired => 'Vielleicht musst Du bei deinem Anbieter den Zugang für E-Mail Apps aktivieren.';

  @override
  String get addAccountSetupImapAccessButtonLabel => 'E-Mail Zugang aktivieren';

  @override
  String get addAccountNameOfUserLabel => 'Dein Name';

  @override
  String get addAccountNameOfUserHint => 'Name, den Empfänger:innen sehen';

  @override
  String get addAccountNameOfAccountLabel => 'Konto Name';

  @override
  String get addAccountNameOfAccountHint => 'Gebe den Namen des Kontos an';

  @override
  String editAccountTitle(String name) {
    return 'Bearbeite $name';
  }

  @override
  String editAccountFailureToConnectInfo(String name) {
    return 'Maily konnte $name nicht erreichen.';
  }

  @override
  String get editAccountFailureToConnectRetryAction => 'Wiederholen';

  @override
  String get editAccountFailureToConnectChangePasswordAction => 'Passwort ändern';

  @override
  String get editAccountFailureToConnectFixedTitle => 'Verbunden';

  @override
  String get editAccountFailureToConnectFixedInfo => 'Das Konto ist wieder verbunden.';

  @override
  String get editAccountIncludeInUnifiedLabel => 'zu \"Alle Konten\" hinzufügen';

  @override
  String editAccountAliasLabel(String email) {
    return 'Alias E-Mail Adressen für $email:';
  }

  @override
  String get editAccountNoAliasesInfo => 'Du hast noch keine bekannten Alias E-Mail Adressen für dieses Konto.';

  @override
  String editAccountAliasRemoved(String email) {
    return '$email Alias gelöscht';
  }

  @override
  String get editAccountAddAliasAction => 'Alias hinzufügen';

  @override
  String get editAccountPlusAliasesSupported => 'Unterstützt + Aliase';

  @override
  String get editAccountCheckPlusAliasAction => 'Teste Unterstützung für + Aliase';

  @override
  String get editAccountBccMyself => 'Setze mich auf BCC';

  @override
  String get editAccountBccMyselfDescriptionTitle => 'Setze mich auf CC';

  @override
  String get editAccountBccMyselfDescriptionText => 'Du kannst Dir selbst eine \"BCC\" Kopie von jeder Nachricht schicken, die du von diesem Konto verschickst. Normalerweise ist das nicht nötig und nicht gewollt, weil alle gesendeten Nachrichten im\"Gesendete Nachrichten\" Ordner gespeichert werden.';

  @override
  String get editAccountServerSettingsAction => 'Bearbeite Server Einstellungen';

  @override
  String get editAccountDeleteAccountAction => 'Lösche Konto';

  @override
  String get editAccountDeleteAccountConfirmationTitle => 'Bestätige';

  @override
  String editAccountDeleteAccountConfirmationQuery(String name) {
    return 'Möchtest du das Konto $name löschen?';
  }

  @override
  String editAccountTestPlusAliasTitle(String name) {
    return '+ Aliase für $name';
  }

  @override
  String get editAccountTestPlusAliasStepIntroductionTitle => 'Einleitung';

  @override
  String editAccountTestPlusAliasStepIntroductionText(String accountName, String example) {
    return 'Dein Konto $accountName könnte sogenannte + Aliase wie $example unterstützen.\nEin + Alias hilft dir Deine Identität zu schützen und kann gegen Spam helfen.\nUm dies zu testen, wird eine Nachricht an diese generierte Adresse gesendet. Wenn sie ankommt, dann unterstützt dein Anbieter  + Aliase und du kannst leicht neue generieren wenn Du eine E-Mail schreibst.';
  }

  @override
  String get editAccountTestPlusAliasStepTestingTitle => 'Testen';

  @override
  String get editAccountTestPlusAliasStepResultTitle => 'Ergebnis';

  @override
  String editAccountTestPlusAliasStepResultSuccess(String name) {
    return 'Dein Konto $name unterstütz + Aliase.';
  }

  @override
  String editAccountTestPlusAliasStepResultNoSuccess(String name) {
    return 'Dein Konto $name unterstütz leider keine + Aliase.';
  }

  @override
  String get editAccountAddAliasTitle => 'Alias hinzufügen';

  @override
  String get editAccountEditAliasTitle => 'Alias bearbeiten';

  @override
  String get editAccountAliasAddAction => 'Hinzufügen';

  @override
  String get editAccountAliasUpdateAction => 'Ändern';

  @override
  String get editAccountEditAliasNameLabel => 'Alias Name';

  @override
  String get editAccountEditAliasEmailLabel => 'Alias E-Mail';

  @override
  String get editAccountEditAliasEmailHint => 'Deine Alias E-Mail Adresse';

  @override
  String editAccountEditAliasDuplicateError(String email) {
    return 'Es gibt bereits einen Alias mit $email.';
  }

  @override
  String get editAccountEnableLogging => 'Log aktivieren';

  @override
  String get editAccountLoggingEnabled => 'Log aktiviert, bitte neu starten';

  @override
  String get editAccountLoggingDisabled => 'Log de-aktiviert, bitte neu starten';

  @override
  String get accountDetailsFallbackTitle => 'Server Einstellungen';

  @override
  String get errorTitle => 'Fehler';

  @override
  String get accountProviderStepTitle => 'E-Mail Service Anbieter';

  @override
  String get accountProviderCustom => 'Anderer E-Mail Service';

  @override
  String accountDetailsErrorHostProblem(String incomingHost, String outgoingHost) {
    return 'Maily kann den angegeben Server nicht erreich. Bitte überprüfe die Einstellugen des Posteingang-Servers \"$incomingHost\" und des Postausgang-Servers \"$outgoingHost\".';
  }

  @override
  String accountDetailsErrorLoginProblem(String userName, String password) {
    return 'Anmeldung fehlgeschlagen. Bitte überprüfe den Login-Namen \"$userName\" und das Passwort \"$password\".';
  }

  @override
  String get accountDetailsUserNameLabel => 'Login Name';

  @override
  String get accountDetailsUserNameHint => 'Dein Login, falls es nicht die E-Mail ist';

  @override
  String get accountDetailsPasswordLabel => 'Login Passwort';

  @override
  String get accountDetailsPasswordHint => 'Dein Passwort';

  @override
  String get accountDetailsBaseSectionTitle => 'Basis Einstellungen';

  @override
  String get accountDetailsIncomingLabel => 'Posteingangs-Server';

  @override
  String get accountDetailsIncomingHint => 'Domäne wie imap.domain.de';

  @override
  String get accountDetailsOutgoingLabel => 'Postausgangs-Server';

  @override
  String get accountDetailsOutgoingHint => 'Domäne wie smtp.domain.de';

  @override
  String get accountDetailsAdvancedIncomingSectionTitle => 'Erweiterte Posteingang Einstellungen';

  @override
  String get accountDetailsIncomingServerTypeLabel => 'Typ des Posteingang Servers:';

  @override
  String get accountDetailsOptionAutomatic => 'automatisch';

  @override
  String get accountDetailsIncomingSecurityLabel => 'Posteingang Sicherheit:';

  @override
  String get accountDetailsSecurityOptionNone => 'Plain (keine Verschlüsselung)';

  @override
  String get accountDetailsIncomingPortLabel => 'Posteingang Port';

  @override
  String get accountDetailsPortHint => 'Leer lassen um automatisch finden zu lassen';

  @override
  String get accountDetailsIncomingUserNameLabel => 'Posteingang Login-Name';

  @override
  String get accountDetailsAlternativeUserNameHint => 'Login, falls abweichend von oben';

  @override
  String get accountDetailsIncomingPasswordLabel => 'Posteingang Passwort';

  @override
  String get accountDetailsAlternativePasswordHint => 'Passwort, falls abweichend von oben';

  @override
  String get accountDetailsAdvancedOutgoingSectionTitle => 'Erweiterte Postausgang Einstellungen';

  @override
  String get accountDetailsOutgoingServerTypeLabel => 'Typ des Postausgang Servers:';

  @override
  String get accountDetailsOutgoingSecurityLabel => 'Postausgang Sicherheit:';

  @override
  String get accountDetailsOutgoingPortLabel => 'Postausgang Port';

  @override
  String get accountDetailsOutgoingUserNameLabel => 'Postausgang Login-Name';

  @override
  String get accountDetailsOutgoingPasswordLabel => 'Postausgang Passwort';

  @override
  String get composeTitleNew => 'Neu';

  @override
  String get composeTitleForward => 'Weiterleitung';

  @override
  String get composeTitleReply => 'Antwort';

  @override
  String get composeEmptyMessage => 'Leere Nachricht';

  @override
  String get composeWarningNoSubject => 'Du hast kein Betreff geschrieben. Möchtest du die Nachricht ohne Betreff senden?';

  @override
  String get composeActionSentWithoutSubject => 'Senden';

  @override
  String get composeMailSendSuccess => 'Gesendet 😊';

  @override
  String composeSendErrorInfo(String details) {
    return 'Leider konnte die E-Mail nicht versendet werden.\nDer Postausgang Server liefert folgende Antwort:\n$details';
  }

  @override
  String get composeRequestReadReceiptAction => 'Lesebestätigung anfordern';

  @override
  String get composeSaveDraftAction => 'Als Entwurf speichern';

  @override
  String get composeMessageSavedAsDraft => 'Entwurf gespeichert';

  @override
  String composeMessageSavedAsDraftErrorInfo(String details) {
    return 'Der Entwurf konnte nicht gespeichert werden.\nDie Fehlermeldung lautet:\n$details';
  }

  @override
  String get composeConvertToPlainTextEditorAction => 'Zu Text-Nachricht konvertieren';

  @override
  String get composeConvertToHtmlEditorAction => 'Zu HTML-Nachricht konvertieren';

  @override
  String get composeContinueEditingAction => 'Weiter bearbeiten';

  @override
  String get composeCreatePlusAliasAction => 'Neuen + Alias erstellen...';

  @override
  String get composeSenderHint => 'Absender:in';

  @override
  String get composeRecipientHint => 'E-Mails der Empfänger:innen';

  @override
  String get composeSubjectLabel => 'Betreff';

  @override
  String get composeSubjectHint => 'Betreff der Nachricht';

  @override
  String get composeAddAttachmentAction => 'Hinzufügen';

  @override
  String composeRemoveAttachmentAction(String name) {
    return '$name entfernen';
  }

  @override
  String get composeLeftByMistake => 'Aus Versehen verlassen?';

  @override
  String get attachTypeFile => 'Datei';

  @override
  String get attachTypePhoto => 'Foto';

  @override
  String get attachTypeVideo => 'Video';

  @override
  String get attachTypeAudio => 'Audio';

  @override
  String get attachTypeLocation => 'Ort';

  @override
  String get attachTypeGif => 'Animiertes Gif';

  @override
  String get attachTypeGifSearch => 'in GIPHY suchen';

  @override
  String get attachTypeSticker => 'Sticker';

  @override
  String get attachTypeStickerSearch => 'in GIPHY suchen';

  @override
  String get attachTypeAppointment => 'Termin';

  @override
  String get languageSettingTitle => 'Sprache (Language)';

  @override
  String get languageSettingLabel => 'Währe die Sprache für Maily:';

  @override
  String get languageSettingSystemOption => 'Systemsprache';

  @override
  String get languageSettingConfirmationTitle => 'Deutsch für Maily nutzen?';

  @override
  String get languageSettingConfirmationQuery => 'Bitte bestätige, dass deutsch als Sprache verwendet werden soll.';

  @override
  String get languageSetInfo => 'Maily ist nun auf deutsch. Bitte starte die App neu.';

  @override
  String get languageSystemSetInfo => 'Maily wird nun die Systemsprache oder englisch nutzen, wenn die Systemprache nicht unterstützt wird. Bitte starte die App neu.';

  @override
  String get swipeSettingTitle => 'Wischgesten';

  @override
  String get swipeSettingLeftToRightLabel => 'Von links nach rechts wischen';

  @override
  String get swipeSettingRightToLeftLabel => 'Von rechts nach links wischen';

  @override
  String get swipeSettingChangeAction => 'Ändern';

  @override
  String get signatureSettingsTitle => 'Signatur';

  @override
  String get signatureSettingsComposeActionsInfo => 'Aktiviere die Signatur für folgende Nachrichten:';

  @override
  String get signatureSettingsAccountInfo => 'Du kannst Signaturen für Konten in den Konten-Einstellungen festlegen.';

  @override
  String signatureSettingsAddForAccount(String account) {
    return 'Signature für $account hinzufügen';
  }

  @override
  String get defaultSenderSettingsTitle => 'Standard Absender';

  @override
  String get defaultSenderSettingsLabel => 'Wähle den Absender für neue Nachrichten aus.';

  @override
  String defaultSenderSettingsFirstAccount(String email) {
    return 'Erstes Konto ($email)';
  }

  @override
  String get defaultSenderSettingsAliasInfo => 'Du kannst Alias E-Mail Adressen in den [AS] festlegen.';

  @override
  String get defaultSenderSettingsAliasAccountSettings => 'Konto-Einstellungen';

  @override
  String get replySettingsTitle => 'Nachrichten Format';

  @override
  String get replySettingsIntro => 'In welchem Format möchtest du Nachrichten schreiben?';

  @override
  String get replySettingsFormatHtml => 'Immer HTML';

  @override
  String get replySettingsFormatSameAsOriginal => 'Im selben Format wie die Orignal-Nachricht';

  @override
  String get replySettingsFormatPlainText => 'Immer nur Text';

  @override
  String get moveTitle => 'Nachricht verschieben';

  @override
  String moveSuccess(String mailbox) {
    return 'In $mailbox verschoben.';
  }

  @override
  String get editorArtInputLabel => 'Deine Eingabe';

  @override
  String get editorArtInputHint => 'Hier Text eingeben';

  @override
  String get editorArtWaitingForInputHint => 'warte auf Eingabe';

  @override
  String get fontSerifBold => 'Serif fett';

  @override
  String get fontSerifItalic => 'Serif kursiv';

  @override
  String get fontSerifBoldItalic => 'Serif fett kursiv';

  @override
  String get fontSans => 'Sans';

  @override
  String get fontSansBold => 'Sans fett';

  @override
  String get fontSansItalic => 'Sans kursiv';

  @override
  String get fontSansBoldItalic => 'Sans fett kursiv';

  @override
  String get fontScript => 'Script';

  @override
  String get fontScriptBold => 'Script fett';

  @override
  String get fontFraktur => 'Fraktur';

  @override
  String get fontFrakturBold => 'Fraktur fett';

  @override
  String get fontMonospace => 'Monospace';

  @override
  String get fontFullwidth => 'Fullwidth';

  @override
  String get fontDoublestruck => 'Double struck';

  @override
  String get fontCapitalized => 'Grossbuchstaben';

  @override
  String get fontCircled => 'Eingekreist';

  @override
  String get fontParenthesized => 'Geklammert';

  @override
  String get fontUnderlinedSingle => 'Unterstrichen';

  @override
  String get fontUnderlinedDouble => 'Doppelt unterstrichen';

  @override
  String get fontStrikethroughSingle => 'Durchgestrichen';

  @override
  String get fontCrosshatch => 'Crosshatch';

  @override
  String accountLoadError(String name) {
    return 'Keine Verbindung mit $name möglich. Wurde vielleicht das Passwort geändert?';
  }

  @override
  String get accountLoadErrorEditAction => 'Konto bearbeiten';

  @override
  String get extensionsTitle => 'Erweiterungen';

  @override
  String get extensionsIntro => 'Mit Erweiterungen können E-Mail-Dienstleister, Firmen und Entwickler:innen Maily mit hilfreichen Funktionen ergänzen.';

  @override
  String get extensionsLearnMoreAction => 'Lerne mehr über Erweiterungen';

  @override
  String get extensionsReloadAction => 'Erweiterungen neu laden';

  @override
  String get extensionDeactivateAllAction => 'Alle Erweiterungen deaktivieren';

  @override
  String get extensionsManualAction => 'Manuell laden';

  @override
  String get extensionsManualUrlLabel => 'Url der Erweiterung';

  @override
  String extensionsManualLoadingError(String url) {
    return 'Es kann keine Erweiterung von \"$url\" heruntergeladen werden.';
  }

  @override
  String get icalendarAcceptTentatively => 'Vorbehaltlich';

  @override
  String get icalendarActionChangeParticipantStatus => 'Ändern';

  @override
  String get icalendarLabelSummary => 'Titel';

  @override
  String get icalendarNoSummaryInfo => '(kein Titel)';

  @override
  String get icalendarLabelDescription => 'Beschreibung';

  @override
  String get icalendarLabelStart => 'Start';

  @override
  String get icalendarLabelEnd => 'Ende';

  @override
  String get icalendarLabelDuration => 'Dauer';

  @override
  String get icalendarLabelLocation => 'Ort';

  @override
  String get icalendarLabelTeamsUrl => 'Link';

  @override
  String get icalendarLabelRecurrenceRule => 'Wiederholung';

  @override
  String get icalendarLabelParticipants => 'Teilnehmer';

  @override
  String get icalendarParticipantStatusNeedsAction => 'Du wirst gebeten, diese Einladung zu beantworten.';

  @override
  String get icalendarParticipantStatusAccepted => 'Du hast die Einladung akzeptiert.';

  @override
  String get icalendarParticipantStatusDeclined => 'Du hast die Einladung abgelehnt.';

  @override
  String get icalendarParticipantStatusAcceptedTentatively => 'Du hast die Einladung vorbehaltlich akzeptiert.';

  @override
  String get icalendarParticipantStatusDelegated => 'Du hast die Teilnahme delegiert.';

  @override
  String get icalendarParticipantStatusInProcess => 'Die Aufgabe wird bearbeitet.';

  @override
  String get icalendarParticipantStatusPartial => 'Die Aufgabe ist teilweise erledigt.';

  @override
  String get icalendarParticipantStatusCompleted => 'Die Aufgabe ist erledigt.';

  @override
  String get icalendarParticipantStatusOther => 'Der Status ist unbekannt.';

  @override
  String get icalendarParticipantStatusChangeTitle => 'Dein Status';

  @override
  String get icalendarParticipantStatusChangeText => 'Möchtest Du an diese Einladung annehmen?';

  @override
  String icalendarParticipantStatusSentFailure(String details) {
    return 'Antwort kann nicht gesendet werrden.\nDer Server hat mit den folgenden Details geantwortet:\n$details';
  }

  @override
  String get icalendarExportAction => 'Exportieren';

  @override
  String icalendarReplyStatusNeedsAction(String attendee) {
    return '$attendee hat diese Einladung nicht beantwortet.';
  }

  @override
  String icalendarReplyStatusAccepted(String attendee) {
    return '$attendee hat die Einladung akzeptiert.';
  }

  @override
  String icalendarReplyStatusDeclined(String attendee) {
    return '$attendee hat die Einladung abgelehnt.';
  }

  @override
  String icalendarReplyStatusAcceptedTentatively(String attendee) {
    return '$attendee hat die Einladung vorbehaltlich akzeptiert.';
  }

  @override
  String icalendarReplyStatusDelegated(String attendee) {
    return '$attendee hat die Teilnahme delegiert.';
  }

  @override
  String icalendarReplyStatusInProcess(String attendee) {
    return '$attendee hat mit der Aufgabe begonnen.';
  }

  @override
  String icalendarReplyStatusPartial(String attendee) {
    return '$attendee hat die Aufgabe teilweise erledigt.';
  }

  @override
  String icalendarReplyStatusCompleted(String attendee) {
    return '$attendee hat die Aufgabe erledigt.';
  }

  @override
  String icalendarReplyStatusOther(String attendee) {
    return '$attendee hat mit einem unbekannten Status geantwortet.';
  }

  @override
  String get icalendarReplyWithoutParticipants => 'Diese Antwort enthält keine Teilnehmer:innen.';

  @override
  String icalendarReplyWithoutStatus(String attendee) {
    return '$attendee hat eine Antwort ohne Teilnahme-Status gesendet.';
  }

  @override
  String get composeAppointmentTitle => 'Einladung erstellen';

  @override
  String get composeAppointmentLabelDay => 'Tag';

  @override
  String get composeAppointmentLabelTime => 'Zeit';

  @override
  String get composeAppointmentLabelAllDayEvent => 'Ganztägiger Termin';

  @override
  String get composeAppointmentLabelRepeat => 'Wiederholen';

  @override
  String get composeAppointmentLabelRepeatOptionNever => 'Nie';

  @override
  String get composeAppointmentLabelRepeatOptionDaily => 'Täglich';

  @override
  String get composeAppointmentLabelRepeatOptionWeekly => 'Wöchentlich';

  @override
  String get composeAppointmentLabelRepeatOptionMonthly => 'Monatlich';

  @override
  String get composeAppointmentLabelRepeatOptionYearly => 'Jährlich';

  @override
  String get composeAppointmentRecurrenceFrequencyLabel => 'Frequenz';

  @override
  String get composeAppointmentRecurrenceIntervalLabel => 'Intervall';

  @override
  String get composeAppointmentRecurrenceDaysLabel => 'An Tagen';

  @override
  String get composeAppointmentRecurrenceUntilLabel => 'Bis';

  @override
  String get composeAppointmentRecurrenceUntilOptionUnlimited => 'Unlimitiert';

  @override
  String composeAppointmentRecurrenceUntilOptionRecommended(String duration) {
    return 'Empfohlen ($duration)';
  }

  @override
  String get composeAppointmentRecurrenceUntilOptionSpecificDate => 'Bestimmtes Datum';

  @override
  String composeAppointmentRecurrenceMonthlyOnDayOfMonth(int day) {
    final intl.NumberFormat dayNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
      
    );
    final String dayString = dayNumberFormat.format(day);

    return 'Am $dayString. Tag des Monats';
  }

  @override
  String get composeAppointmentRecurrenceMonthlyOnWeekDay => 'Am Wochentag des Monats';

  @override
  String get composeAppointmentRecurrenceFirst => 'Erster';

  @override
  String get composeAppointmentRecurrenceSecond => 'Zweiter';

  @override
  String get composeAppointmentRecurrenceThird => 'Dritter';

  @override
  String get composeAppointmentRecurrenceLast => 'Letzter';

  @override
  String get composeAppointmentRecurrenceSecondLast => 'Vorletzter';

  @override
  String durationYears(int number) {
    final intl.NumberFormat numberNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
      
    );
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$numberString Jahre',
      one: '1 Jahr',
    );
    return '$_temp0';
  }

  @override
  String durationMonths(int number) {
    final intl.NumberFormat numberNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
      
    );
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$numberString Monate',
      one: '1 Monat',
    );
    return '$_temp0';
  }

  @override
  String durationWeeks(int number) {
    final intl.NumberFormat numberNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
      
    );
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$numberString Wochen',
      one: '1 Woche',
    );
    return '$_temp0';
  }

  @override
  String durationDays(int number) {
    final intl.NumberFormat numberNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
      
    );
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$numberString Tage',
      one: '1 Tag',
    );
    return '$_temp0';
  }

  @override
  String durationHours(int number) {
    final intl.NumberFormat numberNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
      
    );
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$numberString Stunden',
      one: '1 Stunde',
    );
    return '$_temp0';
  }

  @override
  String durationMinutes(int number) {
    final intl.NumberFormat numberNumberFormat = intl.NumberFormat.compactLong(
      locale: localeName,
      
    );
    final String numberString = numberNumberFormat.format(number);

    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: '$numberString Minuten',
      one: '1 Minute',
    );
    return '$_temp0';
  }

  @override
  String get durationEmpty => 'Keine Dauer';
}
