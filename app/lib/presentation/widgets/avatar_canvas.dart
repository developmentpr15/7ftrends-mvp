import 'package:flutter/material.dart';
import '../../models/avatar_config.dart';

/// Simple SVG-style avatar renderer.
/// Uses colored [Container]/[Positioned] shapes—no external assets.
class AvatarCanvas extends StatelessWidget {
  final AvatarConfig config;
  final double size;          // logical pixels (width == height)

  const AvatarCanvas({
    super.key,
    required this.config,
    this.size = 80,
  });

  /// Helper to map enums → Colors.
  Color _tone(SkinTone tone) {
    switch (tone) {
      case SkinTone.light:
        return const Color(0xFFFFE0BD);
      case SkinTone.medium:
        return const Color(0xFFDCB48C);
      case SkinTone.tan:
        return const Color(0xFFC88A65);
      case SkinTone.dark:
        return const Color(0xFF8D5524);
      default:
        return const Color(0xFFDCB48C);
    }
  }

  Color _hairColor(HairColor color) {
    switch (color) {
      case HairColor.brown:
        return const Color(0xFF5D4037);
      case HairColor.black:
        return Colors.black;
      case HairColor.blonde:
        return const Color(0xFFFFE082);
      case HairColor.red:
        return const Color(0xFFBF360C);
      case HairColor.gray:
        return const Color(0xFF9E9E9E);
      default:
        return const Color(0xFF5D4037);
    }
  }

  Widget _body() => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _tone(config.skinTone),
          shape: BoxShape.circle,
        ),
      );

  Widget _hairWidget() {
    if (config.hairStyle == HairStyle.bun) return const SizedBox(); // Example: treat bun as bald
    return Positioned(
      top: size * 0.05,
      left: size * 0.15,
      child: Container(
        width: size * 0.7,
        height: size * 0.35,
        decoration: BoxDecoration(
          color: _hairColor(config.hairColor),
          borderRadius: BorderRadius.circular(size * 0.2),
        ),
      ),
    );
  }

  Widget _accessory() {
    switch (config.accessory) {
      case Accessory.glasses:
        return Positioned(
          top: size * 0.38,
          left: size * 0.18,
          child: Row(children: [
            _glassesLens(), const SizedBox(width: 6), _glassesLens(),
          ]),
        );
      case Accessory.hat:
        return Positioned(
          top: size * 0.0,
          left: size * 0.1,
          child: Container(
            width: size * 0.8,
            height: size * 0.25,
            decoration: BoxDecoration(
              color: _hairColor(config.hairColor),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      case Accessory.earrings:
      case Accessory.necklace:
      case Accessory.none:
        return const SizedBox();
    }
  }

  Widget _glassesLens() => Container(
        width: size * 0.22,
        height: size * 0.15,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          _body(),
          _hairWidget(),
          _accessory(),
        ],
      ),
    );
  }
}
