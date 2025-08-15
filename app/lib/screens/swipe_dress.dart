import 'package:flutter/material.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SwipeDressScreen extends StatefulWidget {
  const SwipeDressScreen({Key? key}) : super(key: key);

  @override
  State<SwipeDressScreen> createState() => _SwipeDressScreenState();
}

class _SwipeDressScreenState extends State<SwipeDressScreen> {
  List<Map<String, dynamic>> _garments = [];
  int _currentPage = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchGarments();
  }

  Future<void> _fetchGarments() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUserId;

      final response = await authProvider.postToApi('/v1/graphql', {
        'query': '''
          query GetGarments(
            $userId: uuid!,
            $offset: Int!
          ) {
            garments(
              where: {
                is_copy: {_eq: true},
                seed_user_id: {_neq: $userId}
              },
              limit: 20,
              offset: $offset
            ) {
              id
              mask_url
              texture_url
            }
          }
        ''',
        'variables': {
          'userId': userId,
          'offset': _currentPage * 20,
        },
      });

      if (response != null && response['data'] != null) {
        setState(() {
          _garments.addAll(List<Map<String, dynamic>>.from(response['data']['garments']));
          _currentPage++;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching garments: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addToCloset(String garmentId) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      await authProvider.postToApi('/v1/graphql', {
        'query': '''
          mutation AddToCloset($garmentId: uuid!) {
            insert_garment_copies_one(object: {
              garment_id: $garmentId,
              copy_type: "swiped"
            }) {
              id
            }
          }
        ''',
        'variables': {'garmentId': garmentId},
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to your closet!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding to closet: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Swipe Dresses'),
      ),
      body: _garments.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : TinderSwapCard(
              orientation: AmassOrientation.BOTTOM,
              totalNum: _garments.length,
              stackNum: 3,
              swipeEdge: 4.0,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              minWidth: MediaQuery.of(context).size.width * 0.8,
              minHeight: MediaQuery.of(context).size.height * 0.7,
              cardBuilder: (context, index) {
                final garment = _garments[index];
                return Card(
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
                );
              },
              swipeUpdateCallback: (DragUpdateDetails details, Alignment align) {
                if (align.x < 0) {
                  // Swiping left
                } else if (align.x > 0) {
                  // Swiping right
                }
              },
              swipeCompleteCallback: (CardSwipeOrientation orientation, int index) {
                if (orientation == CardSwipeOrientation.RIGHT) {
                  _addToCloset(_garments[index]['id']);
                }

                if (index == _garments.length - 1) {
                  _fetchGarments();
                }
              },
            ),
    );
  }
}
