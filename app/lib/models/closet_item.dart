import 'package:flutter/material.dart';

class ClosetCategory {
  final String name;
  final IconData icon;
  const ClosetCategory(this.name, this.icon);
}

class ClosetItem {
  final String id;
  final String name;
  final String category;
  final String color;
  final String brand;
  final String imageBase64;
  final DateTime createdAt;
  final List<String> tags;

  ClosetItem({
    required this.id,
    required this.name,
    required this.category,
    required this.color,
    required this.brand,
    required this.imageBase64,
    required this.createdAt,
    required this.tags,
  });

  ClosetItem copyWith({
    String? id,
    String? name,
    String? category,
    String? color,
    String? brand,
    String? imageBase64,
    DateTime? createdAt,
    List<String>? tags,
  }) {
    return ClosetItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      color: color ?? this.color,
      brand: brand ?? this.brand,
      imageBase64: imageBase64 ?? this.imageBase64,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'color': color,
        'brand': brand,
        'imageBase64': imageBase64,
        'createdAt': createdAt.toIso8601String(),
        'tags': tags,
      };

  factory ClosetItem.fromJson(Map<String, dynamic> json) => ClosetItem(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        category: json['category'] ?? '',
        color: json['color'] ?? '',
        brand: json['brand'] ?? '',
        imageBase64: json['imageBase64'] ?? '',
        createdAt: DateTime.parse(json['createdAt']),
        tags: (json['tags'] as List).map((e) => e.toString()).toList(),
      );
}
