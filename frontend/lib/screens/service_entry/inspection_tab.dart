import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../backend/models/inspection_item.dart';

class InspectionTab extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onPrev;
  final List<InspectionItem> items;
  final Function(InspectionItem) onUpdateItem;

  const InspectionTab({
      super.key, 
      required this.onNext, 
      required this.onPrev,
      required this.items,
      required this.onUpdateItem,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
                return _buildInspectionItem(context, items[index]);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onPrev,
                  child: const Text('PREV'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: onNext,
                  child: const Text('NEXT ▶'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInspectionItem(BuildContext context, InspectionItem item) {
    Color chipColor;
    IconData icon;
    Color textColor;

    switch (item.status) {
      case 'OK':
        chipColor = AppColors.statusOk.withOpacity(0.1);
        icon = Icons.check_circle;
        textColor = AppColors.statusOk;
        break;
      case 'Attention':
        chipColor = AppColors.statusWarning.withOpacity(0.1);
        icon = Icons.warning;
        textColor = AppColors.statusWarning;
        break;
      case 'Critical':
        chipColor = AppColors.statusCritical.withOpacity(0.1);
        icon = Icons.dangerous;
        textColor = AppColors.statusCritical;
        break;
      case 'Not Checked':
      default:
        chipColor = Colors.grey.withOpacity(0.1);
        icon = Icons.circle_outlined;
        textColor = Colors.grey;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(item.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.photoPaths.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: SizedBox(
                   height: 60,
                   child: ListView.separated(
                     scrollDirection: Axis.horizontal,
                     itemCount: item.photoPaths.length,
                     separatorBuilder: (_, __) => const SizedBox(width: 8),
                     itemBuilder: (context, index) {
                         return Container(
                           width: 60,
                           decoration: BoxDecoration(
                               color: Colors.grey[300],
                               borderRadius: BorderRadius.circular(8),
                               image: const DecorationImage(
                                   image: AssetImage('assets/placeholder_image.png'), // Placeholder
                                   fit: BoxFit.cover,
                               ),
                           ),
                           child: const Center(child: Icon(Icons.image, color: Colors.grey)),
                         );
                     },
                   ),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                icon: const Icon(Icons.camera_alt_outlined),
                onPressed: () {
                    // Mock adding photo
                    final newPaths = List<String>.from(item.photoPaths)..add('mock_path_${DateTime.now().millisecondsSinceEpoch}');
                    final newItem = InspectionItem(
                        name: item.name,
                        status: item.status,
                        notes: item.notes,
                        photoPaths: newPaths
                    );
                    onUpdateItem(newItem);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Photo attached (Mock)')));
                },
            ),
            InkWell(
              onTap: () => _cycleStatus(item),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: chipColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: textColor.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 16, color: textColor),
                    const SizedBox(width: 8),
                    Text(
                      item.status,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _cycleStatus(InspectionItem item) {
      const statuses = ['Not Checked', 'OK', 'Attention', 'Critical'];
      int currentIndex = statuses.indexOf(item.status);
      int nextIndex = (currentIndex + 1) % statuses.length;
      
      final newItem = InspectionItem(
          name: item.name,
          status: statuses[nextIndex],
          notes: item.notes,
          photoPaths: item.photoPaths,
      );
      
      onUpdateItem(newItem);
  }
}
