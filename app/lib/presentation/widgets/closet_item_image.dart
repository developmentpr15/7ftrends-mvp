import 'dart:convert';
import 'package:flutter/material.dart';

import '../../shared/constants.dart';

class ClosetItemImage extends StatelessWidget {
  final String imageBase64;
  final double size;
  final String name;
  
  const ClosetItemImage({
    super.key, 
    required this.imageBase64, 
    required this.size, 
    required this.name
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double actualSize = size.isFinite ? size : constraints.maxWidth;

        if (imageBase64.isNotEmpty) {
          try {
            final bytes = base64Decode(imageBase64);
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                bytes,
                width: actualSize,
                height: actualSize,
                fit: BoxFit.cover,
              ),
            );
          } catch (_) {}
        }
        
        // Placeholder
        return Container(
          width: actualSize,
          height: actualSize,
          decoration: BoxDecoration(
            color: kPrimaryColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                color: kPrimaryColor,
                fontWeight: FontWeight.bold,
                fontSize: actualSize * 0.5,
              ),
            ),
          ),
        );
      },
    );
  }
}
