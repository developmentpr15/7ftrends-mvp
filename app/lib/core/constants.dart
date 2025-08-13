import 'package:flutter/material.dart';

class ClosetCategory {
  final String name;
  final IconData icon;
  const ClosetCategory(this.name, this.icon);
}

const kPrimaryColor = Color(0xFF8B5CF6);

const kCategories = [
  ClosetCategory('All', Icons.apps),
  ClosetCategory('Tops', Icons.checkroom),
  ClosetCategory('Bottoms', Icons.shopping_bag),
  ClosetCategory('Shoes', Icons.directions_run),
  ClosetCategory('Accessories', Icons.watch),
  ClosetCategory('Outerwear', Icons.ac_unit),
  ClosetCategory('Dresses', Icons.checkroom),
  ClosetCategory('Activewear', Icons.sports_gymnastics),
  ClosetCategory('Swimwear', Icons.pool),
  ClosetCategory('Other', Icons.more_horiz),
];
