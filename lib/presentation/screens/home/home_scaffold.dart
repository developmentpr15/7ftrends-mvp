import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class HomeScaffold extends StatefulWidget {
  const HomeScaffold({super.key});

  @override
  State<HomeScaffold> createState() => _HomeScaffoldState();
}

class _HomeScaffoldState extends State<HomeScaffold> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final email = context.watch<AuthProvider>().email ?? 'unknown';
    
    final tabs = <Widget>[
      const _CenterText('Home'),
      const _CenterText('Closet'),
      const _CenterText('Competitions'),
      _ProfileTab(email: email),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('7ftrends'),
        actions: [
          IconButton(
            onPressed: () => context.read<AuthProvider>().logout(),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: tabs[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.checkroom_outlined), label: 'Closet'),
          NavigationDestination(icon: Icon(Icons.emoji_events_outlined), label: 'Compete'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class _CenterText extends StatelessWidget {
  final String text;
  const _CenterText(this.text);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(text, style: const TextStyle(fontSize: 20)),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  final String email;
  const _ProfileTab({required this.email});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person, size: 80, color: Color(0xFF8B5CF6)),
          const SizedBox(height: 16),
          Text('Logged in as:', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text(email, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
