import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../models/address_model.dart';
import '../../providers/address_provider.dart';

class AddAddressScreen extends ConsumerStatefulWidget {
  const AddAddressScreen({super.key});

  @override
  ConsumerState<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends ConsumerState<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _fullAddressController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isDefault = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _fullAddressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() {
    _isSaving = true;
  });

  final address = AddressModel(
    id: '', // Firestore will generate the ID
    title: _titleController.text.trim(),
    fullAddress: _fullAddressController.text.trim(),
    phoneNumber: _phoneController.text.trim(),
    isDefault: _isDefault,
  );

  await ref.read(addressProvider.notifier).addAddress(address);

  if (!mounted) return;

  final addressState = ref.read(addressProvider);

  setState(() {
    _isSaving = false;
  });

  if (addressState.hasError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(addressState.error.toString()),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Address saved successfully'),
    ),
  );

  context.pop();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Address'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Address Title',
                      hintText: 'Home, Office, Hostel',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter address title';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _fullAddressController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Full Address',
                      hintText: 'House no, street, city, state, pincode',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter full address';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      hintText: 'Enter phone number',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter phone number';
                      }
                      if (value.trim().length < 10) {
                        return 'Please enter valid phone number';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  SwitchListTile(
                    value: _isDefault,
                    onChanged: (value) {
                      setState(() {
                        _isDefault = value;
                      });
                    },
                    title: const Text(
                      'Set as default address',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    activeColor: AppTheme.primary,
                    contentPadding: EdgeInsets.zero,
                  ),

                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Save Address',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
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
}