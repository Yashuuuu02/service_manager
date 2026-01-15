import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../backend/providers/service_provider.dart';
import '../backend/models/inventory_item.dart';
import '../theme/app_colors.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  @override
  void initState() {
    super.initState();
    // Load inventory on init (if not already loaded)
    WidgetsBinding.instance.addPostFrameCallback((_) {
       context.read<ServiceProvider>().loadInventory();
    });
  }

  void _showAddEditDialog(BuildContext context, {InventoryItem? item}) {
    final nameController = TextEditingController(text: item?.name ?? '');
    final partNumController = TextEditingController(text: item?.partNumber ?? '');
    final priceController = TextEditingController(text: item?.price.toString() ?? '');
    final qtyController = TextEditingController(text: item?.quantity.toString() ?? '0');
    final minStockController = TextEditingController(text: item?.minStockLevel.toString() ?? '5');
    
    // Simple validation flag
    final formKey = GlobalKey<FormState>();
    
    // Capture provider before opening dialog
    final provider = context.read<ServiceProvider>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(item == null ? 'Add New Item' : 'Edit Item'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Item Name'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: partNumController,
                  decoration: const InputDecoration(labelText: 'Part Number / SKU'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: priceController,
                        decoration: const InputDecoration(labelText: 'Price (₹)'),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          if (double.tryParse(v) == null) return 'Invalid number';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: qtyController,
                        decoration: const InputDecoration(labelText: 'Quantity'),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v != null && v.isNotEmpty && int.tryParse(v) == null) {
                            return 'Invalid number';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: minStockController,
                  decoration: const InputDecoration(labelText: 'Min Stock Alert Level'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final newItem = InventoryItem(
                  id: item?.id ?? const Uuid().v4(),
                  name: nameController.text,
                  partNumber: partNumController.text,
                  price: double.tryParse(priceController.text) ?? 0.0,
                  quantity: int.tryParse(qtyController.text) ?? 0,
                  minStockLevel: int.tryParse(minStockController.text) ?? 0,
                  trackStock: true, // Default to true for inventory screen
                );

                if (item == null) {
                  await provider.addInventoryItem(newItem);
                } else {
                  await provider.updateInventoryItem(newItem);
                }
                
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, InventoryItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
             onPressed: () async {
               await context.read<ServiceProvider>().deleteInventoryItem(item.id);
               if (mounted) Navigator.pop(ctx);
             },
             child: const Text('Delete', style: TextStyle(color: Colors.red)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch inventory
    final provider = context.watch<ServiceProvider>();
    final inventory = provider.inventory;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
               // Future: Search functionality
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context),
        child: const Icon(Icons.add),
      ),
      body: inventory.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('No items in inventory', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  const Text('Tap + to add your first part', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: inventory.length,
              itemBuilder: (context, index) {
                final item = inventory[index];
                final isLowStock = item.quantity <= item.minStockLevel;
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isLowStock ? AppColors.statusCritical.withOpacity(0.1) : AppColors.secondary.withOpacity(0.1),
                      child: Icon(
                        Icons.settings_suggest, 
                        color: isLowStock ? AppColors.statusCritical : AppColors.secondary
                      ),
                    ),
                    title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('SKU: ${item.partNumber.isEmpty ? "N/A" : item.partNumber} • ₹${item.price.toStringAsFixed(0)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                           mainAxisAlignment: MainAxisAlignment.center,
                           crossAxisAlignment: CrossAxisAlignment.end,
                           children: [
                             Text('${item.quantity} In Stock', 
                              style: TextStyle(
                                fontWeight: FontWeight.bold, 
                                color: isLowStock ? AppColors.statusCritical : Colors.black
                              )
                             ),
                             if (isLowStock) 
                               const Text('Low Stock', style: TextStyle(fontSize: 10, color: AppColors.statusCritical)),
                           ],
                        ),
                        const SizedBox(width: 8),
                        PopupMenuButton(
                           itemBuilder: (ctx) => [
                             const PopupMenuItem(value: 'edit', child: Text('Edit')),
                             const PopupMenuItem(value: 'delete', child: Text('Delete')),
                           ],
                           onSelected: (val) {
                             if (val == 'edit') _showAddEditDialog(context, item: item);
                             if (val == 'delete') _confirmDelete(context, item);
                           },
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
