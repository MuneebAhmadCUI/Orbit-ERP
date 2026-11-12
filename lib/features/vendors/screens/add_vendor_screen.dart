import 'package:flutter/material.dart';
import '../../../core/services/local_erp_store.dart';
import '../../../core/widgets/erp_form_fields.dart';

class AddVendorScreen extends StatefulWidget {
  const AddVendorScreen({super.key, this.vendor});
  final Map<String, dynamic>? vendor;

  @override
  State<AddVendorScreen> createState() => _AddVendorScreenState();
}

class _AddVendorScreenState extends State<AddVendorScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _contact;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _address;
  bool _saving = false;

  bool get _isEditing => widget.vendor != null;

  @override
  void initState() {
    super.initState();
    final v = widget.vendor ?? {};
    _name = TextEditingController(text: v['name']?.toString() ?? '');
    _contact = TextEditingController(text: v['contact']?.toString() ?? '');
    _email = TextEditingController(text: v['email']?.toString() ?? '');
    _phone = TextEditingController(text: v['phone']?.toString() ?? '');
    _address = TextEditingController(text: v['address']?.toString() ?? '');
  }

  @override
  void dispose() {
    for (final c in [_name, _contact, _email, _phone, _address]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate() || _saving) return;
    setState(() => _saving = true);
    try {
      if (_isEditing) {
        final id = widget.vendor!['id'].toString();
        await LocalErpStore.update('vendors', id, {
          'name': _name.text.trim(),
          'contact': _contact.text.trim(),
          'email': _email.text.trim(),
          'phone': _phone.text.trim(),
          'address': _address.text.trim(),
        });
        await LocalErpStore.logActivity(
          'Vendor "${_name.text.trim()}" updated',
          _contact.text.trim().isNotEmpty ? _contact.text.trim() : _email.text.trim(),
          iconType: 'vendor',
        );
      } else {
        await LocalErpStore.add('vendors', {
          'id': DateTime.now().microsecondsSinceEpoch.toString(),
          'name': _name.text.trim(),
          'contact': _contact.text.trim(),
          'email': _email.text.trim(),
          'phone': _phone.text.trim(),
          'address': _address.text.trim(),
        });
        await LocalErpStore.logActivity(
          'Vendor "${_name.text.trim()}" added',
          _contact.text.trim().isNotEmpty ? _contact.text.trim() : _email.text.trim(),
          iconType: 'vendor',
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save vendor. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(_isEditing ? 'Edit Vendor' : 'Add Vendor')),
        body: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                _isEditing ? 'Edit vendor details' : 'Vendor information',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              ErpTextField(controller: _name, label: 'Vendor / Business name *', validator: requiredField),
              ErpTextField(controller: _contact, label: 'Contact person'),
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
                      : (_isEditing ? 'Update Vendor' : 'Save Vendor')),
                ),
              ),
            ],
          ),
        ),
      );
}