import 'package:flutter/material.dart';

class VehicleDetailsTab extends StatefulWidget {
  final VoidCallback onNext;
  final Function(String, String, String, String, String) onDataChanged;
  
  // Initial Values
  final String initialName;
  final String initialPhone;
  final String initialModel;
  final String initialReg;
  final String initialType;

  const VehicleDetailsTab({
      super.key, 
      required this.onNext,
      required this.onDataChanged,
      this.initialName = '',
      this.initialPhone = '',
      this.initialModel = '',
      this.initialReg = '',
      this.initialType = 'Sedan',
  });

  @override
  State<VehicleDetailsTab> createState() => _VehicleDetailsTabState();
}

class _VehicleDetailsTabState extends State<VehicleDetailsTab> with AutomaticKeepAliveClientMixin {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _modelController;
  late TextEditingController _regController;
  late String _type;
  
  @override
  bool get wantKeepAlive => true; // Prevent disposal when scrolling away

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _phoneController = TextEditingController(text: widget.initialPhone);
    _modelController = TextEditingController(text: widget.initialModel);
    _regController = TextEditingController(text: widget.initialReg);
    _type = widget.initialType;
  }
  
  @override
  void dispose() {
      _nameController.dispose();
      _phoneController.dispose();
      _modelController.dispose();
      _regController.dispose();
      super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Customer Name'),
            onChanged: (v) => _notifyChange(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(labelText: 'Phone'),
            onChanged: (v) => _notifyChange(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _modelController,
            decoration: const InputDecoration(labelText: 'Vehicle Model'),
             onChanged: (v) => _notifyChange(),
          ),
          const SizedBox(height: 16),
           TextField(
            controller: _regController,
            decoration: const InputDecoration(labelText: 'Reg Number'),
             onChanged: (v) => _notifyChange(),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: widget.onNext, child: const Text('NEXT ▶')),
        ],
      ),
    );
  }
  
  void _notifyChange() {
      widget.onDataChanged(
          _nameController.text,
          _phoneController.text,
          _modelController.text,
          _regController.text,
          _type,
      );
  }
}
