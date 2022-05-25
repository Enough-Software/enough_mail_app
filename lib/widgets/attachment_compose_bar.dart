import 'package:enough_giphy_flutter/enough_giphy_flutter.dart';
import 'package:enough_icalendar/enough_icalendar.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:enough_mail_app/models/compose_data.dart';
import 'package:enough_mail_app/models/message.dart';
import 'package:enough_mail_app/routes.dart';
import 'package:enough_mail_app/services/i18n_service.dart';
import 'package:enough_mail_app/services/icon_service.dart';
import 'package:enough_mail_app/services/navigation_service.dart';
import 'package:enough_mail_app/services/theme_service.dart';
import 'package:enough_mail_app/services/key_service.dart';
import 'package:enough_mail_app/util/http_helper.dart';
import 'package:enough_mail_app/util/localized_dialog_helper.dart';
import 'package:enough_mail_app/widgets/ical_composer.dart';
import 'package:enough_mail_app/widgets/icon_text.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:enough_media/enough_media.dart';
import '../l10n/app_localizations.g.dart';
import '../locator.dart';

class AttachmentMediaProviderFactory {
  static MediaProvider fromAttachmentInfo(AttachmentInfo info) {
    return MemoryMediaProvider(info.name!, info.mediaType.text, info.data!);
  }
}

class AttachmentComposeBar extends StatefulWidget {
  const AttachmentComposeBar(
      {Key? key, required this.composeData, this.isDownloading = false})
      : super(key: key);
  final ComposeData composeData;
  final bool isDownloading;

  @override
  State<AttachmentComposeBar> createState() => _AttachmentComposeBarState();
}

class _AttachmentComposeBarState extends State<AttachmentComposeBar> {
  late List<AttachmentInfo> _attachments;

  @override
  void initState() {
    _attachments = widget.composeData.messageBuilder.attachments;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final localizations = AppLocalizations.of(context);
    return Wrap(
      children: [
        for (final attachment in _attachments)
          ComposeAttachment(
            attachment: attachment,
            onRemove: removeAttachment,
          ),

        if (widget.isDownloading) const PlatformProgressIndicator(),

        AddAttachmentPopupButton(
          composeData: widget.composeData,
          update: () => setState(() {}),
        ),
        // ActionChip(
        //   avatar: Icon(Icons.add),
        //   visualDensity: VisualDensity.compact,
        //   label: Text(localizations.composeAddAttachmentAction),
        //   onPressed: addAttachment,
        // ),
      ],
    );
  }

  void removeAttachment(AttachmentInfo attachment) {
    widget.composeData.messageBuilder.removeAttachment(attachment);
    setState(() {
      _attachments.remove(attachment);
    });
  }
}

class AddAttachmentPopupButton extends StatelessWidget {
  final ComposeData composeData;
  final Function() update;
  const AddAttachmentPopupButton(
      {Key? key, required this.composeData, required this.update})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final iconService = locator<IconService>();
    final themeService = locator<ThemeService>();
    final brightness = themeService.brightness(context);
    return PlatformPopupMenuButton<int>(
      icon: Icon(CommonPlatformIcons.add),
      itemBuilder: (context) => [
        PlatformPopupMenuItem(
          value: 0,
          child: IconText(
            icon: Icon(iconService.mediaFile),
            label: Text(localizations.attachTypeFile),
            brightness: brightness,
          ),
        ),
        PlatformPopupMenuItem(
          value: 1,
          child: IconText(
            icon: Icon(iconService.mediaPhoto),
            label: Text(localizations.attachTypePhoto),
            brightness: brightness,
          ),
        ),
        PlatformPopupMenuItem(
          value: 2,
          child: IconText(
            icon: Icon(iconService.mediaVideo),
            label: Text(localizations.attachTypeVideo),
            brightness: brightness,
          ),
        ),
        PlatformPopupMenuItem(
          value: 3,
          child: IconText(
            icon: Icon(iconService.mediaAudio),
            label: Text(localizations.attachTypeAudio),
            brightness: brightness,
          ),
        ),
        PlatformPopupMenuItem(
          value: 4,
          child: IconText(
            icon: Icon(iconService.location),
            label: Text(localizations.attachTypeLocation),
            brightness: brightness,
          ),
        ),
        if (locator<KeyService>().hasGiphy)
          PlatformPopupMenuItem(
            value: 5,
            child: IconText(
              icon: Icon(iconService.mediaGif),
              label: Text(localizations.attachTypeGif),
              brightness: brightness,
            ),
          ),
        PlatformPopupMenuItem(
          value: 6,
          child: IconText(
            icon: Icon(iconService.appointment),
            label: Text(localizations.attachTypeAppointment),
            brightness: brightness,
          ),
        ),
      ],
      onSelected: (value) async {
        var changed = false;
        switch (value) {
          case 0: // any file
            changed = await addAttachmentFile();
            break;
          case 1: // photo file
            changed = await addAttachmentFile(fileType: FileType.image);
            break;
          case 2: // video file
            changed = await addAttachmentFile(fileType: FileType.video);
            break;
          case 3: // audio file
            changed = await addAttachmentFile(fileType: FileType.audio);
            break;
          case 4: // location
            final result =
                await locator<NavigationService>().push(Routes.locationPicker);
            if (result != null) {
              composeData.messageBuilder.addBinary(
                  result, MediaSubtype.imagePng.mediaType,
                  filename: "location.jpg");
              changed = true;
            }
            break;
          case 5: // gif / sticker / emoji file
            changed = await addAttachmentGif(context, localizations);
            break;
          case 6: // appointment
            changed = await addAttachmentAppointment(context, localizations);
            break;
        }
        if (changed) {
          update();
        }
      },
    );
  }

  Future<bool> addAttachmentFile({FileType fileType = FileType.any}) async {
    final result = await FilePicker.platform
        .pickFiles(type: fileType, allowMultiple: true, withData: true);
    if (result == null) {
      return false;
    }
    for (final file in result.files) {
      final lastDotIndex = file.path!.lastIndexOf('.');
      MediaType mediaType;
      if (lastDotIndex == -1 || lastDotIndex == file.path!.length - 1) {
        mediaType = MediaType.fromSubtype(MediaSubtype.applicationOctetStream);
      } else {
        final ext = file.path!.substring(lastDotIndex + 1);
        mediaType = MediaType.guessFromFileExtension(ext);
      }
      composeData.messageBuilder
          .addBinary(file.bytes!, mediaType, filename: file.name);
    }
    return true;
  }

  Future<bool> addAttachmentGif(
    BuildContext context,
    AppLocalizations localizations,
  ) async {
    final giphy = locator<KeyService>().giphy;
    if (giphy == null) {
      LocalizedDialogHelper.showTextDialog(context, localizations.errorTitle,
          'No GIPHY API key found. Please check set up instructions.');
      return false;
    }

    final gif = await Giphy.getGif(
      context: context,
      apiKey: giphy,
      // searchLabelText: searchSticker
      //     ? localizations.attachTypeStickerSearch
      //     : localizations.attachTypeGifSearch,
      lang: locator<I18nService>().locale!.languageCode,
      keepState: true,
      showPreview: true,
      // sticker: searchSticker,
      // showPreviewPage: false,
    );
    final contentUrl = gif?.recommendedMobileSend.url;
    if (gif == null || contentUrl == null) {
      return false;
    }
    final result = await HttpHelper.httpGet(contentUrl);
    final data = result.data;
    if (data == null) {
      return false;
    }
    composeData.messageBuilder.addBinary(
        data, MediaType.fromSubtype(MediaSubtype.imageGif),
        filename: '${gif.title}.gif');

    return true;
  }

  Future<bool> addAttachmentAppointment(
      BuildContext context, AppLocalizations localizations) async {
    final appointment = await IcalComposer.createOrEditAppointment(context);
    if (appointment != null) {
      // idea: add some sort of finalizer that updates the appointment at the end
      // to set the organizer and the attendees
      final text = appointment.toString();
      final attachmentBuilder = composeData.messageBuilder.addText(
        text,
        mediaType: MediaType.fromText('application/ics'),
        disposition: ContentDispositionHeader.from(
          ContentDisposition.attachment,
          filename: 'invite.ics',
        ),
      );
      attachmentBuilder.contentType!.setParameter('method', 'REQUEST');
      final finalizer = _AppointmentFinalizer(appointment, attachmentBuilder);
      composeData.addFinalizer(finalizer.finalize);
    }
    return (appointment != null);
  }
}

class _AppointmentFinalizer {
  final VCalendar appointment;
  final PartBuilder attachmentBuilder;

  _AppointmentFinalizer(this.appointment, this.attachmentBuilder);

  void finalize(MessageBuilder messageBuilder) {
    final event = appointment.event!;
    if (messageBuilder.from?.isNotEmpty == true) {
      final organizer = messageBuilder.from!.first;
      event.organizer = OrganizerProperty.create(
        email: organizer.email,
        commonName: organizer.personalName,
      );
      event.addAttendee(AttendeeProperty.create(
        attendeeEmail: organizer.email,
        commonName: organizer.personalName,
        participantStatus: ParticipantStatus.accepted,
      )!);
    }
    final recipients = <MailAddress>[];
    if (messageBuilder.to != null) {
      recipients.addAll(messageBuilder.to!);
    }
    if (messageBuilder.cc != null) {
      recipients.addAll(messageBuilder.cc!);
    }
    for (final mailAddress in recipients) {
      event.addAttendee(AttendeeProperty.create(
        attendeeEmail: mailAddress.email,
        commonName: mailAddress.personalName,
        rsvp: true,
      )!);
    }
    attachmentBuilder.text = appointment.toString();
  }
}

class ComposeAttachment extends StatelessWidget {
  final AttachmentInfo attachment;
  final void Function(AttachmentInfo attachment) onRemove;

  const ComposeAttachment(
      {Key? key, required this.attachment, required this.onRemove})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: PreviewMediaWidget(
          mediaProvider:
              AttachmentMediaProviderFactory.fromAttachmentInfo(attachment),
          width: 60,
          height: 60,
          showInteractiveDelegate: (interactiveMedia) async {
            if (attachment.mediaType.sub == MediaSubtype.messageRfc822) {
              final mime = MimeMessage.parseFromData(attachment.data!);
              final message = Message.embedded(mime, Message.of(context)!);
              return locator<NavigationService>()
                  .push(Routes.mailDetails, arguments: message);
            }
            if (attachment.mediaType.sub == MediaSubtype.applicationIcs ||
                attachment.mediaType.sub == MediaSubtype.textCalendar) {
              final text = attachment.part.text!;
              final appointment = VComponent.parse(text) as VCalendar;
              final update = await IcalComposer.createOrEditAppointment(context,
                  appointment: appointment);
              if (update != null) {
                attachment.part.text = update.toString();
              }
              return;
            }

            return locator<NavigationService>()
                .push(Routes.interactiveMedia, arguments: interactiveMedia);
          },
          contextMenuEntries: [
            PopupMenuItem<String>(
              value: 'remove',
              child: Text(localizations
                  .composeRemoveAttachmentAction(attachment.name!)),
            ),
          ],
          onContextMenuSelected: (provider, value) => onRemove(attachment),
        ),
      ),
    );
  }
}
