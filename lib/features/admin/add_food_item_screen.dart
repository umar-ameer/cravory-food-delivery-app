import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../app/theme.dart';

class AddFoodItemScreen extends StatefulWidget {
  const AddFoodItemScreen({super.key});

  @override
  State<AddFoodItemScreen> createState() => _AddFoodItemScreenState();
}

class _AddFoodItemScreenState extends State<AddFoodItemScreen> {
  final formKey = GlobalKey<FormState>();

  final restaurantIdController = TextEditingController();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final imageController = TextEditingController();
  final priceController = TextEditingController();

  bool isVeg = true;
  bool isAvailable = true;
  bool isSaving = false;

  @override
  void dispose() {
    restaurantIdController.dispose();
    nameController.dispose();
    descriptionController.dispose();
    imageController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Future<void> saveFoodItem() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final ref = FirebaseFirestore.instance.collection('foodItems').doc();

      await ref.set({
        'id': ref.id,
        'restaurantId': restaurantIdController.text.trim(),
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
        'imageUrl': imageController.text.trim(),
        'price': double.tryParse(priceController.text.trim()) ?? 0,
        'isVeg': isVeg,
        'isAvailable': isAvailable,
        'createdAt': Timestamp.now(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Food item added successfully'),
          backgroundColor: AppTheme.primary,
        ),
      );

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: AppTheme.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  String? requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }

    return null;
  }

  String? priceValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }

    if (double.tryParse(value.trim()) == null) {
      return 'Enter valid price';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.darkText,
        title: const Text(
          'Add Food Item',
          style: TextStyle(
            color: AppTheme.darkText,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.borderColor,
                ),
              ),
              child: const Text(
                'Paste restaurant document ID from Firestore here.',
                style: TextStyle(
                  color: AppTheme.lightText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            _Field(
              controller: restaurantIdController,
              hint: 'Restaurant ID',
              icon: Icons.storefront_rounded,
              validator: requiredField,
            ),
            _Field(
              controller: nameController,
              hint: 'Food item name',
              icon: Icons.fastfood_rounded,
              validator: requiredField,
            ),
            _Field(
              controller: descriptionController,
              hint: 'Description',
              icon: Icons.description_rounded,
              validator: requiredField,
            ),
            _Field(
              controller: imageController,
              hint: 'Image URL',
              icon: Icons.image_rounded,
              validator: requiredField,
            ),
            _Field(
              controller: priceController,
              hint: 'Price e.g. 199',
              icon: Icons.currency_rupee_rounded,
              validator: priceValidator,
              keyboardType: TextInputType.number,
            ),

            SwitchListTile(
              value: isVeg,
              onChanged: (value) {
                setState(() {
                  isVeg = value;
                });
              },
              activeColor: AppTheme.success,
              title: const Text(
                'Vegetarian',
                style: TextStyle(
                  color: AppTheme.darkText,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),

            SwitchListTile(
              value: isAvailable,
              onChanged: (value) {
                setState(() {
                  isAvailable = value;
                });
              },
              activeColor: AppTheme.primary,
              title: const Text(
                'Available',
                style: TextStyle(
                  color: AppTheme.darkText,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),

            const SizedBox(height: 18),

            ElevatedButton(
              onPressed: isSaving ? null : saveFoodItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: isSaving
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Text(
                      'Save Food Item',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final String? Function(String?) validator;
  final TextInputType keyboardType;

  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.validator,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: AppTheme.darkText,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }
}