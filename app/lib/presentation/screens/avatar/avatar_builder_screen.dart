import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/avatar_config.dart';
import '../../providers/avatar_provider.dart';
import '../../widgets/avatar_canvas.dart';

class AvatarBuilderScreen extends StatefulWidget {
  const AvatarBuilderScreen({super.key});

  @override
  State<AvatarBuilderScreen> createState() => _AvatarBuilderScreenState();
}


class _AvatarBuilderScreenState extends State<AvatarBuilderScreen> {
  late AvatarConfig _draft;

  @override
  void initState() {
    super.initState();
    final current = context.read<AvatarProvider>().config;
    _draft = current;
  }

  void _update({BodyType? body, SkinTone? skin, HairStyle? hair, HairColor? hairColor,
    Outfit? outfit, Accessory? acc}) {
    setState(() {
      _draft = _draft.copyWith(
        bodyType: body,
        skinTone: skin,
        hairStyle: hair,
        hairColor: hairColor,
        outfit: outfit,
        accessory: acc,
      );
    });
  }

  Future<void> _save() async {
    context.read<AvatarProvider>().updateConfig(_draft);
    if (mounted) Navigator.pop(context);
  }

  Widget _chip<T>(T value, T group, ValueChanged<T> onTap) {
    final selected = value == group;
    return ChoiceChip(
      label: Text(value.toString().split('.').last),
      selected: selected,
      onSelected: (_) => onTap(value),
      selectedColor: const Color(0xFF8B5CF6),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customize Avatar')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AvatarCanvas(config: _draft, size: 160),
            const SizedBox(height: 24),
            _section<BodyType>('Body Type', BodyType.values, _draft.bodyType, (v)=>_update(body:v)),
            _section<SkinTone>('Skin Tone', SkinTone.values, _draft.skinTone, (v)=>_update(skin:v)),
            _section<HairStyle>('Hair Style', HairStyle.values, _draft.hairStyle, (v)=>_update(hair:v)),
            _section<HairColor>('Hair Color', HairColor.values, _draft.hairColor, (v)=>_update(hairColor:v)),
            _section<Outfit>('Outfit', Outfit.values, _draft.outfit, (v)=>_update(outfit:v)),
            _section<Accessory>('Accessory', Accessory.values, _draft.accessory, (v)=>_update(acc:v)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: const Text('Save Avatar'),
            )
          ],
        ),
      ),
    );
  }

  Widget _section<T>(String title, List<T> options, T group, ValueChanged<T> onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Wrap(
          spacing: 8,
          children: [
            for (final opt in options) _chip<T>(opt, group, onTap)
          ],
        ),
      ],
    );
  }
}
