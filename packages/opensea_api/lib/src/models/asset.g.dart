// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: implicit_dynamic_parameter

part of 'asset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Asset _$AssetFromJson(Map<String, dynamic> json) {
  return $checkedNew('Asset', json, () {
    final val = Asset(
      id: $checkedConvert(json, 'id', (v) => v as int),
      imageUrl: $checkedConvert(json, 'image_url', (v) => v as String),
      tokenId: $checkedConvert(json, 'token_id', (v) => v as String),
      permalink: $checkedConvert(json, 'permalink', (v) => v as String),
      name: $checkedConvert(json, 'name', (v) => v as String),
      description: $checkedConvert(json, 'description', (v) => v as String),
      imagePreviewUrl:
          $checkedConvert(json, 'image_preview_url', (v) => v as String),
    );
    return val;
  }, fieldKeyMap: const {
    'imageUrl': 'image_url',
    'tokenId': 'token_id',
    'imagePreviewUrl': 'image_preview_url'
  });
}
