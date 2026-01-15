import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form Controllers
  final _registrationController = TextEditingController();
  final _vinController = TextEditingController();
  final _modelController = TextEditingController();
  final _variantController = TextEditingController();
  final _engineNumberController = TextEditingController();
  final _odometerController = TextEditingController();
  
  String? _selectedCustomer;
  String _selectedFuelType = 'Petrol';
  
  final List<String> _fuelTypes = ['Petrol', 'Diesel', 'CNG', 'Electric', 'Hybrid'];

  @override
  void dispose() {
    _registrationController.dispose();
    _vinController.dispose();
    _modelController.dispose();
    _variantController.dispose();
    _engineNumberController.dispose();
    _odometerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onBackground),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.handyman_outlined, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'GarageFlow Pro',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.onBackground,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Offline Ready',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back Button Row
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Row(
                        children: [
                          Icon(Icons.arrow_back, size: 20, color: AppColors.onBackground),
                          const SizedBox(width: 8),
                          Text('Back', style: TextStyle(color: AppColors.onBackground)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Header
                    Text(
                      'Add Vehicle',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onBackground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Register a new vehicle',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Owner & Registration Section
                    _buildSectionCard(
                      title: 'Owner & Registration',
                      children: [
                        _buildLabeledField(
                          label: 'Customer (Owner)',
                          isRequired: true,
                          child: DropdownButtonFormField<String>(
                            value: _selectedCustomer,
                            hint: const Text('Select customer'),
                            decoration: _inputDecoration(),
                            items: const [
                              DropdownMenuItem(value: 'cust1', child: Text('Customer 1')),
                              DropdownMenuItem(value: 'cust2', child: Text('Customer 2')),
                            ],
                            onChanged: (value) {
                              setState(() => _selectedCustomer = value);
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildLabeledField(
                          label: 'Registration Number',
                          isRequired: true,
                          child: TextFormField(
                            controller: _registrationController,
                            decoration: _inputDecoration(hint: 'E.G., MH12AB1234'),
                            textCapitalization: TextCapitalization.characters,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildLabeledField(
                          label: 'VIN (Chassis Number)',
                          child: TextFormField(
                            controller: _vinController,
                            decoration: _inputDecoration(hint: 'ENTER VIN'),
                            textCapitalization: TextCapitalization.characters,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Vehicle Details Section
                    _buildSectionCard(
                      title: 'Vehicle Details',
                      children: [
                        _buildLabeledField(
                          label: 'Model',
                          isRequired: true,
                          child: TextFormField(
                            controller: _modelController,
                            decoration: _inputDecoration(hint: 'e.g., Swift, Creta, Nexon'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildLabeledField(
                          label: 'Variant',
                          child: TextFormField(
                            controller: _variantController,
                            decoration: _inputDecoration(hint: 'e.g., ZXI+, SX(O)'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildLabeledField(
                          label: 'Fuel Type',
                          isRequired: true,
                          child: DropdownButtonFormField<String>(
                            value: _selectedFuelType,
                            decoration: _inputDecoration(),
                            items: _fuelTypes.map((fuel) {
                              return DropdownMenuItem(value: fuel, child: Text(fuel));
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedFuelType = value!);
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildLabeledField(
                          label: 'Engine Number',
                          child: TextFormField(
                            controller: _engineNumberController,
                            decoration: _inputDecoration(hint: 'Enter engine number'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildLabeledField(
                          label: 'Current Odometer (km)',
                          child: TextFormField(
                            controller: _odometerController,
                            decoration: _inputDecoration(hint: 'Enter current reading'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saveVehicle,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Save Vehicle'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLabeledField({
    required String label,
    bool isRequired = false,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.onBackground,
            ),
            children: isRequired
                ? [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      fillColor: AppColors.background,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }

  void _saveVehicle() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement save logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle saved successfully!')),
      );
      Navigator.pop(context);
    }
  }
}
