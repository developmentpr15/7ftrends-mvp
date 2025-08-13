import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/closet_item.dart';
import '../../services/closet_service.dart';
import '../models/category_data.dart';

class ClosetProvider extends ChangeNotifier {
  final _closetService = ClosetService();
  List<ClosetItem> _items = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  List<CategoryData> get categories => [
    CategoryData(name: 'All', icon: Icons.grid_view),
    CategoryData(name: 'Tops', icon: Icons.accessibility),
    CategoryData(name: 'Bottoms', icon: Icons.weekend),
    CategoryData(name: 'Dresses', icon: Icons.palette),
    CategoryData(name: 'Shoes', icon: Icons.directions_walk),
    CategoryData(name: 'Accessories', icon: Icons.local_mall),
  ];
  List<ClosetItem> get items {
    if (_selectedCategory == 'All' && _searchQuery.isEmpty) return _items;
    
    return _items.where((item) {
      final matchesCategory = _selectedCategory == 'All' || item.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty || 
        item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        item.brand.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        item.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));
      return matchesCategory && matchesSearch;
    }).toList();
  }

  ClosetProvider() {
    loadItems();
  }

  Future<void> loadItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      _items = await _closetService.loadClosetItems();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addItem(String name, String category, String color, String brand, XFile imageFile, List<String> tags) async {
    _isLoading = true;
    notifyListeners();

    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      final item = ClosetItem(
        id: DateTime.now().toString(),
        name: name,
        category: category,
        color: color,
        brand: brand,
        imageBase64: base64Image,
        createdAt: DateTime.now(),
        tags: tags,
      );

      _items.add(item);
      await _closetService.saveClosetItems(_items);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteItem(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      _items.removeWhere((item) => item.id == id);
      await _closetService.saveClosetItems(_items);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateItem(ClosetItem item) async {
    _isLoading = true;
    notifyListeners();

    try {
      final index = _items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _items[index] = item;
        await _closetService.saveClosetItems(_items);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Uint8List? getImageBytes(String base64String) {
    try {
      return base64Decode(base64String);
    } catch (e) {
      return null;
    }
  }
}
