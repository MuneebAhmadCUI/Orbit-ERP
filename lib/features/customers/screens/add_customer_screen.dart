import 'package:flutter/material.dart';
import '../../../core/services/local_erp_store.dart';
import '../../../core/widgets/erp_form_fields.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key, this.customer});
  final Map<String, dynamic>? customer;

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _company;
  late final TextEditingController _address;
  bool _saving = false;

  bool get _isEditing => widget.customer != null;

  @override
  void initState() {
    super.initState();
    final c = widget.customer ?? {};
    _name = TextEditingController(text: c['name']?.toString() ?? '');
    _email = TextEditingController(text: c['email']?.toString() ?? '');
    _phone = TextEditingController(text: c['phone']?.toString() ?? '');
    _company = TextEditingController(text: c['company']?.toString() ?? '');
    _address = TextEditingController(text: c['address']?.toString() ?? '');
  }

  @override
  void dispose() {
    for (final controller in [_name, _email, _phone, _company, _address]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate() || _saving) return;
    setState(() => _saving = true);
    try {
      if (_isEditing) {
        final id = widget.customer!['id'].toString();
        await LocalErpStore.update('customers', id, {
          'name': _name.text.trim(),
          'email': _email.text.trim(),
          'phone': _phone.text.trim(),
          'company': _company.text.trim(),
          'address': _address.text.trim(),
        });
        await LocalErpStore.logActivity(
          'Customer "${_name.text.trim()}" updated',
          _company.text.trim().isNotEmpty ? _company.text.trim() : _email.text.trim(),
          iconType: 'customer',
        );
      } else {
        await LocalErpStore.add('customers', {
          'id': DateTime.now().microsecondsSinceEpoch.toString(),
          'createdAt': DateTime.now().toIso8601String(),
          'name': _name.text.trim(),
          'email': _email.text.trim(),
          'phone': _phone.text.trim(),
          'company': _company.text.trim(),
          'address': _address.text.trim(),
        });
        await LocalErpStore.logActivity(
          'Customer "${_name.text.trim()}" added',
          _company.text.trim().isNotEmpty ? _company.text.trim() : _email.text.trim(),
          iconType: 'customer',
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save customer. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(_isEditing ? 'Edit Customer' : 'Add Customer')),
        body: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                _isEditing ? 'Edit customer details' : 'Customer information',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              ErpTextField(controller: _name, label: 'Customer name *', validator: requiredField),
              ErpTextField(controller: _company, label: 'Company name'),
              ErpTextField(controller: _email, label: 'Email', keyboardType: TextInputType.emailAddress, validator: emailField),
              ErpTextField(controller: _phone, label: 'Phone number', keyboardType: TextInputType.phone),
              ErpTextField(controller: _address, label: 'Address', maxLines: 3),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(_saving
                      ? 'Saving...'
                      : (_isEditing ? 'Update Customer' : 'Save Customer')),
                ),
              ),
            ],
          ),
        ),
      );
}