
class UserProfile {
  final String userId;
  final String email;
  final String username;
  final String displayName;
  final String bio;
  final String avatarUrl;
  final DateTime createdAt;

  UserProfile({
    required this.userId,
    required this.email,
    required this.username,
    required this.displayName,
    required this.bio,
    required this.avatarUrl,
    required this.createdAt,
  });

  UserProfile copyWith({
    String? userId,
    String? email,
    String? username,
    String? displayName,
    String? bio,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      displayName: json['displayName'] ?? '',
      bio: json['bio'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'email': email,
    'username': username,
    'displayName': displayName,
    'bio': bio,
    'avatarUrl': avatarUrl,
  };

  String get initials {
    if (displayName.isNotEmpty) {
      return displayName.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').join().toUpperCase();
    }
    return username.isNotEmpty ? username[0].toUpperCase() : '?';
  }
}
