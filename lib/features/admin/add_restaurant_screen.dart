import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../app/theme.dart';

class AddRestaurantScreen extends StatefulWidget {
  const AddRestaurantScreen({super.key});

  @override
  State<AddRestaurantScreen> createState() => _AddRestaurantScreenState();
}

class _AddRestaurantScreenState extends State<AddRestaurantScreen> {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final categoryController = TextEditingController();
  final imageController = TextEditingController();
  final deliveryTimeController = TextEditingController();
  final deliveryFeeController = TextEditingController();

  bool isOpen = true;
  bool isSaving = false;

  @override
  void dispose() {
    nameController.dispose();
    categoryController.dispose();
    imageController.dispose();
    deliveryTimeController.dispose();
    deliveryFeeController.dispose();
    super.dispose();
  }

  Future<void> saveRestaurant() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final ref = FirebaseFirestore.instance.collection('restaurants').doc();

      await ref.set({
        'id': ref.id,
        'name': nameController.text.trim(),
        'category': categoryController.text.trim(),
        'imageUrl': imageController.text.trim(),
        'rating': '4.5',
        'deliveryTime': deliveryTimeController.text.trim(),
        'deliveryFee': deliveryFeeController.text.trim(),
        'isOpen': isOpen,
        'createdAt': Timestamp.now(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Restaurant added successfully'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.darkText,
        title: const Text(
          'Add Restaurant',
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
            _Field(
              controller: nameController,
              hint: 'Restaurant name',
              icon: Icons.restaurant_rounded,
              validator: requiredField,
            ),
            _Field(
              controller: categoryController,
              hint: 'Category e.g. Indian, Pizza, Burger',
              icon: Icons.category_rounded,
              validator: requiredField,
            ),
            _Field(
              controller: imageController,
              hint: 'Image URL',
              icon: Icons.image_rounded,
              validator: requiredField,
            ),
            _Field(
              controller: deliveryTimeController,
              hint: 'Delivery time e.g. 25-30 min',
              icon: Icons.schedule_rounded,
              validator: requiredField,
            ),
            _Field(
              controller: deliveryFeeController,
              hint: 'Delivery fee e.g. ₹39',
              icon: Icons.delivery_dining_rounded,
              validator: requiredField,
            ),

            SwitchListTile(
              value: isOpen,
              onChanged: (value) {
                setState(() {
                  isOpen = value;
                });
              },
              activeColor: AppTheme.primary,
              title: const Text(
                'Restaurant Open',
                style: TextStyle(
                  color: AppTheme.darkText,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),

            const SizedBox(height: 18),

            ElevatedButton(
              onPressed: isSaving ? null : saveRestaurant,
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
                      'Save Restaurant',
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

  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        validator: validator,
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