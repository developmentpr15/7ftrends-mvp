import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SevenFTrendsApp());
}

const kPrimaryColor = Color(0xFF8B5CF6);
const kCategories = [
  ClosetCategory('All', Icons.apps),
  ClosetCategory('Tops', Icons.checkroom),
  ClosetCategory('Bottoms', Icons.format_align_justify),
  ClosetCategory('Dresses', Icons.checkroom),
  ClosetCategory('Shoes', Icons.directions_walk),
  ClosetCategory('Accessories', Icons.watch),
  ClosetCategory('Outerwear', Icons.ac_unit),
];

class SevenFTrendsApp extends StatelessWidget {
  const SevenFTrendsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '7ftrends',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        primaryColor: kPrimaryColor,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple)
            .copyWith(secondary: kPrimaryColor),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kPrimaryColor),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// --- MODELS ---

class UserProfile {
  final String userId; // Added userId
  final String email;
  final String username;
  final String displayName;
  final String bio;
  final String avatarUrl;

  UserProfile({
    required this.userId, // Added userId
    required this.email,
    required this.username,
    required this.displayName,
    required this.bio,
    required this.avatarUrl,
  });

  String get initials {
    if (displayName.trim().isNotEmpty) {
      final parts = displayName.trim().split(' ');
      if (parts.length == 1) {
        return parts[0].substring(0, 1).toUpperCase();
      } else {
        return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
      }
    }
    return username.isNotEmpty ? username.substring(0, 1).toUpperCase() : '';
  }

  UserProfile copyWith({
    String? userId, // Added userId
    String? email,
    String? username,
    String? displayName,
    String? bio,
    String? avatarUrl,
  }) {
    return UserProfile(
      userId: userId ?? this.userId, // Added userId
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId, // Added userId
        'email': email,
        'username': username,
        'displayName': displayName,
        'bio': bio,
        'avatarUrl': avatarUrl,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        userId: json['userId'] ?? '', // Added userId
        email: json['email'] ?? '',
        username: json['username'] ?? '',
        displayName: json['displayName'] ?? '',
        bio: json['bio'] ?? '',
        avatarUrl: json['avatarUrl'] ?? '',
      );
}

class ClosetItem {
  final String id;
  final String name;
  final String category;
  final String color;
  final String brand;
  final String imageBase64; // base64 string or empty
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
        id: json['id'],
        name: json['name'],
        category: json['category'],
        color: json['color'],
        brand: json['brand'],
        imageBase64: json['imageBase64'] ?? '',
        createdAt: DateTime.parse(json['createdAt']),
        tags: (json['tags'] as List).map((e) => e.toString()).toList(),
      );
}

class ClosetCategory {
  final String name;
  final IconData icon;
  const ClosetCategory(this.name, this.icon);
}

class FeedPost {
  final String id;
  final String userId;
  final String username;
  final String userAvatarUrl;
  final String imageData; // base64 string
  final String caption;
  final List<String> hashtags;
  final int likes;
  final bool likedByMe;
  final DateTime createdAt;
  final String? closetItemId; // optional

  FeedPost({
    required this.id,
    required this.userId,
    required this.username,
    required this.userAvatarUrl,
    required this.imageData,
    required this.caption,
    required this.hashtags,
    required this.likes,
    required this.likedByMe,
    required this.createdAt,
    this.closetItemId,
  });

  FeedPost copyWith({
    String? id,
    String? userId,
    String? username,
    String? userAvatarUrl,
    String? imageData,
    String? caption,
    List<String>? hashtags,
    int? likes,
    bool? likedByMe,
    DateTime? createdAt,
    String? closetItemId,
  }) {
    return FeedPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      imageData: imageData ?? this.imageData,
      caption: caption ?? this.caption,
      hashtags: hashtags ?? this.hashtags,
      likes: likes ?? this.likes,
      likedByMe: likedByMe ?? this.likedByMe,
      createdAt: createdAt ?? this.createdAt,
      closetItemId: closetItemId ?? this.closetItemId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'username': username,
        'userAvatarUrl': userAvatarUrl,
        'imageData': imageData,
        'caption': caption,
        'hashtags': hashtags,
        'likes': likes,
        'likedByMe': likedByMe,
        'createdAt': createdAt.toIso8601String(),
        'closetItemId': closetItemId,
      };

  factory FeedPost.fromJson(Map<String, dynamic> json) => FeedPost(
        id: json['id'],
        userId: json['userId'],
        username: json['username'],
        userAvatarUrl: json['userAvatarUrl'] ?? '',
        imageData: json['imageData'],
        caption: json['caption'],
        hashtags: (json['hashtags'] as List).map((e) => e.toString()).toList(),
        likes: json['likes'],
        likedByMe: json['likedByMe'],
        createdAt: DateTime.parse(json['createdAt']),
        closetItemId: json['closetItemId'],
      );
}

class Comment {
  final String id;
  final String postId;
  final String userId;
  final String text;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'postId': postId,
        'userId': userId,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: json['id'],
        postId: json['postId'],
        userId: json['userId'],
        text: json['text'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}

// --- SERVICES ---

class LocalSessionService {
  static const _profileKey = 'user_profile';
  static const _lastTabKey = 'last_tab_index';

  Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  Future<UserProfile?> loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_profileKey);
    if (jsonStr == null) return null;
    try {
      final jsonMap = jsonDecode(jsonStr);
      return UserProfile.fromJson(jsonMap);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
  }

  Future<void> saveLastTabIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastTabKey, index);
  }

  Future<int> loadLastTabIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lastTabKey) ?? 0;
  }
}

class LocalClosetService {
  static const _closetKey = 'closet_items';

  Future<List<ClosetItem>> loadClosetItems() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_closetKey);
    if (jsonStr == null) return [];
    try {
      final list = jsonDecode(jsonStr) as List;
      return list.map((e) => ClosetItem.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveClosetItems(List<ClosetItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_closetKey, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  Future<void> clearClosetItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_closetKey);
  }
}

class LocalFeedService {
  static const _feedKey = 'feed_posts';

  Future<List<FeedPost>> loadFeedPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_feedKey);
    if (jsonStr == null) return [];
    try {
      final list = jsonDecode(jsonStr) as List;
      return list.map((e) => FeedPost.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveFeedPosts(List<FeedPost> posts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_feedKey, jsonEncode(posts.map((e) => e.toJson()).toList()));
  }

  Future<void> clearFeedPosts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_feedKey);
  }
}

// --- PROVIDERS ---

class AuthProvider extends ChangeNotifier {
  UserProfile? _profile;
  bool _isLoading = false;
  String? _error;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final LocalSessionService _session = LocalSessionService();

  AuthProvider() {
    _loadSession();
  }

  Future<void> _loadSession() async {
    _isLoading = true;
    notifyListeners();
    _profile = await _session.loadUserProfile();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    _profile = UserProfile(
      userId: UniqueKey().toString(), // Generate unique ID for new user
      email: email,
      username: email.split('@')[0],
      displayName: '',
      bio: '',
      avatarUrl: '',
    );
    await _session.saveUserProfile(_profile!);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signup(String email, String password, String username) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    _profile = UserProfile(
      userId: UniqueKey().toString(), // Generate unique ID for new user
      email: email,
      username: username,
      displayName: '',
      bio: '',
      avatarUrl: '',
    );
    await _session.saveUserProfile(_profile!);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    await _session.clearUserProfile();
    _profile = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile updated) async {
    final prev = _profile;
    _profile = updated;
    notifyListeners();
    try {
      await _session.saveUserProfile(updated);
    } catch (e) {
      _profile = prev;
      notifyListeners();
      rethrow;
    }
  }
}

class ClosetProvider extends ChangeNotifier {
  final LocalClosetService _service = LocalClosetService();
  List<ClosetItem> _items = [];
  bool _isLoading = false;
  String _filterCategory = 'All';
  String _search = '';

  List<ClosetItem> get items => _filteredItems();
  bool get isLoading => _isLoading;
  String get filterCategory => _filterCategory;
  String get search => _search;

  ClosetProvider() {
    _load();
  }

  Future<void> _load() async {
    _isLoading = true;
    notifyListeners();
    _items = await _service.loadClosetItems();
    if (_items.isEmpty) {
      _items = _mockData();
      await _service.saveClosetItems(_items);
    }
    _isLoading = false;
    notifyListeners();
  }

  List<ClosetItem> _filteredItems() {
    var list = _items;
    if (_filterCategory != 'All') {
      list = list.where((e) => e.category == _filterCategory).toList();
    }
    if (_search.trim().isNotEmpty) {
      final q = _search.trim().toLowerCase();
      list = list.where((e) =>
          e.name.toLowerCase().contains(q) ||
          e.brand.toLowerCase().contains(q) ||
          e.tags.any((t) => t.toLowerCase().contains(q))).toList();
    }
    return list;
  }

  void setCategory(String category) {
    _filterCategory = category;
    notifyListeners();
  }

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  Future<void> addItem(ClosetItem item) async {
    _items.insert(0, item);
    notifyListeners();
    await _service.saveClosetItems(_items);
  }

  Future<void> updateItem(ClosetItem item) async {
    final idx = _items.indexWhere((e) => e.id == item.id);
    if (idx != -1) {
      _items[idx] = item;
      notifyListeners();
      await _service.saveClosetItems(_items);
    }
  }

  Future<void> deleteItem(String id) async {
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
    await _service.saveClosetItems(_items);
  }

  List<ClosetItem> _mockData() {
    return [
      ClosetItem(
        id: UniqueKey().toString(),
        name: 'White T-Shirt',
        category: 'Tops',
        color: 'White',
        brand: 'Uniqlo',
        imageBase64: '',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        tags: ['casual', 'summer'],
      ),
      ClosetItem(
        id: UniqueKey().toString(),
        name: 'Blue Jeans',
        category: 'Bottoms',
        color: 'Blue',
        brand: 'Levi\'s',
        imageBase64: '',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        tags: ['denim', 'classic'],
      ),
      ClosetItem(
        id: UniqueKey().toString(),
        name: 'Red Dress',
        category: 'Dresses',
        color: 'Red',
        brand: 'Zara',
        imageBase64: '',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        tags: ['party', 'evening'],
      ),
      ClosetItem(
        id: UniqueKey().toString(),
        name: 'Sneakers',
        category: 'Shoes',
        color: 'White',
        brand: 'Nike',
        imageBase64: '',
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        tags: ['sport', 'casual'],
      ),
    ];
  }
}

class FeedProvider extends ChangeNotifier {
  final LocalFeedService _service = LocalFeedService();
  List<FeedPost> _posts = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<FeedPost> get posts => _filteredPosts();
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  FeedProvider() {
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    _isLoading = true;
    notifyListeners();
    _posts = await _service.loadFeedPosts();
    if (_posts.isEmpty) {
      _posts = _mockFeedData();
      await _service.saveFeedPosts(_posts);
    }
    _isLoading = false;
    notifyListeners();
  }

  List<FeedPost> _filteredPosts() {
    if (_searchQuery.isEmpty) return _posts;
    final query = _searchQuery.toLowerCase();
    return _posts.where((post) {
      return post.caption.toLowerCase().contains(query) ||
             post.hashtags.any((tag) => tag.toLowerCase().contains(query)) ||
             post.username.toLowerCase().contains(query);
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addPost(FeedPost post) async {
    _posts.insert(0, post);
    notifyListeners();
    await _service.saveFeedPosts(_posts);
  }

  Future<void> toggleLike(String postId, String userId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      final liked = post.likedByMe;
      _posts[index] = post.copyWith(
        likes: liked ? post.likes - 1 : post.likes + 1,
        likedByMe: !liked,
      );
      notifyListeners();
      await _service.saveFeedPosts(_posts);
    }
  }

  Future<void> deletePost(String postId) async {
    _posts.removeWhere((p) => p.id == postId);
    notifyListeners();
    await _service.saveFeedPosts(_posts);
  }

  List<FeedPost> _mockFeedData() {
    return [
      FeedPost(
        id: UniqueKey().toString(),
        userId: 'user1',
        username: 'fashionista_gal',
        userAvatarUrl: 'https://picsum.photos/id/1005/50/50',
        imageData: '', // Placeholder, will be replaced with actual base64
        caption: 'Loving this new outfit! Perfect for a casual day out. #OOTD #casualstyle',
        hashtags: ['OOTD', 'casualstyle'],
        likes: 15,
        likedByMe: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        closetItemId: null,
      ),
      FeedPost(
        id: UniqueKey().toString(),
        userId: 'user2',
        username: 'style_guru',
        userAvatarUrl: 'https://picsum.photos/id/1011/50/50',
        imageData: '', // Placeholder
        caption: 'My go-to formal look. This red dress is a must-have! #formalwear #reddress',
        hashtags: ['formalwear', 'reddress'],
        likes: 30,
        likedByMe: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        closetItemId: null, // Assuming a red dress from closet
      ),
      FeedPost(
        id: UniqueKey().toString(),
        userId: 'user1',
        username: 'fashionista_gal',
        userAvatarUrl: 'https://picsum.photos/id/1005/50/50',
        imageData: '', // Placeholder
        caption: 'Street style vibes today. Comfort meets chic! #streetwear #fashion',
        hashtags: ['streetwear', 'fashion'],
        likes: 22,
        likedByMe: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        closetItemId: null,
      ),
      FeedPost(
        id: UniqueKey().toString(),
        userId: 'user3',
        username: 'trendsetter',
        userAvatarUrl: 'https://picsum.photos/id/1012/50/50',
        imageData: '', // Placeholder
        caption: 'New sneakers alert! So comfy and stylish. #sneakers #sporty',
        hashtags: ['sneakers', 'sporty'],
        likes: 45,
        likedByMe: false,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        closetItemId: null,
      ),
      FeedPost(
        id: UniqueKey().toString(),
        userId: 'user2',
        username: 'style_guru',
        userAvatarUrl: 'https://picsum.photos/id/1011/50/50',
        imageData: '', // Placeholder
        caption: 'Accessorizing is key! Love this new watch. #accessories #style',
        hashtags: ['accessories', 'style'],
        likes: 10,
        likedByMe: false,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        closetItemId: null,
      ),
      FeedPost(
        id: UniqueKey().toString(),
        userId: 'user4',
        username: 'minimalist_chic',
        userAvatarUrl: 'https://picsum.photos/id/1015/50/50',
        imageData: '', // Placeholder
        caption: 'Keeping it simple and elegant with a classic white tee. #minimalist #classic',
        hashtags: ['minimalist', 'classic'],
        likes: 18,
        likedByMe: true,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        closetItemId: null,
      ),
      FeedPost(
        id: UniqueKey().toString(),
        userId: 'user1',
        username: 'fashionista_gal',
        userAvatarUrl: 'https://picsum.photos/id/1005/50/50',
        imageData: '', // Placeholder
        caption: 'Ready for autumn with this cozy outerwear. #autumnfashion #outerwear',
        hashtags: ['autumnfashion', 'outerwear'],
        likes: 25,
        likedByMe: false,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        closetItemId: null,
      ),
      FeedPost(
        id: UniqueKey().toString(),
        userId: 'user3',
        username: 'trendsetter',
        userAvatarUrl: 'https://picsum.photos/id/1012/50/50',
        imageData: '', // Placeholder
        caption: 'Experimenting with new color palettes. What do you think? #colorblock #fashiontips',
        hashtags: ['colorblock', 'fashiontips'],
        likes: 35,
        likedByMe: false,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        closetItemId: null,
      ),
    ];
  }
}

// --- VALIDATION UTILS ---

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

// --- WIDGETS ---

class AvatarCircle extends StatelessWidget {
  final String? avatarUrl;
  final String initials;
  final double radius;

  const AvatarCircle({
    super.key,
    required this.avatarUrl,
    required this.initials,
    this.radius = 40,
  });

  @override
  Widget build(BuildContext context) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(avatarUrl!),
        backgroundColor: kPrimaryColor.withOpacity(0.2),
      );
    }
    final color = kPrimaryColor.withOpacity(0.8);
    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.7,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class ClosetItemImage extends StatelessWidget {
  final String imageBase64;
  final double size;
  final String name;
  const ClosetItemImage({super.key, required this.imageBase64, required this.size, required this.name});

  @override
  Widget build(BuildContext context) {
    if (imageBase64.isNotEmpty) {
      try {
        final bytes = base64Decode(imageBase64);
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            bytes,
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        );
      } catch (_) {}
    }
    // Placeholder: colored box with first letter
    return Container(
      width: size,
      height: size,
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
            fontSize: size * 0.5,
          ),
        ),
      ),
    );
  }
}

// --- SCREENS ---

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _scale = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
    Future.delayed(const Duration(seconds: 2), () async {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => AuthGate()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.checkroom, size: 64, color: kPrimaryColor),
                ),
                const SizedBox(height: 32),
                const Text(
                  '7ftrends',
                  style: TextStyle(
                    color: kPrimaryColor,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your fashion metaverse is ready to build!',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late AuthProvider _auth;

  @override
  void initState() {
    super.initState();
    _auth = AuthProvider();
    _auth.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    _auth.dispose();
    super.dispose();
  }

  void _onAuthChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_auth.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: kPrimaryColor)),
      );
    }
    if (_auth.profile == null) {
      return AuthScreen(auth: _auth);
    }
    return HomeScaffold(auth: _auth);
  }
}

class AuthScreen extends StatefulWidget {
  final AuthProvider auth;
  const AuthScreen({super.key, required this.auth});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

enum AuthMode { login, signup }

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  AuthMode _mode = AuthMode.login;
  String _email = '';
  String _password = '';
  String _username = '';
  String? _error;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _error = null);
    try {
      if (_mode == AuthMode.login) {
        await widget.auth.login(_email.trim(), _password);
      } else {
        await widget.auth.signup(_email.trim(), _password, _username.trim());
      }
    } catch (e) {
      setState(() => _error = 'Something went wrong');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = widget.auth.isLoading;
    return Scaffold(
      appBar: AppBar(
        title: Text(_mode == AuthMode.login ? 'Sign In' : 'Sign Up'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(_error!, style: const TextStyle(color: Colors.red)),
                  ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  enabled: !isLoading,
                  validator: (v) => v != null && v.contains('@') ? null : 'Enter a valid email',
                  onChanged: (v) => _email = v,
                ),
                const SizedBox(height: 16),
                if (_mode == AuthMode.signup)
                  Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Username'),
                        enabled: !isLoading,
                        validator: (v) => validateUsername(v),
                        onChanged: (v) => _username = v,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  enabled: !isLoading,
                  validator: (v) => v != null && v.length >= 6 ? null : 'Min 6 characters',
                  onChanged: (v) => _password = v,
                ),
                const SizedBox(height: 24),
                isLoading
                    ? const CircularProgressIndicator(color: kPrimaryColor)
                    : ElevatedButton(
                        onPressed: _submit,
                        child: Text(_mode == AuthMode.login ? 'Login' : 'Sign Up'),
                      ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          setState(() {
                            _mode = _mode == AuthMode.login ? AuthMode.signup : AuthMode.login;
                          });
                        },
                  child: Text(_mode == AuthMode.login
                      ? "Don't have an account? Sign Up"
                      : "Already have an account? Sign In"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScaffold extends StatefulWidget {
  final AuthProvider auth;
  const HomeScaffold({super.key, required this.auth});

  @override
  State<HomeScaffold> createState() => _HomeScaffoldState();
}

class _HomeScaffoldState extends State<HomeScaffold> {
  int _tabIndex = 0;
  bool _loadingTab = false;
  late LocalSessionService _session;
  late ClosetProvider _closet;
  late FeedProvider _feed;

  @override
  void initState() {
    super.initState();
    _session = LocalSessionService();
    _closet = ClosetProvider();
    _feed = FeedProvider();
    _loadLastTab();
    _closet.addListener(_onClosetChanged);
    _feed.addListener(_onFeedChanged);
  }

  @override
  void dispose() {
    _closet.removeListener(_onClosetChanged);
    _feed.removeListener(_onFeedChanged);
    super.dispose();
  }

  void _onClosetChanged() => setState(() {});
  void _onFeedChanged() => setState(() {});

  Future<void> _loadLastTab() async {
    final idx = await _session.loadLastTabIndex();
    setState(() => _tabIndex = idx);
  }

  void _onTabChanged(int idx) async {
    setState(() {
      _tabIndex = idx;
      _loadingTab = true;
    });
    await _session.saveLastTabIndex(idx);
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() => _loadingTab = false);
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.auth.profile!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('7ftrends'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: widget.auth.isLoading
                ? null
                : () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Logout?'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await widget.auth.logout();
                    }
                  },
          ),
        ],
      ),
      body: _loadingTab
          ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
          : IndexedStack(
              index: _tabIndex,
              children: [
                FeedTab(
                  feedProvider: _feed,
                  authProvider: widget.auth,
                  closetProvider: _closet,
                ),
                ClosetTab(provider: _closet),
                Center(child: Text('Competitions (Coming soon)', style: Theme.of(context).textTheme.headlineSmall)),
                ProfileTab(
                  profile: profile,
                  onEdit: () async {
                    final takenUsernames = {profile.username};
                    final updated = await Navigator.of(context).push<UserProfile>(
                      MaterialPageRoute(
                        builder: (_) => ProfileEditScreen(
                          initial: profile,
                          takenUsernames: takenUsernames,
                        ),
                      ),
                    );
                    if (updated != null) {
                      try {
                        await widget.auth.updateProfile(updated);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profile updated!'),
                              backgroundColor: kPrimaryColor,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to update profile.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onTabChanged,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.rss_feed), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.checkroom), label: 'Closet'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Competitions'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// --- FEED TAB & RELATED SCREENS ---

class FeedTab extends StatefulWidget {
  final FeedProvider feedProvider;
  final AuthProvider authProvider;
  final ClosetProvider closetProvider;

  const FeedTab({
    super.key,
    required this.feedProvider,
    required this.authProvider,
    required this.closetProvider,
  });

  @override
  State<FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends State<FeedTab> {
  @override
  void initState() {
    super.initState();
    widget.feedProvider.addListener(_onFeedChanged);
  }

  @override
  void dispose() {
    widget.feedProvider.removeListener(_onFeedChanged);
    super.dispose();
  }

  void _onFeedChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final feedProvider = widget.feedProvider;
    final authProvider = widget.authProvider;
    final closetProvider = widget.closetProvider;
    final currentUser = authProvider.profile!;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search posts by caption, hashtag, or username',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              onChanged: feedProvider.setSearchQuery,
            ),
          ),
          Expanded(
            child: feedProvider.isLoading
                ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
                : feedProvider.posts.isEmpty
                    ? const Center(child: Text('No posts yet. Be the first to share!'))
                    : ListView.builder(
                        itemCount: feedProvider.posts.length,
                        itemBuilder: (context, index) {
                          final post = feedProvider.posts[index];
                          return PostCard(
                            post: post,
                            currentUser: currentUser,
                            onLikeToggle: (postId) => feedProvider.toggleLike(postId, currentUser.userId),
                            onDelete: (postId) async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete Post?'),
                                  content: const Text('Are you sure you want to delete this post?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await feedProvider.deletePost(postId);
                              }
                            },
                            onViewDetails: (post) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PostDetailScreen(
                                    post: post,
                                    currentUser: currentUser,
                                    onLikeToggle: (postId) => feedProvider.toggleLike(postId, currentUser.userId),
                                    onDelete: (postId) async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Delete Post?'),
                                          content: const Text('Are you sure you want to delete this post?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx, false),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () => Navigator.pop(ctx, true),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await feedProvider.deletePost(postId);
                                        Navigator.pop(context); // Pop detail screen
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimaryColor,
        child: const Icon(Icons.add),
        onPressed: () async {
          final newPost = await Navigator.of(context).push<FeedPost>(
            MaterialPageRoute(
              builder: (_) => CreatePostScreen(
                currentUser: currentUser,
                closetItems: closetProvider.items,
              ),
            ),
          );
          if (newPost != null) {
            await feedProvider.addPost(newPost);
          }
        },
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final FeedPost post;
  final UserProfile currentUser;
  final ValueChanged<String> onLikeToggle;
  final ValueChanged<String> onDelete;
  final ValueChanged<FeedPost> onViewDetails;

  const PostCard({
    super.key,
    required this.post,
    required this.currentUser,
    required this.onLikeToggle,
    required this.onDelete,
    required this.onViewDetails,
  });

  String _timeAgo(DateTime date) {
    final Duration diff = DateTime.now().difference(date);
    if (diff.inDays > 365) {
      return '${(diff.inDays / 365).floor()}y ago';
    } else if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()}mo ago';
    } else if (diff.inDays > 7) {
      return '${(diff.inDays / 7).floor()}w ago';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                AvatarCircle(
                  avatarUrl: post.userAvatarUrl,
                  initials: post.username.isNotEmpty ? post.username[0].toUpperCase() : '?',
                  radius: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.username,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _timeAgo(post.createdAt),
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (post.userId == currentUser.userId)
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (ctx) => SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.delete, color: Colors.red),
                                title: const Text('Delete Post', style: TextStyle(color: Colors.red)),
                                onTap: () {
                                  Navigator.pop(ctx);
                                  onDelete(post.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          if (post.imageData.isNotEmpty)
            GestureDetector(
              onDoubleTap: () => onLikeToggle(post.id),
              child: Image.memory(
                base64Decode(post.imageData),
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 300,
                  color: Colors.grey[200],
                  child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        post.likedByMe ? Icons.favorite : Icons.favorite_border,
                        color: post.likedByMe ? Colors.red : Colors.grey,
                      ),
                      onPressed: () => onLikeToggle(post.id),
                    ),
                    Text('${post.likes} likes'),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.comment_outlined),
                      onPressed: () => onViewDetails(post),
                    ),
                    const Text('0 comments'), // Placeholder for comments count
                  ],
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${post.username} ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: post.caption),
                    ],
                  ),
                ),
                if (post.hashtags.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      post.hashtags.map((e) => '#$e').join(' '),
                      style: const TextStyle(color: kPrimaryColor),
                    ),
                  ),
                if (post.closetItemId != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Wearing: ${post.closetItemId}', // This should ideally show the item name
                      style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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

  Future<void> _selectFromCloset() async {
    final selected = await Navigator.of(context).push<ClosetItem>(
      MaterialPageRoute(
        builder: (_) => ClosetPickerDialog(closetItems: widget.closetItems),
      ),
    );
    if (selected != null) {
      setState(() {
        _selectedClosetItem = selected;
        _imageData = selected.imageBase64; // Use image from closet item
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image for your post.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final newPost = FeedPost(
      id: UniqueKey().toString(),
      userId: widget.currentUser.userId, // Assuming UserProfile has a userId
      username: widget.currentUser.username,
      userAvatarUrl: widget.currentUser.avatarUrl,
      imageData: _imageData,
      caption: _caption.trim(),
      hashtags: _hashtags.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      likes: 0,
      likedByMe: false,
      createdAt: DateTime.now(),
      closetItemId: _selectedClosetItem?.id,
    );

    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    setState(() => _isLoading = false);
    if (mounted) Navigator.of(context).pop(newPost);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Post'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                if (_imageData.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      base64Decode(_imageData),
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 200,
                        height: 200,
                        color: Colors.grey[200],
                        child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(Icons.image, size: 60, color: Colors.grey),
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _pickImage,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload New Image'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _selectFromCloset,
                      icon: const Icon(Icons.checkroom),
                      label: const Text('From Closet'),
                    ),
                  ],
                ),
                if (_selectedClosetItem != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Selected from closet: ${_selectedClosetItem!.name}',
                      style: const TextStyle(fontStyle: FontStyle.italic, color: kPrimaryColor),
                    ),
                  ),
                const SizedBox(height: 24),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Caption'),
                  maxLines: 3,
                  maxLength: 500,
                  enabled: !_isLoading,
                  validator: validateCaption,
                  onChanged: (v) => _caption = v,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Hashtags (comma separated, e.g., fashion, OOTD)'),
                  enabled: !_isLoading,
                  validator: validateHashtags,
                  onChanged: (v) => _hashtags = v,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Post'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ClosetPickerDialog extends StatelessWidget {
  final List<ClosetItem> closetItems;

  const ClosetPickerDialog({super.key, required this.closetItems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select from Closet'),
        centerTitle: true,
      ),
      body: closetItems.isEmpty
          ? const Center(child: Text('Your closet is empty. Add items first!'))
          : ListView.builder(
              itemCount: closetItems.length,
              itemBuilder: (context, index) {
                final item = closetItems[index];
                return ListTile(
                  leading: ClosetItemImage(
                    imageBase64: item.imageBase64,
                    size: 40,
                    name: item.name,
                  ),
                  title: Text(item.name),
                  subtitle: Text(item.category),
                  onTap: () {
                    Navigator.of(context).pop(item);
                  },
                );
              },
            ),
    );
  }
}

class PostDetailScreen extends StatelessWidget {
  final FeedPost post;
  final UserProfile currentUser;
  final ValueChanged<String> onLikeToggle;
  final ValueChanged<String> onDelete;

  const PostDetailScreen({
    super.key,
    required this.post,
    required this.currentUser,
    required this.onLikeToggle,
    required this.onDelete,
  });

  String _timeAgo(DateTime date) {
    final Duration diff = DateTime.now().difference(date);
    if (diff.inDays > 365) {
      return '${(diff.inDays / 365).floor()}y ago';
    } else if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()}mo ago';
    } else if (diff.inDays > 7) {
      return '${(diff.inDays / 7).floor()}w ago';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  AvatarCircle(
                    avatarUrl: post.userAvatarUrl,
                    initials: post.username.isNotEmpty ? post.username[0].toUpperCase() : '?',
                    radius: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.username,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _timeAgo(post.createdAt),
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  if (post.userId == currentUser.userId)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => onDelete(post.id),
                    ),
                ],
              ),
            ),
            if (post.imageData.isNotEmpty)
              Image.memory(
                base64Decode(post.imageData),
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 300,
                  color: Colors.grey[200],
                  child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          post.likedByMe ? Icons.favorite : Icons.favorite_border,
                          color: post.likedByMe ? Colors.red : Colors.grey,
                        ),
                        onPressed: () => onLikeToggle(post.id),
                      ),
                      Text('${post.likes} likes'),
                      const SizedBox(width: 16),
                      const Icon(Icons.comment_outlined),
                      const Text('0 comments'), // Placeholder for comments count
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${post.username} ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: post.caption),
                      ],
                    ),
                  ),
                  if (post.hashtags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        post.hashtags.map((e) => '#$e').join(' '),
                        style: const TextStyle(color: kPrimaryColor),
                      ),
                    ),
                  if (post.closetItemId != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Wearing: ${post.closetItemId}', // This should ideally show the item name
                        style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
            // Comments section (scaffold only)
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Comments',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text('No comments yet.'), // Placeholder
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- CLOSET TAB & RELATED SCREENS ---

class ClosetTab extends StatefulWidget {
  final ClosetProvider provider;
  const ClosetTab({super.key, required this.provider});

  @override
  State<ClosetTab> createState() => _ClosetTabState();
}

class _ClosetTabState extends State<ClosetTab> {
  @override
  void initState() {
    super.initState();
    widget.provider.addListener(_onProviderChanged);
  }

  @override
  void dispose() {
    widget.provider.removeListener(_onProviderChanged);
    super.dispose();
  }

  void _onProviderChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    return Scaffold(
      body: Column(
        children: [
          _ClosetCategoryChips(
            selected: provider.filterCategory,
            onSelected: provider.setCategory,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name, brand, or tag',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              onChanged: provider.setSearch,
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
                : _ClosetGrid(
                    items: provider.items,
                    onTap: (item) async {
                      await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => ItemDetailSheet(
                          item: item,
                          onEdit: (updated) async {
                            await provider.updateItem(updated);
                            Navigator.pop(context);
                          },
                          onDelete: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete Item?'),
                                content: const Text('Are you sure you want to delete this item?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await provider.deleteItem(item.id);
                              Navigator.pop(context);
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimaryColor,
        child: const Icon(Icons.add),
        onPressed: () async {
          final newItem = await Navigator.of(context).push<ClosetItem>(
            MaterialPageRoute(
              builder: (_) => AddItemScreen(),
            ),
          );
          if (newItem != null) {
            await provider.addItem(newItem);
          }
        },
      ),
    );
  }
}

class _ClosetCategoryChips extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;
  const _ClosetCategoryChips({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: kCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = kCategories[i];
          final isSelected = selected == cat.name;
          return ChoiceChip(
            label: Row(
              children: [
                Icon(cat.icon, size: 18, color: isSelected ? Colors.white : kPrimaryColor),
                const SizedBox(width: 4),
                Text(cat.name),
              ],
            ),
            selected: isSelected,
            selectedColor: kPrimaryColor,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(color: isSelected ? Colors.white : kPrimaryColor),
            onSelected: (_) => onSelected(cat.name),
          );
        },
      ),
    );
  }
}

class _ClosetGrid extends StatelessWidget {
  final List<ClosetItem> items;
  final ValueChanged<ClosetItem> onTap;
  const _ClosetGrid({required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = MediaQuery.of(context).size.width > 900
        ? 3
        : MediaQuery.of(context).size.width > 600
            ? 2
            : 1;
    return items.isEmpty
        ? const Center(child: Text('No items found.'))
        : GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              return GestureDetector(
                onTap: () => onTap(item),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClosetItemImage(
                        imageBase64: item.imageBase64,
                        size: 120,
                        name: item.name,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: kPrimaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.category,
                            style: const TextStyle(color: kPrimaryColor, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }
}

class AddItemScreen extends StatefulWidget {
  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _category = '';
  String _color = '';
  String _brand = '';
  String _imageBase64 = '';
  String _tags = '';
  bool _isLoading = false;
  String? _error;

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
        _imageBase64 = base64Encode(bytes);
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    await Future.delayed(const Duration(milliseconds: 500));
    final item = ClosetItem(
      id: UniqueKey().toString(),
      name: _name.trim(),
      category: _category,
      color: _color.trim(),
      brand: _brand.trim(),
      imageBase64: _imageBase64,
      createdAt: DateTime.now(),
      tags: _tags.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
    );
    setState(() => _isLoading = false);
    if (mounted) Navigator.of(context).pop(item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Closet Item'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(_error!, style: const TextStyle(color: Colors.red)),
                  ),
                GestureDetector(
                  onTap: _isLoading ? null : _pickImage,
                  child: ClosetItemImage(
                    imageBase64: _imageBase64,
                    size: 120,
                    name: _name,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Name'),
                  enabled: !_isLoading,
                  validator: validateItemName,
                  onChanged: (v) => _name = v,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Category'),
                  value: _category.isEmpty ? null : _category,
                  items: kCategories
                      .where((c) => c.name != 'All')
                      .map((c) => DropdownMenuItem(
                            value: c.name,
                            child: Text(c.name),
                          ))
                      .toList(),
                  onChanged: _isLoading ? null : (v) => setState(() => _category = v ?? ''),
                  validator: validateCategory,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Color'),
                  enabled: !_isLoading,
                  onChanged: (v) => _color = v,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Brand'),
                  enabled: !_isLoading,
                  onChanged: (v) => _brand = v,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Tags (comma separated)'),
                  enabled: !_isLoading,
                  onChanged: (v) => _tags = v,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Add Item'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                Navigator.of(context).pop();
                              },
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ItemDetailSheet extends StatelessWidget {
  final ClosetItem item;
  final ValueChanged<ClosetItem> onEdit;
  final VoidCallback onDelete;

  const ItemDetailSheet({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: ClosetItemImage(
                    imageBase64: item.imageBase64,
                    size: 140,
                    name: item.name,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: kPrimaryColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.category,
                      style: const TextStyle(color: kPrimaryColor, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (item.brand.isNotEmpty)
                  Text('Brand: ${item.brand}', style: const TextStyle(fontSize: 16)),
                if (item.color.isNotEmpty)
                  Text('Color: ${item.color}', style: const TextStyle(fontSize: 16)),
                if (item.tags.isNotEmpty)
                  Text('Tags: ${item.tags.join(', ')}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 12),
                Text(
                  'Added: ${item.createdAt.toLocal().toString().split(' ').first}',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () async {
                    final updated = await Navigator.of(context).push<ClosetItem>(
                      MaterialPageRoute(
                        builder: (_) => EditItemScreen(item: item),
                      ),
                    );
                    if (updated != null) {
                      onEdit(updated);
                    }
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class EditItemScreen extends StatefulWidget {
  final ClosetItem item;
  const EditItemScreen({super.key, required this.item});

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _category;
  late String _color;
  late String _brand;
  late String _imageBase64;
  late String _tags;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _name = widget.item.name;
    _category = widget.item.category;
    _color = widget.item.color;
    _brand = widget.item.brand;
    _imageBase64 = widget.item.imageBase64;
    _tags = widget.item.tags.join(', ');
  }

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
        _imageBase64 = base64Encode(bytes);
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    await Future.delayed(const Duration(milliseconds: 500));
    final updated = widget.item.copyWith(
      name: _name.trim(),
      category: _category,
      color: _color.trim(),
      brand: _brand.trim(),
      imageBase64: _imageBase64,
      tags: _tags.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
    );
    setState(() => _isLoading = false);
    if (mounted) Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Closet Item'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(_error!, style: const TextStyle(color: Colors.red)),
                  ),
                GestureDetector(
                  onTap: _isLoading ? null : _pickImage,
                  child: ClosetItemImage(
                    imageBase64: _imageBase64,
                    size: 120,
                    name: _name,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: _name,
                  decoration: const InputDecoration(labelText: 'Name'),
                  enabled: !_isLoading,
                  validator: validateItemName,
                  onChanged: (v) => _name = v,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Category'),
                  value: _category.isEmpty ? null : _category,
                  items: kCategories
                      .where((c) => c.name != 'All')
                      .map((c) => DropdownMenuItem(
                            value: c.name,
                            child: Text(c.name),
                          ))
                      .toList(),
                  onChanged: _isLoading ? null : (v) => setState(() => _category = v ?? ''),
                  validator: validateCategory,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: _color,
                  decoration: const InputDecoration(labelText: 'Color'),
                  enabled: !_isLoading,
                  onChanged: (v) => _color = v,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: _brand,
                  decoration: const InputDecoration(labelText: 'Brand'),
                  enabled: !_isLoading,
                  onChanged: (v) => _brand = v,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: _tags,
                  decoration: const InputDecoration(labelText: 'Tags (comma separated)'),
                  enabled: !_isLoading,
                  onChanged: (v) => _tags = v,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Save'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                Navigator.of(context).pop();
                              },
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- PROFILE TAB (unchanged from Day 2) ---

class ProfileTab extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onEdit;

  const ProfileTab({super.key, required this.profile, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AvatarCircle(
            avatarUrl: profile.avatarUrl,
            initials: profile.initials,
            radius: 48,
          ),
          const SizedBox(height: 16),
          Text(
            profile.displayName.isNotEmpty ? profile.displayName : profile.username,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kPrimaryColor),
          ),
          const SizedBox(height: 8),
          Text(
            '@${profile.username}',
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 12),
          if (profile.bio.isNotEmpty)
            Text(
              profile.bio,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          if (profile.bio.isNotEmpty) const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatBox(label: 'Posts', value: '0'),
              const SizedBox(width: 24),
              _StatBox(label: 'Followers', value: '0'),
              const SizedBox(width: 24),
              _StatBox(label: 'Following', value: '0'),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profile'),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  const _StatBox({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

class ProfileEditScreen extends StatefulWidget {
  final UserProfile initial;
  final Set<String> takenUsernames;
  const ProfileEditScreen({super.key, required this.initial, required this.takenUsernames});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _username;
  late String _displayName;
  late String _bio;
  late String _avatarUrl;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _username = widget.initial.username;
    _displayName = widget.initial.displayName;
    _bio = widget.initial.bio;
    _avatarUrl = widget.initial.avatarUrl;
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final updated = widget.initial.copyWith(
      username: _username.trim(),
      displayName: _displayName.trim(),
      bio: _bio.trim(),
      avatarUrl: _avatarUrl.trim(),
    );
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (mounted) Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(_error!, style: const TextStyle(color: Colors.red)),
                  ),
                AvatarCircle(
                  avatarUrl: _avatarUrl,
                  initials: _displayName.isNotEmpty
                      ? _displayName.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
                      : _username.substring(0, 1).toUpperCase(),
                  radius: 40,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _username,
                  decoration: const InputDecoration(labelText: 'Username'),
                  enabled: !_isLoading,
                  validator: (v) => validateUsername(v, takenUsernames: widget.takenUsernames),
                  onChanged: (v) => _username = v,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _displayName,
                  decoration: const InputDecoration(labelText: 'Display Name'),
                  enabled: !_isLoading,
                  validator: validateDisplayName,
                  onChanged: (v) => _displayName = v,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _bio,
                  decoration: const InputDecoration(labelText: 'Bio'),
                  enabled: !_isLoading,
                  maxLines: 3,
                  maxLength: 180,
                  validator: validateBio,
                  onChanged: (v) => _bio = v,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _avatarUrl,
                  decoration: const InputDecoration(labelText: 'Avatar URL (optional)'),
                  enabled: !_isLoading,
                  onChanged: (v) => _avatarUrl = v,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _save,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Save'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                Navigator.of(context).pop();
                              },
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- END OF FILE ---
