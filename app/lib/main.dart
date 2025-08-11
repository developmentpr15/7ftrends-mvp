import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SevenFTrendsApp());
}

const kPrimaryColor = Color(0xFF8B5CF6);

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
    // Simulate login: accept any email/password
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
    // Simulate signup: accept any
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
    // Color from initials for variety
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

  @override
  void initState() {
    super.initState();
    _session = LocalSessionService();
    _loadLastTab();
  }

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
                Center(child: Text('Feed (Coming soon)', style: Theme.of(context).textTheme.headlineSmall)),
                Center(child: Text('Explore (Coming soon)', style: Theme.of(context).textTheme.headlineSmall)),
                Center(child: Text('Notifications (Coming soon)', style: Theme.of(context).textTheme.headlineSmall)),
                ProfileTab(
                  profile: profile,
                  onEdit: () async {
                    // In a real app, this would be all usernames except the current user's
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

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
          // Placeholder for stats
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
