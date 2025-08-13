import 'package:flutter/material.dart';

import '../../../presentation/providers/auth_provider.dart';
import '../../../presentation/providers/closet_provider.dart';
import '../../../presentation/providers/feed_provider.dart';
import '../../../presentation/providers/competition_provider.dart';
import '../../../services/local_session_service.dart';
import '../../../shared/constants.dart';
import '../feed/feed_tab.dart';
import '../closet_tab.dart';
import '../competition_tab.dart';
import '../profile_tab.dart';

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
  late CompetitionProvider _competition;

  @override
  void initState() {
    super.initState();
    _session = LocalSessionService();
    _closet = ClosetProvider();
    _feed = FeedProvider();
    _competition = CompetitionProvider();
    _loadLastTab();
    _closet.addListener(_onProviderChanged);
    _feed.addListener(_onProviderChanged);
    _competition.addListener(_onProviderChanged);
  }

  @override
  void dispose() {
    _closet.removeListener(_onProviderChanged);
    _feed.removeListener(_onProviderChanged);
    _competition.removeListener(_onProviderChanged);
    _closet.dispose();
    _feed.dispose();
    _competition.dispose();
    super.dispose();
  }

  void _onProviderChanged() => setState(() {});

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
                  competitionProvider: _competition,
                ),
                ClosetTab(provider: _closet),
                CompetitionsTab(
                  provider: _competition,
                  authProvider: widget.auth,
                ),
                ProfileTab(
                  profile: profile,
                  onEdit: () async {
                    final takenUsernames = {profile['username']};
                    final updated = await Navigator.of(context).push<Map<String, dynamic>>(
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
