import 'package:flutter/material.dart';

import '../../models/closet_item.dart';
import '../widgets/closet_item_image.dart';

class ClosetPickerDialog extends StatelessWidget {
  final List<ClosetItem> closetItems;

  const ClosetPickerDialog({
    super.key,
    required this.closetItems,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose from Closet'),
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        width: double.maxFinite,
        child: closetItems.isEmpty
            ? const Center(
                child: Text(
                  'No items in your closet yet',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: closetItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final item = closetItems[index];
                  return InkWell(
                    onTap: () => Navigator.pop(context, item),
                    child: Row(
                      children: [
                        ClosetItemImage(
                          imageBase64: item.imageBase64,
                          size: 60,
                          name: item.name,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                item.category,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
