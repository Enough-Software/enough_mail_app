import 'package:enough_giphy_flutter/enough_giphy_flutter.dart';
import 'package:enough_icalendar/enough_icalendar.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:enough_media/enough_media.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../app_lifecycle/provider.dart';
import '../keys/service.dart';
import '../localization/app_localizations.g.dart';
import '../localization/extension.dart';
import '../models/compose_data.dart';
import '../models/message.dart';
import '../routes.dart';
import '../settings/theme/icon_service.dart';
import '../util/http_helper.dart';
import '../util/localized_dialog_helper.dart';
import 'ical_composer.dart';
import 'icon_text.dart';

class AttachmentMediaProviderFactory {
  static MediaProvider fromAttachmentInfo(AttachmentInfo info) =>
      MemoryMediaProvider(info.name!, info.mediaType.text, info.data!);
}

class AttachmentComposeBar extends StatefulWidget {
  const AttachmentComposeBar({
    super.key,
    required this.composeData,
    this.isDownloading = false,
  });

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
  Widget build(BuildContext context) => Wrap(
        children: [
          for (final attachment in _attachments)
            ComposeAttachment(
              parentMessage: widget.composeData.originalMessage,
              attachment: attachment,
              onRemove: removeAttachment,
            ),
          if (widget.isDownloading) const PlatformProgressIndicator(),
          AddAttachmentPopupButton(
            composeData: widget.composeData,
            update: () => setState(() {}),
          ),
        ],
      );

  void removeAttachment(AttachmentInfo attachment) {
    widget.composeData.messageBuilder.removeAttachment(attachment);
    setState(() {
      _attachments.remove(attachment);
    });
  }
}

class AddAttachmentPopupButton extends ConsumerWidget {
  const AddAttachmentPopupButton({
    super.key,
    required this.composeData,
    required this.update,
  });
  final ComposeData composeData;
  final Function() update;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void ignoreNextResume() => ref
        .read(appLifecycleProvider.notifier)
        .ignoreNextInactivationCycle(timeout: const Duration(seconds: 120));

    final localizations = context.text;
    final iconService = IconService.instance;
    const brightness = Brightness.light;
    // TODO(RV): implement brightness access
    // themeService.brightness(context);

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
        if (KeyService.instance.hasGiphy)
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
            ignoreNextResume();
            changed = await addAttachmentFile();
            break;
          case 1: // photo file
            ignoreNextResume();
            changed = await addAttachmentFile(
              fileType: FileType.image,
            );
            break;
          case 2: // video file
            ignoreNextResume();
            changed = await addAttachmentFile(
              fileType: FileType.video,
            );
            break;
          case 3: // audio file
            ignoreNextResume();
            changed = await addAttachmentFile(
              fileType: FileType.audio,
            );
            break;
          case 4: // location
            if (context.mounted) {
              final result =
                  await context.pushNamed<Uint8List>(Routes.locationPicker);
              if (result != null) {
                composeData.messageBuilder.addBinary(
                  result,
                  MediaSubtype.imagePng.mediaType,
                  filename: 'location.jpg',
                );
                changed = true;
              }
            }
            break;
          case 5: // gif / sticker / emoji file
            if (context.mounted) {
              changed = await addAttachmentGif(context, localizations);
            }
            break;
          case 6: // appointment
            if (context.mounted) {
              changed =
                  await addAttachmentAppointment(context, ref, localizations);
            }
            break;
        }
        if (changed) {
          update();
        }
      },
    );
  }

  Future<bool> addAttachmentFile({
    FileType fileType = FileType.any,
  }) async {
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
    final giphy = KeyService.instance.giphy;
    if (giphy == null) {
      await LocalizedDialogHelper.showTextDialog(
        context,
        localizations.errorTitle,
        'No GIPHY API key found. Please check set up instructions.',
      );

      return false;
    }

    final gif = await Giphy.getGif(
      context: context,
      apiKey: giphy,
      // searchLabelText: searchSticker
      //     ? localizations.attachTypeStickerSearch
      //     : localizations.attachTypeGifSearch,
      lang: localizations.localeName,
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
      data,
      MediaType.fromSubtype(MediaSubtype.imageGif),
      filename: '${gif.title}.gif',
    );

    return true;
  }

  Future<bool> addAttachmentAppointment(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations localizations,
  ) async {
    final appointment =
        await IcalComposer.createOrEditAppointment(context, ref);
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
  _AppointmentFinalizer(this.appointment, this.attachmentBuilder);
  final VCalendar appointment;
  final PartBuilder attachmentBuilder;

  void finalize(MessageBuilder messageBuilder) {
    final event = appointment.event!;
    if (messageBuilder.from?.isNotEmpty ?? false) {
      final organizer = messageBuilder.from!.first;
      event.organizer = OrganizerProperty.create(
        email: organizer.email,
        commonName: organizer.personalName,
      );
      event.addAttendee(
        AttendeeProperty.create(
          attendeeEmail: organizer.email,
          commonName: organizer.personalName,
          participantStatus: ParticipantStatus.accepted,
        )!,
      );
    }
    final recipients = <MailAddress>[];
    if (messageBuilder.to != null) {
      recipients.addAll(messageBuilder.to!);
    }
    if (messageBuilder.cc != null) {
      recipients.addAll(messageBuilder.cc!);
    }
    for (final mailAddress in recipients) {
      event.addAttendee(
        AttendeeProperty.create(
          attendeeEmail: mailAddress.email,
          commonName: mailAddress.personalName,
          rsvp: true,
        )!,
      );
    }
    attachmentBuilder.text = appointment.toString();
  }
}

class ComposeAttachment extends ConsumerWidget {
  const ComposeAttachment({
    super.key,
    required this.parentMessage,
    required this.attachment,
    required this.onRemove,
  });

  final Message? parentMessage;
  final AttachmentInfo attachment;
  final void Function(AttachmentInfo attachment) onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = context.text;
    final parentMessage = this.parentMessage;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: PreviewMediaWidget(
          mediaProvider:
              AttachmentMediaProviderFactory.fromAttachmentInfo(attachment),
          width: 60,
          height: 60,
          showInteractiveDelegate: (interactiveMedia) async {
            if (attachment.mediaType.sub == MediaSubtype.messageRfc822 &&
                parentMessage != null) {
              final mime = MimeMessage.parseFromData(attachment.data!);
              final message = Message.embedded(mime, parentMessage);

              return context.pushNamed(
                Routes.mailDetails,
                extra: message,
              );
            }
            if (attachment.mediaType.sub == MediaSubtype.applicationIcs ||
                attachment.mediaType.sub == MediaSubtype.textCalendar) {
              final text = attachment.part.text!;
              final appointment = VComponent.parse(text) as VCalendar;
              final update = await IcalComposer.createOrEditAppointment(
                context,
                ref,
                appointment: appointment,
              );
              if (update != null) {
                attachment.part.text = update.toString();
              }

              return Future.value();
            }

            return context.pushNamed(
              Routes.interactiveMedia,
              extra: interactiveMedia,
            );
          },
          contextMenuEntries: [
            PopupMenuItem<String>(
              value: 'remove',
              child: Text(
                localizations.composeRemoveAttachmentAction(attachment.name!),
              ),
            ),
          ],
          onContextMenuSelected: (provider, value) => onRemove(attachment),
        ),
      ),
    );
  }
}
