import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart' as url_launcher;

import 'package:enough_mail_app/locator.dart';
import 'package:enough_mail_app/services/mail_service.dart';
import 'package:enough_mail_app/widgets/inherited_widgets.dart';

import 'account.dart';
import 'message_source.dart';

class Message extends ChangeNotifier {
  Message(this.mimeMessage, this.mailClient, this.source, this.sourceIndex);

  Message.embedded(this.mimeMessage, Message parent)
      : mailClient = parent.mailClient,
        source = SingleMessageSource(parent.source),
        sourceIndex = 0 {
    (source as SingleMessageSource).singleMessage = this;
    isEmbedded = true;
  }

  static const String keywordFlagUnsubscribed = r'$Unsubscribed';

  MimeMessage mimeMessage;
  final MailClient mailClient;
  int sourceIndex;
  final MessageSource source;

  bool _isSelected = false;
  bool get isSelected => _isSelected;

  List<ContentInfo>? _attachments;
  List<ContentInfo> get attachments {
    var infos = _attachments;
    if (infos == null) {
      infos = mimeMessage.findContentInfo();
      final inlineAttachments = mimeMessage
          .findContentInfo(disposition: ContentDisposition.inline)
          .where((info) =>
              info.fetchId.isNotEmpty &&
              !(info.isText ||
                  info.isImage ||
                  info.mediaType?.sub ==
                      MediaSubtype.messageDispositionNotification));
      infos.addAll(inlineAttachments);
      _attachments = infos;
    }
    return infos;
  }

  RealAccount get account =>
      locator<MailService>().getAccountFor(mailClient.account)!;

  set isSelected(bool value) {
    if (value != _isSelected) {
      _isSelected = value;
      notifyListeners();
    }
  }

  bool isEmbedded = false;

  bool get hasNext => sourceIndex < source.size;
  Future<Message?> get next => source.next(this);
  bool get hasPrevious => (sourceIndex > 0);
  Future<Message?> get previous => source.previous(this);

  bool get isSeen => mimeMessage.isSeen;
  set isSeen(bool value) {
    if (value != mimeMessage.isSeen) {
      mimeMessage.isSeen = value;
      notifyListeners();
    }
  }

  bool get isFlagged => mimeMessage.isFlagged;
  set isFlagged(bool value) {
    if (value != mimeMessage.isFlagged) {
      mimeMessage.isFlagged = value;
      notifyListeners();
    }
  }

  bool get isAnswered => mimeMessage.isAnswered;
  set isAnswered(bool value) {
    if (value != mimeMessage.isAnswered) {
      mimeMessage.isAnswered = value;
      notifyListeners();
    }
  }

  bool get isForwarded => mimeMessage.isForwarded;
  set isForwarded(bool value) {
    if (value != mimeMessage.isForwarded) {
      mimeMessage.isForwarded = value;
      notifyListeners();
    }
  }

  bool get isDeleted => mimeMessage.isDeleted;
  set isDeleted(bool value) {
    if (value != mimeMessage.isDeleted) {
      mimeMessage.isDeleted = value;
      notifyListeners();
    }
  }

  bool get isMdnSent => mimeMessage.isReadReceiptSent;
  set isMdnSent(bool value) {
    if (value != mimeMessage.isReadReceiptSent) {
      mimeMessage.isReadReceiptSent = value;
      notifyListeners();
    }
  }

  bool get isNewsLetter => mimeMessage.isNewsletter;

  bool get isNewsLetterSubscribable => mimeMessage.isNewsLetterSubscribable;

  bool get isNewsletterUnsubscribed =>
      mimeMessage.hasFlag(keywordFlagUnsubscribed);
  set isNewsletterUnsubscribed(bool value) {
    mimeMessage.setFlag(keywordFlagUnsubscribed, value);
    notifyListeners();
  }

  bool get hasAttachment {
    final mime = mimeMessage;
    final size = mime.size;
    // when only the envelope is downloaded, the content-type header ergo mediaType is not yet available
    return mime.hasAttachments() ||
        (mime.mimeData == null &&
            mime.body == null &&
            size != null &&
            size > 256 * 1024);
  }

  void updateFlags(List<String>? flags) {
    mimeMessage.flags = flags;
    notifyListeners();
  }

  void updateMime(MimeMessage mime) {
    mimeMessage = mime;
    _attachments = null;
    notifyListeners();
  }

  void toggleSelected() {
    isSelected = !_isSelected;
  }

  static Message? of(BuildContext context) =>
      MessageWidget.of(context)?.message;

  @override
  String toString() {
    return '${mailClient.account.name}[$sourceIndex]=$mimeMessage';
  }
}

extension NewsLetter on MimeMessage {
  bool get isEmpty => (mimeData == null && envelope == null && body == null);

  /// Checks if this is a newsletter with a `list-unsubscribe` header.
  bool get isNewsletter => hasHeader('list-unsubscribe');

  /// Checks if this is a newsletter with a `list-subscribe` header.
  bool get isNewsLetterSubscribable => hasHeader('list-subscribe');

  /// Retrieves the List-Unsubscribe URIs, if present
  List<Uri?>? decodeListUnsubscribeUris() {
    return _decodeUris('list-unsubscribe');
  }

  List<Uri?>? decodeListSubscribeUris() {
    return _decodeUris('list-subscribe');
  }

  String? decodeListName() {
    final listPost = decodeHeaderValue('list-post');
    if (listPost != null) {
      // typically only mailing lists that allow posting have a human understandable List-ID header:
      final id = decodeHeaderValue('list-id');
      if (id != null && id.isNotEmpty) {
        return id;
      }
      final startIndex = listPost.indexOf('<mailto:');
      if (startIndex != -1) {
        final endIndex = listPost.indexOf('>', startIndex + '<mailto:'.length);
        if (endIndex != -1) {
          return listPost.substring(startIndex + '<mailto:'.length, endIndex);
        }
      }
    }
    final sender = decodeSender();
    if (sender.isNotEmpty) {
      return sender.first.toString();
    }
    return null;
  }

  List<Uri?>? _decodeUris(final String name) {
    final value = getHeaderValue(name);
    if (value == null) {
      return null;
    }
    //TODO allow comments in / before URIs, e.g. "(send a mail to unsubscribe) <mailto:unsubscribe@list.org>"
    final uris = <Uri?>[];
    final parts = value.split('>');
    for (var part in parts) {
      part = part.trimLeft();
      if (part.startsWith(',')) {
        part = part.substring(1).trimLeft();
      }
      if (part.startsWith('<')) {
        part = part.substring(1);
      }
      if (part.isNotEmpty) {
        final uri = Uri.tryParse(part);
        if (uri == null) {
          if (kDebugMode) {
            print('Invalid $name $value: unable to pars URI $part');
          }
        } else {
          uris.add(uri);
        }
      }
    }
    return uris;
  }

  bool hasListUnsubscribePostHeader() {
    return hasHeader('list-unsubscribe-post');
  }

  Future<bool> unsubscribe(MailClient client) async {
    final uris = decodeListUnsubscribeUris();
    if (uris == null) {
      return false;
    }
    final httpUri = uris.firstWhere(
        (uri) => uri!.scheme.toLowerCase() == 'https',
        orElse: () => uris.firstWhere(
            (uri) => uri!.scheme.toLowerCase() == 'http',
            orElse: () => null));
    // unsubscribe via one click POST request: https://tools.ietf.org/html/rfc8058
    if (hasListUnsubscribePostHeader() && httpUri != null) {
      var response = await unsubscribeWithOneClick(httpUri);
      if (response.statusCode == 200) {
        return true;
      }
    }
    // unsubscribe via generated mail:
    final mailtoUri = uris.firstWhere(
        (uri) => uri!.scheme.toLowerCase() == 'mailto',
        orElse: () => null);
    if (mailtoUri != null) {
      await sendMailto(mailtoUri, client, 'unsubscribe');
      return true;
    }
    // manually open unsubscribe web page:
    if (httpUri != null) {
      return url_launcher.launchUrl(httpUri);
    }
    return false;
  }

  Future<bool> subscribe(MailClient client) async {
    final uris = decodeListSubscribeUris();
    if (uris == null) {
      return false;
    }
    // subscribe via generated mail:
    final mailtoUri = uris.firstWhere(
        (uri) => uri!.scheme.toLowerCase() == 'mailto',
        orElse: () => null);
    if (mailtoUri != null) {
      await sendMailto(mailtoUri, client, 'subscribe');
      return true;
    }
    // manually open subscribe web page:
    final httpUri = uris.firstWhere(
        (uri) => uri!.scheme.toLowerCase() == 'https',
        orElse: () => uris.firstWhere(
            (uri) => uri!.scheme.toLowerCase() == 'http',
            orElse: () => null));
    if (httpUri != null) {
      return url_launcher.launchUrl(httpUri);
    }
    return false;
  }

  Future<http.StreamedResponse> unsubscribeWithOneClick(Uri uri) {
    var request = http.MultipartRequest('POST', uri)
      ..fields['List-Unsubscribe'] = 'One-Click';
    return request.send();
  }

  Future<void> sendMailto(
      Uri mailtoUri, MailClient client, String defaultSubject) {
    final account = client.account;
    var me = findRecipient(account.fromAddress,
        aliases: account.aliases,
        allowPlusAliases: account.supportsPlusAliases);
    me ??= account.fromAddress;
    final builder = MessageBuilder.prepareMailtoBasedMessage(mailtoUri, me);
    builder.subject ??= defaultSubject;
    builder.text ??= defaultSubject;
    final message = builder.buildMimeMessage();
    return client.sendMessage(message, appendToSent: false);
  }
}

class DisplayMessageArguments {
  final Message message;
  final bool blockExternalContent;

  const DisplayMessageArguments(this.message, this.blockExternalContent);
}
