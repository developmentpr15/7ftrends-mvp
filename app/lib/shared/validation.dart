// Validation utility functions for form inputs

import '../shared/constants.dart';

String? validateUsername(String? value, {Set<String>? takenUsernames}) {
  if (value == null || value.trim().isEmpty) return 'Username required';
  final v = value.trim();
  if (v.length < 3 || v.length > 20) return '3-20 characters';
  if (!RegExp(r'^[a-z0-9_]+$').hasMatch(v)) return 'Lowercase, numbers, _ only';
  if (takenUsernames != null && takenUsernames.contains(v)) return 'Username taken';
  return null;
}

String? validateDisplayName(String? value) {
  if (value == null || value.trim().isEmpty) return 'Display name required';
  final v = value.trim();
  if (v.length < 2 || v.length > 30) return '2-30 characters';
  return null;
}

String? validateBio(String? value) {
  if (value != null && value.length > 180) return 'Max 180 characters';
  return null;
}

String? validateItemName(String? value) {
  if (value == null || value.trim().isEmpty) return 'Name required';
  final v = value.trim();
  if (v.length < 2 || v.length > 50) return '2-50 characters';
  return null;
}

String? validateCategory(String? value) {
  if (value == null || value.trim().isEmpty) return 'Category required';
  if (!kCategories.any((c) => c.name == value)) return 'Invalid category';
  return null;
}

String? validateCaption(String? value) {
  if (value == null || value.trim().isEmpty) return 'Caption required';
  if (value.length > 500) return 'Max 500 characters';
  return null;
}

String? validateHashtags(String? value) {
  if (value != null && value.isNotEmpty) {
    final tags = value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    for (final tag in tags) {
      if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(tag)) {
        return 'Hashtags can only contain letters, numbers, and underscores.';
      }
    }
  }
  return null;
}
