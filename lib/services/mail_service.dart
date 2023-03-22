import 'dart:convert';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/events/app_event_bus.dart';
import 'package:enough_mail_app/extensions/extensions.dart';
import 'package:enough_mail_app/models/account.dart';
import 'package:enough_mail_app/models/async_mime_source_factory.dart';
import 'package:enough_mail_app/models/message_source.dart';
import 'package:enough_mail_app/models/sender.dart';
import 'package:enough_mail_app/models/settings.dart';
import 'package:enough_mail_app/routes.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_mail_app/services/notification_service.dart';
import 'package:enough_mail_app/services/providers.dart';
import 'package:enough_mail_app/services/settings_service.dart';
import 'package:enough_mail_app/util/gravatar.dart';
import 'package:enough_mail_app/widgets/inherited_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../l10n/app_localizations.g.dart';
import '../locator.dart';
import '../models/async_mime_source.dart';

class MailService implements MimeSourceSubscriber {
  MailService({required AsyncMimeSourceFactory mimeSourceFactory})
      : _mimeSourceFactory = mimeSourceFactory;
  final AsyncMimeSourceFactory _mimeSourceFactory;

  static const _clientId = Id(name: 'Maily', version: '1.0');
  MessageSource? messageSource;
  Account? _currentAccount;
  Account? get currentAccount => _currentAccount;
  List<MailAccount> mailAccounts = <MailAccount>[];
  final accounts = <Account>[];
  UnifiedAccount? unifiedAccount;

  List<Account>? _accountsWithErrors;
  bool get hasUnifiedAccount => (unifiedAccount != null);

  static const String _keyAccounts = 'accts';
  final _storage = const FlutterSecureStorage();
  final _mailClientsPerAccount = <Account, MailClient>{};
  final _mailboxesPerAccount = <Account, Tree<Mailbox?>>{};
  late AppLocalizations _localizations;
  AppLocalizations get localizations => _localizations;

  List<Account> get accountsWithoutErrors {
    final withErrors = _accountsWithErrors;
    if (withErrors == null) {
      return accounts;
    }
    return accounts.where((account) => !withErrors.contains(account)).toList();
  }

  List<Account> get accountsWithErrors {
    final withErrors = _accountsWithErrors;
    return withErrors ?? [];
  }

  set localizations(AppLocalizations value) {
    if (value != _localizations) {
      _localizations = value;
      if (unifiedAccount != null) {
        unifiedAccount!.name = value.unifiedAccountName;
        final mailboxes = _mailboxesPerAccount[unifiedAccount]!
            .root
            .children!
            .map((c) => c.value);
        for (final mailbox in mailboxes) {
          String? name;
          if (mailbox!.isInbox) {
            name = value.unifiedFolderInbox;
          } else if (mailbox.isDrafts) {
            name = value.unifiedFolderDrafts;
          } else if (mailbox.isTrash) {
            name = value.unifiedFolderTrash;
          } else if (mailbox.isSent) {
            name = value.unifiedFolderSent;
          } else if (mailbox.isArchive) {
            name = value.unifiedFolderArchive;
          } else if (mailbox.isJunk) {
            name = value.unifiedFolderJunk;
          }
          if (name != null) {
            mailbox.name = name;
          }
        }
      }
    }
  }

  Future<void> init(AppLocalizations localizations) async {
    _localizations = localizations;
    await _mimeSourceFactory.init();
    await _loadAccounts();
    messageSource = await _initMessageSource();
  }

  Future<void> _loadAccounts() async {
    mailAccounts = await loadMailAccounts();
    for (var mailAccount in mailAccounts) {
      accounts.add(RealAccount(mailAccount));
    }
    _createUnifiedAccount();
  }

  Future<List<MailAccount>> loadMailAccounts() async {
    final jsonText = await _storage.read(key: _keyAccounts);
    if (jsonText == null) {
      return <MailAccount>[];
    }
    final accountsJson = jsonDecode(jsonText) as List;
    try {
      return accountsJson.map((json) => MailAccount.fromJson(json)).toList();
    } catch (e, s) {
      print('Unable to load accounts from json: $e $s');
      return <MailAccount>[];
    }
  }

  Future<MessageSource> search(MailSearch search) async {
    final currentSource = messageSource;
    if (currentSource != null && currentSource.supportsSearching) {
      return currentSource.search(search);
    }
    final Account account = currentAccount ?? unifiedAccount ?? accounts.first;
    final source = await _createMessageSource(null, account);
    messageSource = source;
    return source.search(search);
  }

  void _createUnifiedAccount() {
    final mailAccountsForUnified = accounts.where((account) =>
        (account is RealAccount &&
            !account.hasAttribute(RealAccount.attributeExcludeFromUnified)));
    if (mailAccountsForUnified.length > 1) {
      unifiedAccount = UnifiedAccount(
        List<RealAccount>.from(mailAccountsForUnified),
        _localizations.unifiedAccountName,
      );
      final mailboxes = [
        Mailbox.virtual(_localizations.unifiedFolderInbox, [MailboxFlag.inbox]),
        Mailbox.virtual(
            _localizations.unifiedFolderDrafts, [MailboxFlag.drafts]),
        Mailbox.virtual(_localizations.unifiedFolderSent, [MailboxFlag.sent]),
        Mailbox.virtual(_localizations.unifiedFolderTrash, [MailboxFlag.trash]),
        Mailbox.virtual(
            _localizations.unifiedFolderArchive, [MailboxFlag.archive]),
        Mailbox.virtual(_localizations.unifiedFolderJunk, [MailboxFlag.junk]),
      ];
      final tree = Tree<Mailbox?>(Mailbox.virtual('', []))
        ..populateFromList(mailboxes, (child) => null);
      _mailboxesPerAccount[unifiedAccount!] = tree;
    }
  }

  Future<MessageSource>? _initMessageSource() {
    final account =
        unifiedAccount ?? ((accounts.isNotEmpty) ? accounts.first : null);
    if (account != null) {
      _currentAccount = account;
      return _createMessageSource(null, account);
    }
    return null;
  }

  Future<MessageSource> _createMessageSource(
    Mailbox? mailbox,
    Account account,
  ) async {
    if (account is UnifiedAccount) {
      final mimeSources = await _getUnifiedMimeSources(mailbox, account);
      return MultipleMessageSource(
        mimeSources,
        mailbox == null ? _localizations.unifiedFolderInbox : mailbox.name,
        mailbox?.flags.first ?? MailboxFlag.inbox,
      );
    } else if (account is RealAccount) {
      final mailClient = await _getClientAndStopPolling(account);
      if (mailClient != null) {
        if (mailbox == null) {
          mailbox = await mailClient.selectInbox();
        } else {
          await mailClient.selectMailbox(mailbox);
        }
        final source = _mimeSourceFactory.createMailboxMimeSource(
            mailClient, mailbox)
          ..addSubscriber(this);
        return MailboxMessageSource.fromMimeSource(
          source,
          mailClient.account.email,
          mailbox.name,
        );
      }
    }
    final accountWithErrors = _accountsWithErrors ?? <Account>[];
    if (!accountWithErrors.contains(account)) {
      accountWithErrors.add(account);
      _accountsWithErrors ??= accountsWithErrors;
    }
    return ErrorMessageSource(account);
  }

  Future<List<AsyncMimeSource>> _getUnifiedMimeSources(
    Mailbox? mailbox,
    UnifiedAccount unifiedAccount,
  ) async {
    Future<AsyncMimeSource?> selectMailbox(
      MailboxFlag flag,
      RealAccount account,
    ) async {
      final client = await _getClientAndStopPolling(account);
      if (client == null) {
        _accountsWithErrors ??= <Account>[];
        _accountsWithErrors!.add(account);
        return null;
      }
      Mailbox? accountMailbox = client.getMailbox(flag);
      if (accountMailbox == null) {
        if (client.isConnected) {
          await client.listMailboxes();
          accountMailbox = client.getMailbox(flag);
        }
        if (accountMailbox == null) {
          if (kDebugMode) {
            print(
                'unable to find mailbox with $flag in account ${client.account.name}');
          }
          return null;
        }
      }
      await client.selectMailbox(accountMailbox);
      accountsWithErrors.remove(account);
      return _mimeSourceFactory.createMailboxMimeSource(client, accountMailbox)
        ..addSubscriber(this);
    }

    Future<List<AsyncMimeSource>> resolveFutures(
        List<Future<AsyncMimeSource?>> unresolvedFutures) async {
      final results = await Future.wait(unresolvedFutures);
      final mimeSources =
          List<AsyncMimeSource>.from(results.where((source) => source != null));
      return mimeSources;
    }

    final futures = <Future<AsyncMimeSource?>>[];
    final flag = mailbox?.flags.first ?? MailboxFlag.inbox;
    for (final subAccount in unifiedAccount.accounts) {
      futures.add(selectMailbox(flag, subAccount));
    }
    return resolveFutures(futures);
  }

  Future<MailClient?> _getClientAndStopPolling(RealAccount account) async {
    try {
      final client = await getClientFor(account);
      await client.stopPollingIfNeeded();
      if (!client.isConnected) {
        await client.connect();
      }
      return client;
    } catch (e, s) {
      if (kDebugMode) {
        print('Unable to get client for ${account.email}: $e $s');
      }
      return null;
    }
  }

  void _addGravatar(MailAccount account) {
    final url = Gravatar.imageUrl(
      account.email,
      size: 400,
      defaultImage: GravatarImage.retro,
    );
    account.attributes[RealAccount.attributeGravatarImageUrl] = url;
  }

  Future<bool> addAccount(
    MailAccount mailAccount,
    MailClient mailClient,
    BuildContext context,
  ) async {
    // TODO(RV): remove BuildContext usage in service
    // TODO(RV): check if other account with the same name already exists
    final state = MailServiceWidget.of(context);
    final existing = mailAccounts
        .firstWhereOrNull((account) => account.email == mailAccount.email);
    if (existing != null) {
      final account = accounts.firstWhereOrNull(
        (account) =>
            account is RealAccount && account.email == mailAccount.email,
      );
      if (account is RealAccount) {
        removeAccount(account, context);
      }
    }
    mailAccount = await _checkForAddingSentMessages(mailAccount);
    final newAccount = RealAccount(mailAccount);
    _currentAccount = newAccount;
    accounts.add(newAccount);
    await loadMailboxesFor(mailClient);
    _mailClientsPerAccount[newAccount] = mailClient;
    _addGravatar(mailAccount);
    mailAccounts.add(mailAccount);
    if (!mailAccount.hasAttribute(RealAccount.attributeExcludeFromUnified)) {
      final unified = unifiedAccount;
      if (unified != null) {
        unified.accounts.add(newAccount);
      } else {
        _createUnifiedAccount();
      }
    }
    final source = await getMessageSourceFor(newAccount);
    messageSource = source;
    if (state != null) {
      state.account = newAccount;
      state.accounts = accounts;
      state.messageSource = source;
    }
    await saveAccounts();
    return true;
  }

  List<Sender> getSenders() {
    final senders = <Sender>[];
    for (final account in accounts) {
      if (account is! RealAccount) {
        continue;
      }
      senders.add(Sender(account.fromAddress, account));
      for (final alias in account.aliases) {
        senders.add(Sender(alias, account));
      }
    }
    return senders;
  }

  MessageBuilder mailto(Uri mailto, MimeMessage originatingMessage) {
    final senders = getSenders();
    final searchFor = senders.map((s) => s.address).toList();
    final searchIn = originatingMessage.recipientAddresses
        .map((email) => MailAddress('', email))
        .toList();
    var fromAddress = MailAddress.getMatch(searchFor, searchIn);
    if (fromAddress == null) {
      final settings = locator<SettingsService>().settings;
      if (settings.preferredComposeMailAddress != null) {
        fromAddress = searchFor.firstWhereOrNull(
            (address) => address.email == settings.preferredComposeMailAddress);
      }
      fromAddress ??= searchFor.first;
    }
    return MessageBuilder.prepareMailtoBasedMessage(mailto, fromAddress);
  }

  Future<void> reorderAccounts(List<RealAccount> newOrder) {
    accounts.clear();
    accounts.addAll(newOrder);
    mailAccounts = newOrder.map((a) => a.mailAccount).toList();
    return saveAccounts();
  }

  Future<void> saveAccounts() {
    final accountsJson = mailAccounts.map((a) => a.toJson()).toList();
    final json = jsonEncode(accountsJson);
    return _storage.write(key: _keyAccounts, value: json);
  }

  Future<MailClient> getClientFor(
    RealAccount account,
  ) async =>
      _mailClientsPerAccount[account] ?? await createClientFor(account);

  Future<MailClient> createClientFor(
    RealAccount account, {
    bool store = true,
  }) async {
    final client = createMailClient(account.mailAccount);
    if (store) {
      _mailClientsPerAccount[account] = client;
    }
    await _connect(client);
    await loadMailboxesFor(client);

    return client;
  }

  Future<MailClient> getClientForAccountWithEmail(String? accountEmail) {
    final account = getAccountForEmail(accountEmail)!;
    return getClientFor(account);
  }

  Future<MessageSource> getMessageSourceFor(
    Account account, {
    Mailbox? mailbox,
    bool switchToAccount = false,
  }) async {
    var source = await _createMessageSource(mailbox, account);
    if (switchToAccount) {
      messageSource = source;
      _currentAccount = account;
    }
    return source;
  }

  RealAccount? getAccountFor(MailAccount mailAccount) {
    return accounts.firstWhereOrNull(
      (a) => a is RealAccount && a.mailAccount == mailAccount,
    ) as RealAccount?;
  }

  RealAccount? getAccountForEmail(String? accountEmail) {
    return accounts.firstWhereOrNull(
      (a) => a is RealAccount && a.email == accountEmail,
    ) as RealAccount;
  }

  void applyFolderNameSettings(Settings settings) {
    for (final client in _mailClientsPerAccount.values) {
      _setMailboxNames(settings, client);
    }
  }

  void _setMailboxNames(Settings settings, MailClient client) {
    final folderNameSetting = settings.folderNameSetting;
    if (client.mailboxes == null) {
      return;
    }
    if (folderNameSetting == FolderNameSetting.server) {
      for (final mailbox in client.mailboxes!) {
        mailbox.setNameFromPath();
      }
    } else {
      var names = settings.customFolderNames;
      if (names == null || folderNameSetting == FolderNameSetting.localized) {
        final l = localizations;
        names = [
          l.folderInbox,
          l.folderDrafts,
          l.folderSent,
          l.folderTrash,
          l.folderArchive,
          l.folderJunk
        ];
      }
      final boxes = client.mailboxes;
      if (boxes != null) {
        for (final mailbox in boxes) {
          if (mailbox.isInbox) {
            mailbox.name = names[0];
          } else if (mailbox.isDrafts) {
            mailbox.name = names[1];
          } else if (mailbox.isSent) {
            mailbox.name = names[2];
          } else if (mailbox.isTrash) {
            mailbox.name = names[3];
          } else if (mailbox.isArchive) {
            mailbox.name = names[4];
          } else if (mailbox.isJunk) {
            mailbox.name = names[5];
          }
        }
      }
    }
  }

  Future<void> loadMailboxesFor(MailClient client) async {
    final account = getAccountFor(client.account);
    if (account == null) {
      if (kDebugMode) {
        print('Unable to find account for ${client.account}');
      }
      return;
    }
    final mailboxTree =
        await client.listMailboxesAsTree(createIntermediate: false);
    final settings = locator<SettingsService>().settings;
    if (settings.folderNameSetting != FolderNameSetting.server) {
      _setMailboxNames(settings, client);
    }

    _mailboxesPerAccount[account] = mailboxTree;
  }

  Tree<Mailbox?>? getMailboxTreeFor(Account account) {
    return _mailboxesPerAccount[account];
  }

  Future<void> createMailbox(
      RealAccount account, String mailboxName, Mailbox? parentMailbox) async {
    final mailClient = await getClientFor(account);
    await mailClient.createMailbox(mailboxName, parentMailbox: parentMailbox);
    await loadMailboxesFor(mailClient);
  }

  Future<void> deleteMailbox(RealAccount account, Mailbox mailbox) async {
    final mailClient = await getClientFor(account);
    await mailClient.deleteMailbox(mailbox);
    await loadMailboxesFor(mailClient);
  }

  Future<void> saveAccount(MailAccount? account) {
    // print('saving account ${account.name}');
    return saveAccounts();
  }

  void markAccountAsTestedForPlusAlias(RealAccount account) {
    account.setAttribute(RealAccount.attributePlusAliasTested, true);
  }

  bool hasAccountBeenTestedForPlusAlias(RealAccount account) =>
      account.hasAttribute(RealAccount.attributePlusAliasTested);

  /// Creates a new random plus alias based on the primary email address of this account.
  String generateRandomPlusAlias(RealAccount account) {
    final mail = account.email;
    final atIndex = mail.lastIndexOf('@');
    if (atIndex == -1) {
      throw StateError(
          'unable to create alias based on invalid email <$mail>.');
    }
    final random = MessageBuilder.createRandomId(length: 8);
    return '${mail.substring(0, atIndex)}+$random${mail.substring(atIndex)}';
  }

  Sender generateRandomPlusAliasSender(Sender sender) {
    final email = generateRandomPlusAlias(sender.account);
    return Sender(MailAddress(null, email), sender.account);
  }

  Future<void> testRemoveAccount(Account account, BuildContext context) async {
    // as the original context may belong to a widget that is now disposed, use the navigator's context:
    context = locator<NavigationService>().currentContext!;
    final state = MailServiceWidget.of(context);
    if (account == currentAccount) {
      final nextAccount = hasUnifiedAccount
          ? unifiedAccount
          : accounts.isNotEmpty
              ? accounts.first
              : null;
      _currentAccount = nextAccount;
      if (nextAccount != null) {
        messageSource = await _createMessageSource(null, nextAccount);
      } else {
        messageSource = null;
        locator<NavigationService>().push(Routes.welcome, clear: true);
      }
      if (state != null) {
        state.messageSource = messageSource;
        state.account = _currentAccount;
        state.accounts = accounts;
      }
    } else if (state != null) {
      state.accounts = accounts;
    }
  }

  Future<void> removeAccount(RealAccount account, BuildContext context) async {
    accounts.remove(account);
    mailAccounts.remove(account.mailAccount);
    _mailboxesPerAccount.remove(account);
    _mailClientsPerAccount.remove(account);
    final withErrors = _accountsWithErrors;
    if (withErrors != null) {
      withErrors.remove(account);
    }
    try {
      final client = _mailClientsPerAccount[account];
      await client?.disconnect();
    } catch (e) {
      // ignore
    }
    // TODO(RV): remove usage of BuildContext
    // as the original context may belong to a widget that is now disposed, use the navigator's context:
    context = locator<NavigationService>().currentContext!;
    final state = MailServiceWidget.of(context);
    if (!account.excludeFromUnified) {
      // updates the unified account
      excludeAccountFromUnified(
        account,
        true,
        context,
        updateContext: false,
      );
    }
    if (account == currentAccount) {
      final nextAccount = hasUnifiedAccount
          ? unifiedAccount
          : accounts.isNotEmpty
              ? accounts.first
              : null;
      _currentAccount = nextAccount;
      if (nextAccount != null) {
        messageSource = await _createMessageSource(null, nextAccount);
      } else {
        messageSource = null;
        locator<NavigationService>().push(Routes.welcome, clear: true);
      }
      if (state != null) {
        state.messageSource = messageSource;
        state.account = _currentAccount;
        state.accounts = accounts;
      }
    } else if (state != null) {
      state.accounts = accounts;
    }

    await saveAccounts();
  }

  String? getEmailDomain(String email) {
    final startIndex = email.lastIndexOf('@');
    if (startIndex == -1) {
      return null;
    }
    return email.substring(startIndex + 1);
  }

  Future<MailClient?> connectAccount(MailAccount mailAccount) async {
    final mailClient = createMailClient(mailAccount);
    await _connect(mailClient);
    return mailClient;
  }

  Future<ConnectedAccount?> connectFirstTime(MailAccount mailAccount) async {
    var usedMailAccount = mailAccount;
    var mailClient = createMailClient(usedMailAccount);
    try {
      await _connect(mailClient);
    } on MailException {
      final email = usedMailAccount.email;
      var preferredUserName =
          usedMailAccount.incoming.serverConfig.getUserName(email);
      if (preferredUserName == null || preferredUserName == email) {
        final atIndex = mailAccount.email.lastIndexOf('@');
        preferredUserName = usedMailAccount.email.substring(0, atIndex);
        usedMailAccount =
            usedMailAccount.copyWithAuthenticationUserName(preferredUserName);
        mailClient.disconnect();
        mailClient = createMailClient(usedMailAccount);
        try {
          await _connect(mailClient);
        } on MailException {
          mailClient.disconnect();
          return null;
        }
      }
    }
    return ConnectedAccount(usedMailAccount, mailClient);
  }

  Future<bool> reconnect(RealAccount account) async {
    _mailClientsPerAccount.remove(account);
    final source = await getMessageSourceFor(account);
    final connected = source is! ErrorMessageSource;
    if (connected) {
      final accountsWithErrors = _accountsWithErrors;
      if (accountsWithErrors != null) {
        accountsWithErrors.remove(account);
      }
      accountsWithoutErrors.add(account);
      //TODO update unified account message source after connecting account
    }
    return connected;
  }

  /// Disconnects the mail client belonging to [account].
  Future<void> disconnect(RealAccount account) async {
    final client = await getClientFor(account);
    await client.disconnect();
  }

  MailClient createMailClient(MailAccount mailAccount) {
    bool isLogEnabled = kDebugMode ||
        (mailAccount.attributes[RealAccount.attributeEnableLogging] ?? false);
    return MailClient(
      mailAccount,
      isLogEnabled: isLogEnabled,
      logName: mailAccount.name,
      eventBus: AppEventBus.eventBus,
      clientId: _clientId,
      refresh: _refreshToken,
      onConfigChanged: saveAccount,
      downloadSizeLimit: 32 * 1024,
    );
  }

  Future<void> _connect(MailClient client) {
    return client.connect();
  }

  Future<OauthToken?> _refreshToken(
      MailClient mailClient, OauthToken expiredToken) {
    final providerId = expiredToken.provider;
    if (providerId == null) {
      throw MailException(
          mailClient, 'no provider registered for token $expiredToken');
    }
    final provider = locator<ProviderService>()[providerId];
    if (provider == null) {
      throw MailException(mailClient,
          'no provider "$providerId" found -  token: $expiredToken');
    }
    final oauthClient = provider.oauthClient;
    if (oauthClient == null || !oauthClient.isEnabled) {
      throw MailException(
          mailClient, 'provider $providerId has no valid OAuth configuration');
    }
    return oauthClient.refresh(expiredToken);
  }

  Future<MailAccount> _checkForAddingSentMessages(MailAccount mailAccount) {
    final addsSendMailAutomatically = [
      'outlook.office365.com',
      'imap.gmail.com'
    ].contains(mailAccount.incoming.serverConfig.hostname);
    return Future.value(
      mailAccount.copyWithAttribute(
        RealAccount.attributeSentMailAddedAutomatically,
        addsSendMailAutomatically,
      ),
    );
    //TODO later test sending of messages
  }

  List<MailClient> getMailClients() {
    final mailClients = <MailClient>[];
    final existingMailClients = _mailClientsPerAccount.values;
    for (final mailAccount in mailAccounts) {
      var client = existingMailClients
          .firstWhereOrNull((client) => client.account == mailAccount);
      client ??= createMailClient(mailAccount);
      mailClients.add(client);
    }
    return mailClients;
  }

  /// Checks the connection status and resumes the connection if necessary
  Future resume() {
    final futures = <Future>[];
    for (final client in _mailClientsPerAccount.values) {
      futures.add(client.resume());
    }
    if (futures.isEmpty) {
      return Future.value();
    }
    return Future.wait(futures);
  }

  Future excludeAccountFromUnified(
    RealAccount account,
    bool exclude,
    BuildContext context, {
    bool updateContext = true,
  }) async {
    account.excludeFromUnified = exclude;
    final unified = unifiedAccount;
    if (exclude) {
      if (unified != null) {
        unified.removeAccount(account);
      }
    } else {
      if (unified == null) {
        _createUnifiedAccount();
      } else {
        unified.addAccount(account);
      }
    }
    if (currentAccount == unified && unified != null) {
      messageSource = await _createMessageSource(null, unified);
      if (updateContext) {
        final state = MailServiceWidget.of(context);
        if (state != null) {
          state.messageSource = messageSource;
        }
      }
    }
    return saveAccounts();
  }

  bool hasError(Account? account) {
    final accts = _accountsWithErrors;
    return accts != null && accts.contains(account);
  }

  bool hasAccountsWithErrors() {
    final accts = _accountsWithErrors;
    return accts != null && accts.isNotEmpty;
  }

  @override
  void onMailArrived(MimeMessage mime, AsyncMimeSource source,
      {int index = 0}) {
    source.mailClient.lowLevelIncomingMailClient
        .logApp('new message: ${mime.decodeSubject()}');
    if (!mime.isSeen && source.isInbox) {
      locator<NotificationService>()
          .sendLocalNotificationForMail(mime, source.mailClient);
    }
  }

  @override
  void onMailCacheInvalidated(AsyncMimeSource source) {
    // ignore
  }

  @override
  void onMailFlagsUpdated(MimeMessage mime, AsyncMimeSource source) {
    if (mime.isSeen) {
      locator<NotificationService>().cancelNotificationForMail(mime);
    }
  }

  @override
  void onMailVanished(MimeMessage mime, AsyncMimeSource source) {
    locator<NotificationService>().cancelNotificationForMail(mime);
  }
}
