// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'global_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GlobalConfigImpl _$$GlobalConfigImplFromJson(Map<String, dynamic> json) =>
    _$GlobalConfigImpl(
      appName: json['appName'] as String? ?? 'DakLak Admin',
      slogan: json['slogan'] as String? ?? '',
      logoUrl: json['logoUrl'] as String? ?? '',
      contactPhone: json['contactPhone'] as String? ?? '',
      contactEmail: json['contactEmail'] as String? ?? '',
      address: json['address'] as String? ?? '',
      websiteUrl: json['websiteUrl'] as String? ?? '',
      socialAccountCount:
          json['socialAccountCount'] as String? ?? '4 tài khoản đã nối',
      mapStatus: json['mapStatus'] as String? ?? 'Tích hợp Google Maps',
      lastUpdated: json['lastUpdated'] as String? ?? '2 phút trước',
      termsUrl: json['termsUrl'] as String? ?? '',
      privacyUrl: json['privacyUrl'] as String? ?? '',
      refundUrl: json['refundUrl'] as String? ?? '',
    );

Map<String, dynamic> _$$GlobalConfigImplToJson(_$GlobalConfigImpl instance) =>
    <String, dynamic>{
      'appName': instance.appName,
      'slogan': instance.slogan,
      'logoUrl': instance.logoUrl,
      'contactPhone': instance.contactPhone,
      'contactEmail': instance.contactEmail,
      'address': instance.address,
      'websiteUrl': instance.websiteUrl,
      'socialAccountCount': instance.socialAccountCount,
      'mapStatus': instance.mapStatus,
      'lastUpdated': instance.lastUpdated,
      'termsUrl': instance.termsUrl,
      'privacyUrl': instance.privacyUrl,
      'refundUrl': instance.refundUrl,
    };
