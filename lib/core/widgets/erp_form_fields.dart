import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ErpTextField extends StatelessWidget {
  const ErpTextField({super.key, required this.controller, required this.label,
    this.hint, this.keyboardType, this.validator, this.maxLines = 1});
  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(28)),
        enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.border), borderRadius: BorderRadius.circular(28)),
      ),
    ),
  );
}

String? requiredField(String? value) => value == null || value.trim().isEmpty ? 'Required field' : null;
String? emailField(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim()) ? null : 'Enter a valid email';
}
String? positiveNumber(String? value) {
  final n = double.tryParse(value?.trim() ?? '');
  return n == null || !n.isFinite || n <= 0 ? 'Enter a number greater than 0' : null;
}
