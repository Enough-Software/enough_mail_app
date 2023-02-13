// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Settings _$SettingsFromJson(Map<String, dynamic> json) => Settings(
      blockExternalImages: json['blockExternalImages'] as bool? ?? false,
      preferredComposeMailAddress:
          json['preferredComposeMailAddress'] as String?,
      languageTag: json['languageTag'] as String?,
      themeSettings: json['themeSettings'] == null
          ? const ThemeSettings()
          : ThemeSettings.fromJson(
              json['themeSettings'] as Map<String, dynamic>),
      swipeLeftToRightAction: $enumDecodeNullable(
              _$SwipeActionEnumMap, json['swipeLeftToRightAction']) ??
          SwipeAction.markRead,
      swipeRightToLeftAction: $enumDecodeNullable(
              _$SwipeActionEnumMap, json['swipeRightToLeftAction']) ??
          SwipeAction.delete,
      folderNameSetting: $enumDecodeNullable(
              _$FolderNameSettingEnumMap, json['folderNameSetting']) ??
          FolderNameSetting.localized,
      customFolderNames: (json['customFolderNames'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      enableDeveloperMode: json['enableDeveloperMode'] as bool? ?? false,
      signatureHtml: json['signatureHtml'] as String?,
      signaturePlain: json['signaturePlain'] as String?,
      signatureActions: (json['signatureActions'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$ComposeActionEnumMap, e))
              .toList() ??
          const [ComposeAction.newMessage],
      readReceiptDisplaySetting: $enumDecodeNullable(
              _$ReadReceiptDisplaySettingEnumMap,
              json['readReceiptDisplaySetting']) ??
          ReadReceiptDisplaySetting.always,
      defaultSender: json['defaultSender'] == null
          ? null
          : MailAddress.fromJson(json['defaultSender'] as Map<String, dynamic>),
      preferPlainTextMessages:
          json['preferPlainTextMessages'] as bool? ?? false,
      urlLaunchMode:
          $enumDecodeNullable(_$LaunchModeEnumMap, json['urlLaunchMode']) ??
              LaunchMode.externalApplication,
      replyFormatPreference: $enumDecodeNullable(
              _$ReplyFormatPreferenceEnumMap, json['replyFormatPreference']) ??
          ReplyFormatPreference.alwaysHtml,
      enableBiometricLock: json['enableBiometricLock'] as bool? ?? false,
      lockTimePreference: $enumDecodeNullable(
              _$LockTimePreferenceEnumMap, json['enableBiometricLockTime']) ??
          LockTimePreference.immediately,
    );

Map<String, dynamic> _$SettingsToJson(Settings instance) => <String, dynamic>{
      'blockExternalImages': instance.blockExternalImages,
      'preferredComposeMailAddress': instance.preferredComposeMailAddress,
      'languageTag': instance.languageTag,
      'themeSettings': instance.themeSettings,
      'swipeLeftToRightAction':
          _$SwipeActionEnumMap[instance.swipeLeftToRightAction]!,
      'swipeRightToLeftAction':
          _$SwipeActionEnumMap[instance.swipeRightToLeftAction]!,
      'folderNameSetting':
          _$FolderNameSettingEnumMap[instance.folderNameSetting]!,
      'customFolderNames': instance.customFolderNames,
      'enableDeveloperMode': instance.enableDeveloperMode,
      'signatureHtml': instance.signatureHtml,
      'signaturePlain': instance.signaturePlain,
      'signatureActions': instance.signatureActions
          .map((e) => _$ComposeActionEnumMap[e]!)
          .toList(),
      'readReceiptDisplaySetting': _$ReadReceiptDisplaySettingEnumMap[
          instance.readReceiptDisplaySetting]!,
      'defaultSender': instance.defaultSender,
      'preferPlainTextMessages': instance.preferPlainTextMessages,
      'urlLaunchMode': _$LaunchModeEnumMap[instance.urlLaunchMode]!,
      'replyFormatPreference':
          _$ReplyFormatPreferenceEnumMap[instance.replyFormatPreference]!,
      'enableBiometricLock': instance.enableBiometricLock,
      'enableBiometricLockTime':
          _$LockTimePreferenceEnumMap[instance.lockTimePreference]!,
    };

const _$SwipeActionEnumMap = {
  SwipeAction.markRead: 'markRead',
  SwipeAction.archive: 'archive',
  SwipeAction.markJunk: 'markJunk',
  SwipeAction.delete: 'delete',
  SwipeAction.flag: 'flag',
};

const _$FolderNameSettingEnumMap = {
  FolderNameSetting.server: 'server',
  FolderNameSetting.localized: 'localized',
  FolderNameSetting.custom: 'custom',
};

const _$ComposeActionEnumMap = {
  ComposeAction.answer: 'answer',
  ComposeAction.forward: 'forward',
  ComposeAction.newMessage: 'newMessage',
};

const _$ReadReceiptDisplaySettingEnumMap = {
  ReadReceiptDisplaySetting.always: 'always',
  ReadReceiptDisplaySetting.never: 'never',
};

const _$LaunchModeEnumMap = {
  LaunchMode.platformDefault: 'platformDefault',
  LaunchMode.inAppWebView: 'inAppWebView',
  LaunchMode.externalApplication: 'externalApplication',
  LaunchMode.externalNonBrowserApplication: 'externalNonBrowserApplication',
};

const _$ReplyFormatPreferenceEnumMap = {
  ReplyFormatPreference.alwaysHtml: 'alwaysHtml',
  ReplyFormatPreference.sameFormat: 'sameFormat',
  ReplyFormatPreference.alwaysPlainText: 'alwaysPlainText',
};

const _$LockTimePreferenceEnumMap = {
  LockTimePreference.immediately: 'immediately',
  LockTimePreference.after5minutes: 'after5minutes',
  LockTimePreference.after30minutes: 'after30minutes',
};
