import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class MyCopiesScreen extends StatefulWidget {
  const MyCopiesScreen({Key? key}) : super(key: key);

  @override
  State<MyCopiesScreen> createState() => _MyCopiesScreenState();
}

class _MyCopiesScreenState extends State<MyCopiesScreen> {
  List<Map<String, dynamic>> _garments = [];

  @override
  void initState() {
    super.initState();
    _fetchGarments();
  }

  Future<void> _fetchGarments() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUserId;

      final response = await authProvider.postToApi('/v1/graphql', {
        'query': '''
          query GetGarments($userId: uuid!) {
            garments(where: {seed_user_id: {_eq: $userId}}) {
              id
              mask_url
              texture_url
            }
          }
        ''',
        'variables': {'userId': userId},
      });

      if (response != null && response['data'] != null) {
        setState(() {
          _garments = List<Map<String, dynamic>>.from(response['data']['garments']);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching garments: $e')),
      );
    }
  }

  Future<void> _deleteGarment(String garmentId) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      await authProvider.postToApi('/v1/graphql', {
        'query': '''
          mutation DeleteGarment($garmentId: uuid!) {
            delete_garments_by_pk(id: $garmentId) {
              id
            }
          }
        ''',
        'variables': {'garmentId': garmentId},
      });

      setState(() {
        _garments.removeWhere((garment) => garment['id'] == garmentId);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting garment: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Copies'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _garments.length,
          itemBuilder: (context, index) {
            final garment = _garments[index];
            return GestureDetector(
              onLongPress: () => _deleteGarment(garment['id']),
              child: Card(
                child: Column(
                  children: [
                    Expanded(
                      child: Image.network(
                        garment['mask_url'],
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Garment ID: ${garment['id']}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
