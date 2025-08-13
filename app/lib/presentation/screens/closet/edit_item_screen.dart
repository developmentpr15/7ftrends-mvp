import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import '../../../../models/closet_item.dart';
import '../../providers/closet_provider.dart';
import '../../../../shared/constants.dart';

class EditItemScreen extends StatefulWidget {
  final ClosetItem item;
  const EditItemScreen({super.key, required this.item});

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _brandController;
  String? _selectedCategory;
  late Color _selectedColor;
  Uint8List? _imageBytes;
  bool _isPickingImage = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _brandController = TextEditingController(text: widget.item.brand);
    _selectedCategory = widget.item.category;
    _selectedColor = Color(int.parse('0xFF${widget.item.color.substring(1)}'));
    _imageBytes = base64Decode(widget.item.imageBase64);
  }

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

      final updatedItem = widget.item.copyWith(
        name: _nameController.text,
        category: _selectedCategory!,
        color: '#${_selectedColor.value.toRadixString(16).substring(2)}',
        brand: _brandController.text,
        imageBase64: base64Encode(_imageBytes!),
      );

      Provider.of<ClosetProvider>(context, listen: false).updateItem(updatedItem);
      Navigator.pop(context);
    }
  }

  void _deleteItem() {
    Provider.of<ClosetProvider>(context, listen: false).deleteItem(widget.item.id);
    Navigator.pop(context); // Pop edit screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Item'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteItem,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an item name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(labelText: 'Brand'),
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: kCategories.map((category) {
                  return DropdownMenuItem(
                    value: category.name,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Select Color'),
                trailing: CircleAvatar(backgroundColor: _selectedColor),
                onTap: () async {
                  final newColor = await showColorPicker(context, _selectedColor);
                  if (newColor != null) {
                    setState(() {
                      _selectedColor = newColor;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              _isPickingImage
                  ? const Center(child: CircularProgressIndicator())
                  : _imageBytes == null
                      ? ElevatedButton(
                          onPressed: _pickImage,
                          child: const Text('Pick Image'),
                        )
                      : Image.memory(_imageBytes!, height: 200),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Color?> showColorPicker(BuildContext context, Color currentColor) {
    return showDialog<Color>(
      context: context,
      builder: (BuildContext context) {
        Color? tempColor = currentColor;
        return AlertDialog(
          title: const Text('Select Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              color: tempColor,
              onColorChanged: (color) {
                tempColor = color;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Got it'),
              onPressed: () {
                Navigator.of(context).pop(tempColor);
              },
            ),
          ],
        );
      },
    );
  }
}