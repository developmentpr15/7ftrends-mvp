import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../models/feed_post_new.dart';
import '../../providers/feed_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/closet_provider.dart';
import '../../../models/closet_item.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _captionController = TextEditingController();
  final _hashtagsController = TextEditingController();
  Uint8List? _imageBytes;
  bool _isPickingImage = false;
  String? _selectedClosetItemId;

  Future<void> _pickImage() async {
    setState(() {
      _isPickingImage = true;
    });
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _imageBytes = await pickedFile.readAsBytes();
    }
    setState(() {
      _isPickingImage = false;
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_imageBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image')),
        );
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final feedProvider = Provider.of<FeedProvider>(context, listen: false);

      final newPost = FeedPost(
        id: DateTime.now().toString(),
        userId: authProvider.profile!['userId'],
        username: authProvider.profile!['username'],
        userAvatarUrl: authProvider.profile!['avatarUrl'] ?? '',
        imageData: base64Encode(_imageBytes!),
        caption: _captionController.text,
        hashtags: _hashtagsController.text.split(' ').where((tag) => tag.isNotEmpty).toList(),
        likes: 0,
        likedByMe: false,
        createdAt: DateTime.now(),
        closetItemId: _selectedClosetItemId,
      );

      feedProvider.addPost(newPost);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final closetProvider = Provider.of<ClosetProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _isPickingImage
                  ? const Center(child: CircularProgressIndicator())
                  : _imageBytes == null
                      ? ElevatedButton(
                          onPressed: _pickImage,
                          child: const Text('Pick Image'),
                        )
                      : Image.memory(_imageBytes!, height: 200),
              const SizedBox(height: 16),
              TextFormField(
                controller: _captionController,
                decoration: const InputDecoration(labelText: 'Caption'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a caption';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _hashtagsController,
                decoration: const InputDecoration(labelText: 'Hashtags (space separated)'),
              ),
              if (closetProvider.items.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: _selectedClosetItemId,
                  decoration: const InputDecoration(labelText: 'Link to Closet Item (Optional)'),
                  items: ['', ...closetProvider.items.map((item) => item.id)].map((id) {
                    final item = closetProvider.items.firstWhere((i) => i.id == id, orElse: () => ClosetItem(id: '', name: 'None', category: '', color: '', brand: '', imageBase64: '', createdAt: DateTime.now(), tags: []));
                    return DropdownMenuItem(
                      value: id,
                      child: Text(id.isEmpty ? 'None' : item.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedClosetItemId = value == '' ? null : value;
                    });
                  },
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Post'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}