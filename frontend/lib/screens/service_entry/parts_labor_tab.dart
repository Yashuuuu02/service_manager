import 'package:flutter/material.dart';
import '../../backend/models/part_used.dart';
import '../../theme/app_colors.dart';
import '../../widgets/inventory_picker_modal.dart';

class PartsLaborTab extends StatelessWidget {
  final List<PartUsed> parts;
  final Function(PartUsed) onAdd;
  final Function(PartUsed) onRemove;
  final Function(PartUsed, int) onUpdateQty; // item, newQty
  final VoidCallback onNext;
  final VoidCallback onPrev;

  const PartsLaborTab({
    super.key,
    required this.parts,
    required this.onAdd,
    required this.onRemove,
    required this.onUpdateQty,
    required this.onNext,
    required this.onPrev,
  });

  @override
  Widget build(BuildContext context) {
    // Separate into Parts and Labor for display
    final partsList = parts.where((p) => !p.isLabor).toList();
    final laborList = parts.where((p) => p.isLabor).toList();

    // Calculate total from all items
    final totalAmount = parts.fold(0.0, (sum, item) => sum + item.total);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Parts Replaced:', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              if (partsList.isEmpty) 
                 const Padding(padding: EdgeInsets.all(8.0), child: Text("No parts added.", style: TextStyle(color: Colors.grey))),
              ...partsList.map((item) => _buildPartRow(item)),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: () => _showAddDialog(context, isLabor: false),
                    icon: const Icon(Icons.search),
                    label: const Text('Pick Part'),
                  ),
                  TextButton.icon(
                    onPressed: () => _showManualEntryDialog(context, isLabor: false),
                    icon: const Icon(Icons.add),
                    label: const Text('Manual Entry'),
                  ),
                ],
              ),
              
              const Divider(height: 32),
              
              Text('Labor Charges:', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              if (laborList.isEmpty) 
                 const Padding(padding: EdgeInsets.all(8.0), child: Text("No labor charges.", style: TextStyle(color: Colors.grey))),
              ...laborList.map((item) => _buildPartRow(item)),
              
              TextButton.icon(
                onPressed: () => _showAddDialog(context, isLabor: true),
                icon: const Icon(Icons.add),
                label: const Text('Add Labor'),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surfaceVariant,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOTAL EST.', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('₹ ${totalAmount.toStringAsFixed(0)}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              )),
            ],
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

  Widget _buildPartRow(PartUsed item) {
    return Card(
      child: ListTile(
        title: Text(item.name),
        subtitle: Text('₹ ${item.price.toStringAsFixed(0)} x ${item.quantity} = ₹ ${item.total.toStringAsFixed(0)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!item.isLabor) ...[
               IconButton(
                 icon: const Icon(Icons.remove_circle_outline),
                 onPressed: () {
                   if (item.quantity > 1) {
                     onUpdateQty(item, item.quantity - 1);
                   } else {
                     onRemove(item); // Remove if qty goes to 0? Or keep at 1 and use delete button? 
                     // Let's stick to remove button for explicit removal, or decrement to remove
                   }
                 },
                 color: AppColors.secondary,
               ),
               Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
               IconButton(
                 icon: const Icon(Icons.add_circle_outline),
                 onPressed: () => onUpdateQty(item, item.quantity + 1),
                 color: AppColors.primary,
               ),
               const SizedBox(width: 8),
            ],
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.grey),
              onPressed: () => onRemove(item),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context, {required bool isLabor}) async {
    // For Labor, keep simple manual entry
    if (isLabor) {
      _showManualEntryDialog(context, isLabor: true);
      return;
    }

    // For Parts, ask: Pick from Inventory or Manual?
    // Actually, showing a bottom sheet choice is better or just defaulting to Picker with Manual option.
    // Let's open Picker directly.
    showModalBottomSheet(
      context: context, 
      isScrollControlled: true,
      builder: (ctx) => InventoryPickerModal(
        onSelect: (inventoryItem) {
          final newItem = PartUsed(
             name: inventoryItem.name,
             price: inventoryItem.price,
             quantity: 1,
             isLabor: false,
          );
          onAdd(newItem);
        },
      ),
    ).then((_) {
      // If nothing selected (just closed), maybe user wants manual? 
      // The modal has a "Manual Entry" button that just closes.
      // We can't easily detect "Manual Button Clicked" vs "Dismissed" unless we pass result.
      // Let's update modal to return a value if Manual.
      // Or easier: update the picker to just return result.
      // Actually, let's keep it simple: Picker handles selection. 
      // If user wants manual, they close and use a separate "Add Custom" button we can add to UI?
      // Or we can add "Or Manual" button in the tab itself.
    });
  }

  Future<void> _showManualEntryDialog(BuildContext context, {required bool isLabor}) async {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isLabor ? 'Add Labor Charge' : 'Add Custom Part'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(labelText: isLabor ? 'Service Name' : 'Part Name'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceCtrl,
              decoration: const InputDecoration(labelText: 'Price (₹)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && priceCtrl.text.isNotEmpty) {
                 final newItem = PartUsed(
                   name: nameCtrl.text,
                   price: double.tryParse(priceCtrl.text) ?? 0.0,
                   quantity: 1,
                   isLabor: isLabor,
                 );
                 onAdd(newItem);
                 Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
