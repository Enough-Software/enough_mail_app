// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'extensions.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppExtension _$AppExtensionFromJson(Map<String, dynamic> json) => AppExtension(
      version: json['version'] as int?,
      accountSideMenu: (json['accountSideMenu'] as List<dynamic>?)
          ?.map((e) =>
              AppExtensionActionDescription.fromJson(e as Map<String, dynamic>))
          .toList(),
      forgotPasswordAction: json['forgotPassword'] == null
          ? null
          : AppExtensionActionDescription.fromJson(
              json['forgotPassword'] as Map<String, dynamic>),
      signatureHtml: (json['signatureHtml'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$AppExtensionToJson(AppExtension instance) =>
    <String, dynamic>{
      'version': instance.version,
      'accountSideMenu': instance.accountSideMenu,
      'forgotPassword': instance.forgotPasswordAction,
      'signatureHtml': instance.signatureHtml,
    };

AppExtensionActionDescription _$AppExtensionActionDescriptionFromJson(
        Map<String, dynamic> json) =>
    AppExtensionActionDescription(
      action: json['action'] == null
          ? null
          : AppExtensionAction.fromJson(json['action'] as Map<String, dynamic>),
      icon: json['icon'] as String?,
      labelByLanguage: (json['label'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$AppExtensionActionDescriptionToJson(
        AppExtensionActionDescription instance) =>
    <String, dynamic>{
      'action': instance.action,
      'icon': instance.icon,
      'label': instance.labelByLanguage,
    };

AppExtensionAction _$AppExtensionActionFromJson(Map<String, dynamic> json) =>
    AppExtensionAction(
      mechanism:
          $enumDecode(_$AppExtensionActionMechanismEnumMap, json['mechanism']),
      url: json['url'] as String,
    );

Map<String, dynamic> _$AppExtensionActionToJson(AppExtensionAction instance) =>
    <String, dynamic>{
      'mechanism': _$AppExtensionActionMechanismEnumMap[instance.mechanism]!,
      'url': instance.url,
    };

const _$AppExtensionActionMechanismEnumMap = {
  AppExtensionActionMechanism.inapp: 'inapp',
  AppExtensionActionMechanism.external: 'external',
};
