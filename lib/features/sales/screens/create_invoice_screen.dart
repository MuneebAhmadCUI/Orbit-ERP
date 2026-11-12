import 'package:flutter/material.dart';
import '../../../core/services/local_erp_store.dart';
import '../../../core/widgets/erp_form_fields.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});
  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}
class _InvoiceLine {
  final description = TextEditingController();
  final quantity = TextEditingController(text: '1');
  final price = TextEditingController();
  void dispose() { description.dispose(); quantity.dispose(); price.dispose(); }
  double get amount => (double.tryParse(quantity.text) ?? 0) * (double.tryParse(price.text) ?? 0);
}
class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final _form = GlobalKey<FormState>();
  final _note = TextEditingController();
  final _tax = TextEditingController(text: '0');
  final _lines = <_InvoiceLine>[_InvoiceLine()];
  List<Map<String, dynamic>> _customers = [];
  String? _customerId;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 14));
  bool _saving = false;
  @override
  void initState() { super.initState(); _loadCustomers(); _tax.addListener(_updateTotals); _lines.first.quantity.addListener(_updateTotals); _lines.first.price.addListener(_updateTotals); }
  Future<void> _loadCustomers() async {
    final list = await LocalErpStore.load('customers');
    if (mounted) setState(() => _customers = list);
  }
  void _updateTotals() { if (mounted) setState(() {}); }
  void _addLine() {
    final line = _InvoiceLine();
    line.quantity.addListener(_updateTotals);
    line.price.addListener(_updateTotals);
    setState(() => _lines.add(line));
  }
  @override
  void dispose() {
    for (final line in _lines) { line.dispose(); }
    _note.dispose(); _tax.dispose(); super.dispose();
  }
  double get _subtotal => _lines.fold<double>(0, (total,line) => total + line.amount);
  double get _taxRate => double.tryParse(_tax.text) ?? 0;
  double get _total => _subtotal * (1 + _taxRate / 100);
  Future<void> _chooseDueDate() async {
    final date = await showDatePicker(context: context, initialDate: _dueDate,
      firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (date != null) setState(() => _dueDate = date);
  }
  Future<void> _save() async {
    if (!_form.currentState!.validate() || _saving) return;
    if (_customerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a customer first.')));
      return;
    }
    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final id = now.microsecondsSinceEpoch.toString();
      final customer = _customers.firstWhere((c) => c['id'] == _customerId);
      final invoiceNumber = 'INV-${now.millisecondsSinceEpoch}';
      await LocalErpStore.add('invoices', {
        'id': id,
        'number': invoiceNumber,
        'customerId': _customerId,
        'customerName': customer['name'],
        'issuedAt': now.toIso8601String(),
        'dueDate': _dueDate.toIso8601String(),
        'status': 'Unpaid',
        'items': _lines.map((l) => {
          'description': l.description.text.trim(),
          'quantity': double.parse(l.quantity.text),
          'unitPrice': double.parse(l.price.text),
          'amount': l.amount,
        }).toList(),
        'subtotal': _subtotal,
        'taxRate': _taxRate,
        'total': _total,
        'notes': _note.text.trim(),
      });
      await LocalErpStore.logActivity(
        'Invoice #$invoiceNumber created',
        '${customer['name']} • \$${_total.toStringAsFixed(2)}',
        iconType: 'invoice',
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invoice could not be saved.')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Create Invoice')),
    body: Form(key: _form, child: ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Invoice details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
      const SizedBox(height: 14),
      DropdownButtonFormField<String>(
        initialValue: _customerId,
        isExpanded: true,
        decoration: const InputDecoration(labelText: 'Customer *', border: OutlineInputBorder()),
        items: _customers.map((c) => DropdownMenuItem(value: c['id'].toString(), child: Text(c['name'].toString()))).toList(),
        onChanged: (v) => setState(() => _customerId = v),
        validator: (v) => v == null ? 'Select a customer' : null,
      ),
      if (_customers.isEmpty) const Padding(padding: EdgeInsets.only(top: 8), child: Text('No customers found. Add a customer from the Dashboard first.')),
      const SizedBox(height: 12),
      OutlinedButton.icon(onPressed: _chooseDueDate, icon: const Icon(Icons.calendar_today_outlined),
        label: Text('Due date: ${_dueDate.day}/${_dueDate.month}/${_dueDate.year}')),
      const SizedBox(height: 16),
      const Text('Line items', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
      const SizedBox(height: 8),
      ...List.generate(_lines.length, (i) {
        final l = _lines[i];
        return Card(key: ObjectKey(l), margin: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
          Row(children: [Expanded(child: Text('Item ${i+1}', style: const TextStyle(fontWeight: FontWeight.w600))),
            if (_lines.length > 1) IconButton(onPressed: () => setState(() { _lines.removeAt(i); l.dispose(); }), icon: const Icon(Icons.delete_outline))]),
          ErpTextField(controller: l.description, label: 'Description *', validator: requiredField),
          Row(children: [
            Expanded(child: ErpTextField(controller: l.quantity, label: 'Quantity *', keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: positiveNumber)),
            const SizedBox(width: 8),
            Expanded(child: ErpTextField(controller: l.price, label: 'Unit price *', keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: positiveNumber)),
          ]),
          Align(alignment: Alignment.centerRight, child: Text('Amount: ${l.amount.toStringAsFixed(2)}')),
        ])));
      }),
      OutlinedButton.icon(onPressed: _addLine, icon: const Icon(Icons.add), label: const Text('Add line item')),
      const SizedBox(height: 14),
      ErpTextField(controller: _tax, label: 'Tax (%)', keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: (s) {
        final v = double.tryParse(s ?? '');
        return v == null || !v.isFinite || v < 0 || v > 100 ? 'Enter a tax rate from 0 to 100' : null;
      }),
      ErpTextField(controller: _note, label: 'Notes (optional)', maxLines: 2),
      Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(children: [
        _TotalRow('Subtotal', _subtotal),
        _TotalRow('Tax (${_taxRate.toStringAsFixed(1)}%)', _subtotal * _taxRate / 100),
        const Divider(),
        _TotalRow('Total', _total, bold: true),
      ]))),
      const SizedBox(height: 12),
      FilledButton(onPressed: _saving ? null : _save,
        child: Padding(padding: const EdgeInsets.all(12), child: Text(_saving ? 'Saving...' : 'Save Invoice'))),
      const SizedBox(height: 18),
    ])),
  );
}
class _TotalRow extends StatelessWidget {
  const _TotalRow(this.label, this.amount, {this.bold = false});
  final String label;
  final double amount;
  final bool bold;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
    Text(amount.toStringAsFixed(2), style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
  ]));
}
