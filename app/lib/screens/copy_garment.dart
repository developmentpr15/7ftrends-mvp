import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/avatar_provider.dart';
import '../providers/auth_provider.dart';

class CopyGarmentScreen extends StatefulWidget {
  const CopyGarmentScreen({Key? key}) : super(key: key);

  @override
  State<CopyGarmentScreen> createState() => _CopyGarmentScreenState();
}

class _CopyGarmentScreenState extends State<CopyGarmentScreen> {
  File? _image;
  bool _copyToAvatar = false;
  bool _copyToRealMe = false;
  String? _previewImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _extractGarment() async {
    if (_image == null) return;

    try {
      final bytes = await _image!.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await Provider.of<AuthProvider>(context, listen: false)
          .postToApi('/extract-garment', {'image': base64Image});

      if (response != null && response['mask'] != null) {
        setState(() {
          _previewImage = response['mask'];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Copy Garment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Upload Selfie'),
            ),
            const SizedBox(height: 16),
            if (_image != null) ...[
              Image.file(_image!),
              const SizedBox(height: 16),
            ],
            SwitchListTile(
              title: const Text('Copy to my avatar'),
              value: _copyToAvatar,
              onChanged: (value) {
                setState(() {
                  _copyToAvatar = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Copy to real me'),
              value: _copyToRealMe,
              onChanged: (value) {
                setState(() {
                  _copyToRealMe = value;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _extractGarment,
              child: const Text('Preview Garment'),
            ),
            const SizedBox(height: 16),
            if (_previewImage != null)
              Image.memory(base64Decode(_previewImage!)),
          ],
        ),
      ),
    );
  }
}
