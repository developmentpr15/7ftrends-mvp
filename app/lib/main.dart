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
  final String email;
  final String username;
  final String displayName;
  final String bio;
  final String avatarUrl;

  UserProfile({
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
    String? email,
    String? username,
    String? displayName,
    String? bio,
    String? avatarUrl,
  }) {
    return UserProfile(
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'email': email,
        'username': username,
        'displayName': displayName,
        'bio': bio,
        'avatarUrl': avatarUrl,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
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

  @override
  void initState() {
    super.initState();
    _session = LocalSessionService();
    _closet = ClosetProvider();
    _loadLastTab();
    _closet.addListener(_onClosetChanged);
  }

  @override
  void dispose() {
    _closet.removeListener(_onClosetChanged);
    super.dispose();
  }

  void _onClosetChanged() => setState(() {});

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
                ClosetTab(provider: _closet),
                Center(child: Text('Explore (Coming soon)', style: Theme.of(context).textTheme.headlineSmall)),
                Center(child: Text('Notifications (Coming soon)', style: Theme.of(context).textTheme.headlineSmall)),
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
          BottomNavigationBarItem(icon: Icon(Icons.checkroom), label: 'Closet'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
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