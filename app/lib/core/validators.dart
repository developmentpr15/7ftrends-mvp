String? validateUsername(String? value) {
  if (value == null || value.trim().isEmpty) return 'Username required';
  if (value.length < 3) return 'Username too short';
  if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) return 'Only letters, numbers, _ allowed';
  return null;
}

String? validateDisplayName(String? value) {
  if (value == null || value.trim().isEmpty) return 'Display name required';
  if (value.length < 2) return 'Display name too short';
  return null;
}

String? validateBio(String? value) {
  if (value != null && value.length > 160) return 'Bio too long';
  return null;
}

String? validateItemName(String? value) {
  if (value == null || value.trim().isEmpty) return 'Item name required';
  if (value.length < 2) return 'Item name too short';
  return null;
}

String? validateCategory(String? value) {
  if (value == null || value.trim().isEmpty) return 'Category required';
  return null;
}

String? validateCaption(String? value) {
  if (value != null && value.length > 2200) return 'Caption too long';
  return null;
}

String? validateHashtags(String? value) {
  if (value != null && value.isNotEmpty && !RegExp(r'^#[a-zA-Z0-9_]+( #[a-zA-Z0-9_]+)*\$').hasMatch(value.trim())) {
    return 'Hashtags must start with # and be separated by spaces';
  }
  return null;
}
