import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/events/account_change_event.dart';
import 'package:enough_mail_app/events/accounts_changed_event.dart';
import 'package:enough_mail_app/events/app_event_bus.dart';
import 'package:enough_mail_app/events/unified_messagesource_changed_event.dart';
import 'package:enough_mail_app/models/account.dart';
import 'package:enough_mail_app/models/message_source.dart';
import 'package:enough_mail_app/models/mime_source.dart';
import 'package:enough_mail_app/models/sender.dart';
import 'package:enough_mail_app/services/settings_service.dart';
import 'package:enough_mail_app/util/gravatar.dart';
import 'package:enough_serialization/enough_serialization.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/foundation.dart' as foundation;
import '../locator.dart';

class MailService {
  static const String attributeGravatarImageUrl = 'gravatar.img';
  static const String attributeExcludeFromUnified = 'excludeUnified';
  static const String attributePlusAliasTested = 'test.alias.plus';
  static const String attributeSentMailAddedAutomatically = 'sendMailAdded';
  //MailClient current;
  MessageSource messageSource;
  Account currentAccount;
  List<MailAccount> mailAccounts = <MailAccount>[];
  final accounts = <Account>[];
  UnifiedAccount unifiedAccount;
  bool get hasUnifiedAccount => (unifiedAccount != null);

  static const String _keyAccounts = 'accts';
  FlutterSecureStorage _storage;
  final _mailClientsPerAccount = <Account, MailClient>{};
  final _mailboxesPerAccount = <Account, Tree<Mailbox>>{};
  AppLocalizations _localizations;
  AppLocalizations get localizations => _localizations;
  set localizations(AppLocalizations value) {
    if (value != _localizations) {
      _localizations = value;
      if (unifiedAccount != null) {
        unifiedAccount.name = value.unifiedAccountName;
        final mailboxes = _mailboxesPerAccount[unifiedAccount]
            .root
            .children
            .map((c) => c.value);
        for (final mailbox in mailboxes) {
          String name;
          if (mailbox.isInbox) {
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
    var json = await _storage.read(key: _keyAccounts);
    if (json != null) {
      final accounts = <MailAccount>[];
      Serializer().deserializeList(json, accounts, (map) => MailAccount());
      return accounts;
    }
    return <MailAccount>[];
  }

  Future<MessageSource> search(MailSearch search) async {
    final currentSource = messageSource;
    if (currentSource != null && currentSource.supportsSearching) {
      return currentSource.search(search);
    }
    final account = currentAccount != null
        ? currentAccount
        : (unifiedAccount != null)
            ? unifiedAccount
            : mailAccounts.first;
    currentAccount = account;
    messageSource = await _createMessageSource(null, account);
    return messageSource.search(search);
  }

  _createUnifiedAccount() {
    final mailAccountsForUnified = accounts
        .where((account) => (!account.isVirtual &&
            !account.account.hasAttribute(attributeExcludeFromUnified)))
        .toList();
    if (mailAccountsForUnified.length > 1) {
      unifiedAccount = UnifiedAccount(
          mailAccountsForUnified, _localizations.unifiedAccountName);
      final mailboxes = [
        Mailbox()
          ..name = _localizations.unifiedFolderInbox
          ..flags = [MailboxFlag.inbox],
        Mailbox()
          ..name = _localizations.unifiedFolderDrafts
          ..flags = [MailboxFlag.drafts],
        Mailbox()
          ..name = _localizations.unifiedFolderSent
          ..flags = [MailboxFlag.sent],
        Mailbox()
          ..name = _localizations.unifiedFolderTrash
          ..flags = [MailboxFlag.trash],
        Mailbox()
          ..name = _localizations.unifiedFolderArchive
          ..flags = [MailboxFlag.archive],
        Mailbox()
          ..name = _localizations.unifiedFolderJunk
          ..flags = [MailboxFlag.junk],
      ];
      final tree = Tree<Mailbox>(Mailbox())
        ..populateFromList(mailboxes, (child) => null);
      _mailboxesPerAccount[unifiedAccount] = tree;
    }
  }

  Future<MessageSource> _initMessageSource() {
    if (unifiedAccount != null) {
      currentAccount = unifiedAccount;
    } else if (accounts.isNotEmpty) {
      currentAccount = accounts.first;
    }
    if (currentAccount != null) {
      return _createMessageSource(null, currentAccount);
    }
    return null;
  }

  Future<MessageSource> _createMessageSource(
      Mailbox mailbox, Account account) async {
    if (account is UnifiedAccount) {
      final mimeSources = await _getUnifiedMimeSources(mailbox, account);
      return MultipleMessageSource(
        mimeSources,
        mailbox == null ? _localizations.unifiedFolderInbox : mailbox.name,
        mailbox?.flags?.first ?? MailboxFlag.inbox,
      );
    } else {
      var mailClient = await getClientFor(account);
      await mailClient.stopPollingIfNeeded();
      return MailboxMessageSource(mailbox, mailClient);
    }
  }

  Future<List<MimeSource>> _getUnifiedMimeSources(
      Mailbox mailbox, UnifiedAccount unifiedAccount) async {
    final futures = <Future>[];
    final mimeSources = <MimeSource>[];
    MailboxFlag flag = mailbox?.flags?.first;
    for (final subAccount in unifiedAccount.accounts) {
      futures.add(_getClientAndStopPolling(subAccount));
    }
    final clients = await Future.wait(futures);
    for (final client in clients) {
      Mailbox accountMailbox;
      if (flag != null) {
        accountMailbox = client.getMailbox(flag);
        if (accountMailbox == null) {
          print(
              'unable to find mailbox with $flag in account ${client.account.name}');
          continue;
        }
      }
      mimeSources.add(MailboxMimeSource(client, accountMailbox));
    }
    return mimeSources;
  }

  Future<MailClient> _getClientAndStopPolling(Account account) async {
    final client = await getClientFor(account);
    await client.stopPollingIfNeeded();
    return client;
  }

  void _addGravatar(MailAccount account) {
    final url = Gravatar.imageUrl(
      account.email,
      size: 400,
      defaultImage: GravatarImage.retro,
    );
    account.attributes[attributeGravatarImageUrl] = url;
  }

  Future<bool> addAccount(
      MailAccount mailAccount, MailClient mailClient) async {
    currentAccount = Account(mailAccount);
    accounts.add(currentAccount);
    await loadMailboxesFor(mailClient);
    _mailClientsPerAccount[currentAccount] = mailClient;
    await _checkForAddingSentMessages(mailAccount);
    _addGravatar(mailAccount);
    mailAccounts.add(mailAccount);
    if (!mailAccount.hasAttribute(attributeExcludeFromUnified)) {
      if (unifiedAccount != null) {
        unifiedAccount.accounts.add(currentAccount);
      } else {
        _createUnifiedAccount();
      }
    }
    final source = await getMessageSourceFor(currentAccount);
    messageSource = source;
    AppEventBus.eventBus.fire(AccountChangeEvent(mailClient, mailAccount));
    await saveAccounts();
    return true;
  }

  List<Sender> getSenders({bool includePlaceholdersForPlusAliases = true}) {
    final senders = <Sender>[];
    for (final account in accounts) {
      if (account.isVirtual) {
        continue;
      }
      senders.add(Sender(account.fromAddress, account));
      if (account.aliases != null) {
        for (final alias in account.aliases) {
          senders.add(Sender(alias, account));
        }
      }
      if (includePlaceholdersForPlusAliases) {
        if (account.supportsPlusAliases ||
            !hasAccountBeenTestedForPlusAlias(account)) {
          senders.add(Sender(null, account, isPlaceHolderForPlusAlias: true));
        }
      }
    }
    return senders;
  }

  MessageBuilder mailto(Uri mailto, MimeMessage originatingMessage) {
    final senders = getSenders(includePlaceholdersForPlusAliases: false);
    final searchFor = senders.map((s) => s.address).toList();
    final searchIn = originatingMessage.recipientAddresses
        .map((email) => MailAddress('', email))
        .toList();
    var fromAddress = MailAddress.getMatch(searchFor, searchIn);
    if (fromAddress == null) {
      final settings = locator<SettingsService>().settings;
      if (settings.preferredComposeMailAddress != null) {
        fromAddress = searchFor.firstWhere(
            (address) => address.email == settings.preferredComposeMailAddress,
            orElse: () => null);
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
    AppEventBus.eventBus.fire(AccountsChangedEvent());
    final json = Serializer().serializeList(mailAccounts);
    // print(json);
    _storage ??= FlutterSecureStorage();
    return _storage.write(key: _keyAccounts, value: json);
  }

  Future<MailClient> getClientFor(Account account) async {
    var client = _mailClientsPerAccount[account];
    if (client == null) {
      client = MailClient(account.account,
          eventBus: AppEventBus.eventBus,
          isLogEnabled:
              foundation.kDebugMode, // enable log only for debug  mode
          logName: account.account.name);
      _mailClientsPerAccount[account] = client;
      await client.connect();
      await loadMailboxesFor(client);
    }
    return client;
  }

  Future<MailClient> getClientForAccountWithEmail(String accountEmail) {
    final account = getAccountForEmail(accountEmail);
    return getClientFor(account);
  }

  Future<MessageSource> getMessageSourceFor(Account account,
      {Mailbox mailbox, bool switchToAccount}) async {
    var source = await _createMessageSource(mailbox, account);
    if (switchToAccount == true) {
      messageSource = source;
      currentAccount = account;
    }
    return source;
  }

  Account getAccountFor(MailAccount mailAccount) {
    return accounts.firstWhere((a) => a.account == mailAccount,
        orElse: () => null);
  }

  Account getAccountForEmail(String accountEmail) {
    return accounts.firstWhere((a) => a.email == accountEmail,
        orElse: () => null);
  }

  Future<void> loadMailboxesFor(MailClient client) async {
    final account = getAccountFor(client.account);
    if (account == null) {
      print('Unable to find account for ${client.account}');
      return;
    }
    final mailboxTree =
        await client.listMailboxesAsTree(createIntermediate: false);
    _mailboxesPerAccount[account] = mailboxTree;
  }

  Tree<Mailbox> getMailboxTreeFor(Account account) {
    return _mailboxesPerAccount[account];
  }

  Future<void> saveAccount(MailAccount account) {
    // print('saving account ${account.name}');
    return saveAccounts();
  }

  void markAccountAsTestedForPlusAlias(Account account) {
    account.account.attributes[attributePlusAliasTested] = true;
  }

  bool hasAccountBeenTestedForPlusAlias(Account account) {
    return account?.account?.attributes[attributePlusAliasTested] ?? false;
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

  Future<void> removeAccount(Account account) async {
    accounts.remove(account);
    mailAccounts.remove(account.account);
    _mailboxesPerAccount[account] = null;
    _mailClientsPerAccount[account] = null;
    // TODO handle the case when an account is removed that is used in the current mail source
    // if (current?.account == account) {
    //   await current.disconnect();
    //   if (accounts.isNotEmpty) {
    //     current = await getClientFor(accounts.first);
    //   } else {
    //     current = null;
    //   }
    // }
    await saveAccounts();
  }

  String getEmailDomain(String email) {
    final startIndex = email.lastIndexOf('@');
    if (startIndex == -1) {
      return null;
    }
    return email.substring(startIndex + 1);
  }

  Future<MailClient> connect(MailAccount mailAccount) async {
    var mailClient = MailClient(mailAccount,
        isLogEnabled: true, eventBus: AppEventBus.eventBus);
    try {
      await mailClient.connect();
    } on MailException {
      var preferredUserName =
          mailAccount.incoming.serverConfig.getUserName(mailAccount.userName);
      if (preferredUserName == null || preferredUserName == mailAccount.email) {
        final atIndex = mailAccount.email.lastIndexOf('@');
        preferredUserName = mailAccount.email.substring(0, atIndex);
        final incomingAuth = mailAccount.incoming.authentication;
        if (incomingAuth is PlainAuthentication) {
          incomingAuth.userName = preferredUserName;
        }
        final outgoingAuth = mailAccount.outgoing.authentication;
        if (outgoingAuth is PlainAuthentication) {
          outgoingAuth.userName = preferredUserName;
        }
        mailClient = MailClient(mailAccount,
            isLogEnabled: true, eventBus: AppEventBus.eventBus);
        try {
          await mailClient.connect();
        } on MailException {
          return null;
        }
      }
    }
    return mailClient;
  }

  Future _checkForAddingSentMessages(MailAccount mailAccount) async {
    mailAccount.attributes[attributeSentMailAddedAutomatically] = [
      'outlook.office365.com',
      'imap.gmail.com'
    ].contains(mailAccount.incoming.serverConfig.hostname);
    //TODO later test sending of messages
  }

  List<MailClient> getMailClients() {
    final mailClients = <MailClient>[];
    final existingMailClients = _mailClientsPerAccount.values;
    for (final mailAccount in mailAccounts) {
      var client = existingMailClients.firstWhere(
          (client) => client.account == mailAccount,
          orElse: () => null);
      client ??= MailClient(mailAccount);
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
    return Future.wait(futures);
  }

  Future excludeAccountFromUnified(Account account, bool exclude) async {
    account.excludeFromUnified = exclude;
    if (exclude) {
      if (unifiedAccount != null) {
        unifiedAccount.removeAccount(account);
      }
    } else {
      if (unifiedAccount == null) {
        _createUnifiedAccount();
      } else {
        unifiedAccount.addAccount(account);
      }
    }
    if (currentAccount == unifiedAccount) {
      messageSource = await _createMessageSource(null, unifiedAccount);
      AppEventBus.eventBus
          .fire(UnifiedMessageSourceChangedEvent(messageSource));
    }
    return saveAccounts();
  }
}
