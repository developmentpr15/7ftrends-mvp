import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/user_profile.dart';
import '../../models/closet_item.dart';
import '../../models/feed_post.dart';
import '../../shared/constants.dart';
import '../../shared/validation.dart';
import '../widgets/closet_item_image.dart';
import 'closet_picker_dialog.dart';

class CreatePostScreen extends StatefulWidget {
  final UserProfile currentUser;
  final List<ClosetItem> closetItems;

  const CreatePostScreen({
    super.key,
    required this.currentUser,
    required this.closetItems,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  String _imageData = '';
  String _caption = '';
  String _hashtags = '';
  ClosetItem? _selectedClosetItem;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _imageData = base64Encode(bytes);
        _selectedClosetItem = null; // Clear selected closet item if new image is uploaded
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageData.isEmpty && _selectedClosetItem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image or choose from closet'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final post = FeedPost(
      id: '', // Will be set by backend
      userId: widget.currentUser.userId,
      username: widget.currentUser.username,
      userAvatarUrl: '', // No avatar for now
      likes: 0,
      likedByMe: false,
      createdAt: DateTime.now(),
      imageData: _imageData,
      caption: _caption.trim(),
      hashtags: _hashtags.isEmpty
          ? []
          : _hashtags
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
      closetItemId: _selectedClosetItem?.id,
    );

    Navigator.pop(context, post);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submit,
            child: const Text(
              'Post',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_imageData.isNotEmpty || _selectedClosetItem != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _selectedClosetItem != null
                    ? Image.memory(
                        base64Decode(_selectedClosetItem!.imageBase64),
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.cover,
                      )
                    : Image.memory(
                        base64Decode(_imageData),
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
              )
            else
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.image, size: 64, color: Colors.grey),
                      const SizedBox(height: 8),
                      const Text(
                        'No image selected',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.upload),
                            label: const Text('Upload Image'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () => _showClosetPicker(),
                            icon: const Icon(Icons.checkroom),
                            label: const Text('From Closet'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Caption',
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              maxLength: 500,
              validator: validateCaption,
              onChanged: (v) => _caption = v,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Hashtags (comma separated)',
                hintText: 'fashion, ootd, style',
              ),
              validator: validateHashtags,
              onChanged: (v) => _hashtags = v,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showClosetPicker() async {
    if (widget.closetItems.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No items in your closet yet'),
          backgroundColor: Colors.orange,
          action: SnackBarAction(
            label: 'Add Item',
            textColor: Colors.white,
            onPressed: () {
              Navigator.of(context).pushNamed('/closet/add');
            },
          ),
        ),
      );
      return;
    }

    final selected = await showDialog<ClosetItem>(
      context: context,
      builder: (context) => ClosetPickerDialog(closetItems: widget.closetItems),
    );

    if (selected != null) {
      setState(() {
        _selectedClosetItem = selected;
        _imageData = ''; // Clear uploaded image if closet item is selected
      });
    }
  }
}
