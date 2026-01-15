import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../backend/models/inventory_item.dart';
import '../backend/providers/service_provider.dart';
import '../theme/app_colors.dart';

class InventoryPickerModal extends StatefulWidget {
  final Function(InventoryItem) onSelect;

  const InventoryPickerModal({super.key, required this.onSelect});

  @override
  State<InventoryPickerModal> createState() => _InventoryPickerModalState();
}

class _InventoryPickerModalState extends State<InventoryPickerModal> {
  String _searchQuery = "";
  List<InventoryItem> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    // Load inventory if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ServiceProvider>();
      provider.loadInventory().then((_) {
        setState(() {
          _filteredItems = List.from(provider.inventory);
        });
      });
    });
  }

  void _filterItems(String query) {
    final provider = context.read<ServiceProvider>();
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredItems = List.from(provider.inventory);
      } else {
        _filteredItems = provider.inventory
            .where((item) => item.name.toLowerCase().contains(query.toLowerCase()) || 
                             item.partNumber.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 16, 
        left: 16, 
        right: 16, 
        bottom: MediaQuery.of(context).viewInsets.bottom + 16
      ),
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Select Part', style: Theme.of(context).textTheme.titleLarge),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search items...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Theme.of(context).cardColor,
            ),
            onChanged: _filterItems,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _filteredItems.isEmpty 
              ? Center(child: Text(_searchQuery.isEmpty ? 'Loading inventory...' : 'No items found.'))
              : ListView.separated(
                  itemCount: _filteredItems.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = _filteredItems[index];
                    final isLowStock = item.trackStock && item.quantity <= item.minStockLevel;
                    
                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text(item.partNumber.isNotEmpty ? 'SKU: ${item.partNumber}' : 'Price: ₹${item.price.toStringAsFixed(0)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                           Column(
                             mainAxisAlignment: MainAxisAlignment.center,
                             crossAxisAlignment: CrossAxisAlignment.end,
                             children: [
                               Text('₹ ${item.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                               if (item.trackStock)
                                 Text('${item.quantity} in stock', style: TextStyle(
                                   color: isLowStock ? Colors.red : Colors.grey,
                                   fontSize: 12
                                 )),
                             ],
                           ),
                           const SizedBox(width: 8),
                           const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                      onTap: () {
                        widget.onSelect(item);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
               // Close and allow custom entry?
               // Just pop. The parent form can add custom via existing logic.
               Navigator.pop(context);
            },
            icon: const Icon(Icons.edit_note),
            label: const Text('Add Custom Item (Manual Entry)'),
          )
        ],
      ),
    );
  }
}
