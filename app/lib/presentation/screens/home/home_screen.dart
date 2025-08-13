import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/closet_provider.dart';
import '../../providers/feed_provider.dart';
import '../../providers/competition_provider.dart';
import 'feed/feed_tab.dart';
import 'closet/closet_tab.dart';
import 'competition/competition_tab.dart';
import 'profile/profile_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<String> _titles = ['Feed', 'Closet', 'Profile'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      Provider.of<FeedProvider>(context, listen: false).loadPosts(),
      Provider.of<ClosetProvider>(context, listen: false).loadItems(),
      Provider.of<CompetitionProvider>(context, listen: false).loadAll(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          if (_selectedIndex == 0) // Feed
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                // TODO: Navigate to CreatePostScreen
              },
            ),
          if (_selectedIndex == 1) // Closet
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                // TODO: Navigate to AddItemScreen
              },
            ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          FeedTab(
            feedProvider: Provider.of<FeedProvider>(context),
            authProvider: Provider.of<AuthProvider>(context),
            closetProvider: Provider.of<ClosetProvider>(context),
            competitionProvider: Provider.of<CompetitionProvider>(context),
          ),
          ClosetTab(),
          ProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checkroom_outlined),
            activeIcon: Icon(Icons.checkroom),
            label: 'Closet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
