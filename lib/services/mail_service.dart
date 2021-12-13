import 'package:collection/collection.dart' show IterableExtension;
import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/events/app_event_bus.dart';
import 'package:enough_mail_app/extensions/extensions.dart';
import 'package:enough_mail_app/models/account.dart';
import 'package:enough_mail_app/models/message_source.dart';
import 'package:enough_mail_app/models/mime_source.dart';
import 'package:enough_mail_app/models/sender.dart';
import 'package:enough_mail_app/models/settings.dart';
import 'package:enough_mail_app/routes.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_mail_app/services/providers.dart';
import 'package:enough_mail_app/services/settings_service.dart';
import 'package:enough_mail_app/util/gravatar.dart';
import 'package:enough_mail_app/widgets/inherited_widgets.dart';
import 'package:enough_serialization/enough_serialization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/foundation.dart' as foundation;
import '../locator.dart';

class MailService {
  static const _clientId = const Id(name: 'Maily', version: '1.0');
  MessageSource? messageSource;
  Account? _currentAccount;
  Account? get currentAccount => _currentAccount;
  List<MailAccount> mailAccounts = <MailAccount>[];
  final accounts = <Account>[];
  UnifiedAccount? unifiedAccount;

  List<Account>? _accountsWithErrors;
  bool get hasUnifiedAccount => (unifiedAccount != null);

  static const String _keyAccounts = 'accts';
  FlutterSecureStorage? _storage;
  final _mailClientsPerAccount = <Account, MailClient>{};
  final Map<Account, Tree<Mailbox?>> _mailboxesPerAccount =
      <Account, Tree<Mailbox?>>{};
  AppLocalizations? _localizations;
  AppLocalizations? get localizations => _localizations;

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

  set localizations(AppLocalizations? value) {
    if (value != _localizations) {
      _localizations = value;
      if (unifiedAccount != null) {
        unifiedAccount!.name = value!.unifiedAccountName;
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

  Future<void> init(AppLocalizations? localizations) async {
    _localizations = localizations;
    await _loadAccounts();
    messageSource = await _initMessageSource();
  }

  Future<void> _loadAccounts() async {
    mailAccounts = await loadMailAccounts();
    for (var mailAccount in mailAccounts) {
      accounts.add(Account(mailAccount));
    }
    _createUnifiedAccount();
  }

  Future<List<MailAccount>> loadMailAccounts() async {
    _storage ??= FlutterSecureStorage();
    var json = await _storage!.read(key: _keyAccounts);
    if (json != null) {
      final accounts = <MailAccount>[];
      Serializer().deserializeList(json, accounts,
          (map) => MailAccount()..addExtensionSerializationConfiguration());
      return accounts;
    }
    return <MailAccount>[];
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
    final mailAccountsForUnified = accounts
        .where((account) => (!account.isVirtual &&
            !account.account.hasAttribute(Account.attributeExcludeFromUnified)))
        .toList();
    if (mailAccountsForUnified.length > 1) {
      unifiedAccount = UnifiedAccount(
          mailAccountsForUnified, _localizations!.unifiedAccountName);
      final mailboxes = [
        Mailbox()
          ..name = _localizations!.unifiedFolderInbox
          ..flags = [MailboxFlag.inbox],
        Mailbox()
          ..name = _localizations!.unifiedFolderDrafts
          ..flags = [MailboxFlag.drafts],
        Mailbox()
          ..name = _localizations!.unifiedFolderSent
          ..flags = [MailboxFlag.sent],
        Mailbox()
          ..name = _localizations!.unifiedFolderTrash
          ..flags = [MailboxFlag.trash],
        Mailbox()
          ..name = _localizations!.unifiedFolderArchive
          ..flags = [MailboxFlag.archive],
        Mailbox()
          ..name = _localizations!.unifiedFolderJunk
          ..flags = [MailboxFlag.junk],
      ];
      final tree = Tree<Mailbox?>(Mailbox())
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
      Mailbox? mailbox, Account account) async {
    if (account is UnifiedAccount) {
      final mimeSources = await _getUnifiedMimeSources(mailbox, account);
      return MultipleMessageSource(
        mimeSources,
        mailbox == null ? _localizations!.unifiedFolderInbox : mailbox.name,
        mailbox?.flags.first ?? MailboxFlag.inbox,
      );
    } else {
      final mailClient = await _getClientAndStopPolling(account);
      if (mailClient != null) {
        return MailboxMessageSource(mailbox, mailClient);
      }
      _accountsWithErrors ??= <Account>[];
      _accountsWithErrors!.add(account);
      return ErrorMessageSource(account);
    }
  }

  Future<List<MimeSource>> _getUnifiedMimeSources(
      Mailbox? mailbox, UnifiedAccount unifiedAccount) async {
    final futures = <Future<MailClient?>>[];
    final mimeSources = <MimeSource>[];
    final flag = mailbox?.flags.first;
    for (final subAccount in unifiedAccount.accounts) {
      futures.add(_getClientAndStopPolling(subAccount));
    }
    final clients = await Future.wait(futures);
    for (var i = 0; i < clients.length; i++) {
      final client = clients[i];
      if (client != null) {
        Mailbox? accountMailbox;
        if (flag != null) {
          accountMailbox = client.getMailbox(flag);
          if (accountMailbox == null) {
            print(
                'unable to find mailbox with $flag in account ${client.account.name}');
            continue;
          }
        }
        mimeSources.add(MailboxMimeSource(client, accountMailbox));
      } else {
        _accountsWithErrors ??= <Account>[];
        _accountsWithErrors!.add(unifiedAccount.accounts[i]);
      }
    }
    return mimeSources;
  }

  Future<MailClient?> _getClientAndStopPolling(Account account) async {
    try {
      final client = await getClientFor(account);
      await client.stopPollingIfNeeded();
      return client;
    } catch (e, s) {
      print('Unable to get client for ${account.email}: $e $s');
      return null;
    }
  }

  void _addGravatar(MailAccount account) {
    final url = Gravatar.imageUrl(
      account.email!,
      size: 400,
      defaultImage: GravatarImage.retro,
    );
    account.attributes[Account.attributeGravatarImageUrl] = url;
  }

  Future<bool> addAccount(MailAccount mailAccount, MailClient mailClient,
      BuildContext context) async {
    //TODO check if other account with the same name already exists
    //TODO how to save extension data?
    final existing = mailAccounts
        .firstWhereOrNull((account) => account.email == mailAccount.email);
    if (existing != null) {
      final account = accounts
          .firstWhereOrNull((account) => account.email == mailAccount.email);
      if (account != null) {
        removeAccount(account, context);
      }
    }
    final newAccount = Account(mailAccount);

    _currentAccount = newAccount;
    accounts.add(newAccount);
    await loadMailboxesFor(mailClient);
    _mailClientsPerAccount[newAccount] = mailClient;
    await _checkForAddingSentMessages(mailAccount);
    _addGravatar(mailAccount);
    mailAccounts.add(mailAccount);
    if (!mailAccount.hasAttribute(Account.attributeExcludeFromUnified)) {
      final unified = unifiedAccount;
      if (unified != null) {
        unified.accounts.add(newAccount);
      } else {
        _createUnifiedAccount();
      }
    }
    final source = await getMessageSourceFor(newAccount);
    messageSource = source;
    final state = MailServiceWidget.of(context);
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
      if (account.isVirtual) {
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

  Future<void> reorderAccounts(List<Account> newOrder) {
    accounts.clear();
    accounts.addAll(newOrder);
    final newOrderMailAccounts = newOrder.map((a) => a.account).toList();
    mailAccounts = newOrderMailAccounts;
    return saveAccounts();
  }

  Future<void> saveAccounts() {
    final json = Serializer().serializeList(mailAccounts);
    // print(json);
    _storage ??= FlutterSecureStorage();
    return _storage!.write(key: _keyAccounts, value: json);
  }

  Future<MailClient> getClientFor(
    Account account, {
    bool connectIfRequired = true,
  }) async {
    if (account is UnifiedAccount) {
      account = account.accounts.first;
    }
    var client = _mailClientsPerAccount[account];
    if (client == null) {
      if (!connectIfRequired) {
        throw StateError('No MailClient conected for account ${account.name}');
      }
      client = createMailClient(account.account);
      _mailClientsPerAccount[account] = client;
      await _connect(client);
      await loadMailboxesFor(client);
    }
    return client;
  }

  Future<MailClient> getClientForAccountWithEmail(String? accountEmail) {
    final account = getAccountForEmail(accountEmail)!;
    return getClientFor(account);
  }

  Future<MessageSource> getMessageSourceFor(Account account,
      {Mailbox? mailbox, bool switchToAccount = false}) async {
    var source = await _createMessageSource(mailbox, account);
    if (switchToAccount) {
      messageSource = source;
      _currentAccount = account;
    }
    return source;
  }

  Account? getAccountFor(MailAccount mailAccount) {
    return accounts.firstWhereOrNull((a) => a.account == mailAccount);
  }

  Account? getAccountForEmail(String? accountEmail) {
    return accounts.firstWhereOrNull((a) => a.email == accountEmail);
  }

  void applyFolderNameSettings(Settings settings) {
    for (final client in _mailClientsPerAccount.values) {
      _setMaiboxNames(settings, client);
    }
  }

  void _setMaiboxNames(Settings settings, MailClient client) {
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
        final l = localizations!;
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
      print('Unable to find account for ${client.account}');
      return;
    }
    final mailboxTree =
        await client.listMailboxesAsTree(createIntermediate: false);
    final settings = locator<SettingsService>().settings;
    if (settings.folderNameSetting != FolderNameSetting.server) {
      _setMaiboxNames(settings, client);
    }

    _mailboxesPerAccount[account] = mailboxTree;
  }

  Tree<Mailbox?>? getMailboxTreeFor(Account account) {
    return _mailboxesPerAccount[account];
  }

  Future<void> createMailbox(
      Account account, String mailboxName, Mailbox? parentMailbox) async {
    final mailClient = await getClientFor(account);
    await mailClient.createMailbox(mailboxName, parentMailbox: parentMailbox);
    await loadMailboxesFor(mailClient);
  }

  Future<void> deleteMailbox(Account account, Mailbox mailbox) async {
    final mailClient = await getClientFor(account);
    await mailClient.deleteMailbox(mailbox);
    await loadMailboxesFor(mailClient);
  }

  Future<void> saveAccount(MailAccount? account) {
    // print('saving account ${account.name}');
    return saveAccounts();
  }

  void markAccountAsTestedForPlusAlias(Account account) {
    account.account.attributes[Account.attributePlusAliasTested] = true;
  }

  bool hasAccountBeenTestedForPlusAlias(Account account) {
    return account.account.attributes[Account.attributePlusAliasTested] ??
        false;
  }

  /// Creates a new random plus alias based on the primary email address of this account.
  String generateRandomPlusAlias(Account account) {
    final mail = account.email;
    final atIndex = mail.lastIndexOf('@');
    if (atIndex == -1) {
      throw StateError(
          'unable to create alias based on invalid email <$mail>.');
    }
    final random = MessageBuilder.createRandomId(length: 8);
    return mail.substring(0, atIndex) + '+' + random + mail.substring(atIndex);
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

  Future<void> removeAccount(Account account, BuildContext context) async {
    accounts.remove(account);
    mailAccounts.remove(account.account);
    _mailboxesPerAccount.remove(account);
    _mailClientsPerAccount.remove(account);
    final withErrors = _accountsWithErrors;
    if (withErrors != null) {
      withErrors.remove(account);
    }
    try {
      final client = await getClientFor(account, connectIfRequired: false);
      await client.disconnect();
    } catch (e) {
      // ignore
    }
    // as the original context may belong to a widget that is now disposed, use the navigator's context:
    context = locator<NavigationService>().currentContext!;
    if (!account.excludeFromUnified) {
      // updates the unified account
      excludeAccountFromUnified(account, true, context, updateContext: false);
    }
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

    await saveAccounts();
  }

  String? getEmailDomain(String email) {
    final startIndex = email.lastIndexOf('@');
    if (startIndex == -1) {
      return null;
    }
    return email.substring(startIndex + 1);
  }

  Future<MailClient?> connect(MailAccount mailAccount) async {
    var mailClient = createMailClient(mailAccount);
    try {
      await _connect(mailClient);
    } on MailException {
      final email = mailAccount.email!;
      var preferredUserName =
          mailAccount.incoming?.serverConfig?.getUserName(email);
      if (preferredUserName == null || preferredUserName == email) {
        final atIndex = mailAccount.email!.lastIndexOf('@');
        preferredUserName = mailAccount.email!.substring(0, atIndex);
        final incomingAuth = mailAccount.incoming!.authentication;
        if (incomingAuth is UserNameBasedAuthentication) {
          incomingAuth.userName = preferredUserName;
        }
        final outgoingAuth = mailAccount.outgoing!.authentication;
        if (outgoingAuth is UserNameBasedAuthentication) {
          outgoingAuth.userName = preferredUserName;
        }
        mailClient.disconnect();
        mailClient = createMailClient(mailAccount);
        try {
          await _connect(mailClient);
        } on MailException {
          mailClient.disconnect();
          return null;
        }
      }
    }
    return mailClient;
  }

  MailClient createMailClient(MailAccount mailAccount,
      {bool isLogEnabled = foundation.kDebugMode}) {
    return MailClient(
      mailAccount,
      isLogEnabled: isLogEnabled,
      logName: mailAccount.name,
      eventBus: AppEventBus.eventBus,
      clientId: _clientId,
      refresh: _refreshToken,
      onConfigChanged: saveAccount,
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

  Future _checkForAddingSentMessages(MailAccount mailAccount) async {
    mailAccount.attributes[Account.attributeSentMailAddedAutomatically] = [
      'outlook.office365.com',
      'imap.gmail.com'
    ].contains(mailAccount.incoming!.serverConfig!.hostname);
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
      Account account, bool exclude, BuildContext context,
      {bool updateContext = true}) async {
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
}
