import 'package:flutter/material.dart';

enum BodyType { slim, average, athletic, curvy }
enum SkinTone { light, medium, tan, dark }
enum HairStyle { short, medium, long, bun, ponytail }
enum HairColor { black, brown, blonde, red, gray, pink, blue }
enum Outfit { casual, formal, sporty, street, dress, swim }
enum Accessory { none, glasses, hat, earrings, necklace }

class AvatarConfig {
  final BodyType bodyType;
  final SkinTone skinTone;
  final HairStyle hairStyle;
  final HairColor hairColor;
  final Outfit outfit;
  final Accessory accessory;

  const AvatarConfig({
    required this.bodyType,
    required this.skinTone,
    required this.hairStyle,
    required this.hairColor,
    required this.outfit,
    required this.accessory,
  });

  AvatarConfig copyWith({
    BodyType? bodyType,
    SkinTone? skinTone,
    HairStyle? hairStyle,
    HairColor? hairColor,
    Outfit? outfit,
    Accessory? accessory,
  }) {
    return AvatarConfig(
      bodyType: bodyType ?? this.bodyType,
      skinTone: skinTone ?? this.skinTone,
      hairStyle: hairStyle ?? this.hairStyle,
      hairColor: hairColor ?? this.hairColor,
      outfit: outfit ?? this.outfit,
      accessory: accessory ?? this.accessory,
    );
  }

  Map<String, dynamic> toJson() => {
        'bodyType': bodyType.index,
        'skinTone': skinTone.index,
        'hairStyle': hairStyle.index,
        'hairColor': hairColor.index,
        'outfit': outfit.index,
        'accessory': accessory.index,
      };

  factory AvatarConfig.fromJson(Map<String, dynamic> json) => AvatarConfig(
        bodyType: BodyType.values[json['bodyType'] ?? 0],
        skinTone: SkinTone.values[json['skinTone'] ?? 0],
        hairStyle: HairStyle.values[json['hairStyle'] ?? 0],
        hairColor: HairColor.values[json['hairColor'] ?? 0],
        outfit: Outfit.values[json['outfit'] ?? 0],
        accessory: Accessory.values[json['accessory'] ?? 0],
      );

  static AvatarConfig defaultConfig() => const AvatarConfig(
        bodyType: BodyType.average,
        skinTone: SkinTone.medium,
        hairStyle: HairStyle.short,
        hairColor: HairColor.brown,
        outfit: Outfit.casual,
        accessory: Accessory.none,
      );
}
