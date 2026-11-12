import 'package:flutter/material.dart';
import '../../../core/services/local_erp_store.dart';
import '../../../core/theme/app_colors.dart';
import 'create_invoice_screen.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  late Future<List<Map<String, dynamic>>> _items;
  String _filterStatus = 'All';

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _items = LocalErpStore.load('invoices');
    });
  }

  Future<void> _add() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CreateInvoiceScreen()),
    );
    if (saved == true) {
      _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invoice saved')),
        );
      }
    }
  }

  Future<void> _toggleStatus(Map<String, dynamic> invoice, bool isPaid) async {
    final newStatus = isPaid ? 'Paid' : 'Unpaid';
    final id = invoice['id']?.toString() ?? '';
    await LocalErpStore.updateStatus('invoices', id, newStatus);
    final total = (invoice['total'] as num?)?.toDouble() ?? 0.0;
    await LocalErpStore.logActivity(
      'Invoice ${invoice['number']} marked as $newStatus',
      '${invoice['customerName'] ?? ''} • \$${total.toStringAsFixed(2)}',
      iconType: 'invoice',
    );
    _refresh();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invoice ${invoice['number']} marked as $newStatus'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _deleteInvoice(Map<String, dynamic> invoice) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Invoice'),
        content: Text('Are you sure you want to delete invoice ${invoice['number']}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final id = invoice['id']?.toString() ?? '';
      await LocalErpStore.remove('invoices', id);
      _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invoice deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.add),
        label: const Text('Invoice'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _items,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final allData = snapshot.data!;
          if (allData.isEmpty) {
            return const Center(child: Text('No invoices yet. Tap + Invoice to create one.'));
          }

          final unpaidCount = allData.where((i) => i['status'] == 'Unpaid').length;
          final paidCount = allData.where((i) => i['status'] == 'Paid').length;

          final filteredData = allData.where((item) {
            if (_filterStatus == 'Unpaid') return item['status'] == 'Unpaid';
            if (_filterStatus == 'Paid') return item['status'] == 'Paid';
            return true;
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<String>(
                        segments: [
                          ButtonSegment(
                            value: 'All',
                            label: Text('All (${allData.length})'),
                          ),
                          ButtonSegment(
                            value: 'Unpaid',
                            label: Text('Unpaid ($unpaidCount)'),
                          ),
                          ButtonSegment(
                            value: 'Paid',
                            label: Text('Paid ($paidCount)'),
                          ),
                        ],
                        selected: {_filterStatus},
                        onSelectionChanged: (newSelection) {
                          setState(() {
                            _filterStatus = newSelection.first;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filteredData.isEmpty
                    ? Center(child: Text('No $_filterStatus invoices found.'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: filteredData.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (_, i) {
                          final item = filteredData[i];
                          final isPaid = item['status'] == 'Paid';
                          final total = (item['total'] as num?)?.toDouble() ?? 0.0;

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            leading: Checkbox(
                              value: isPaid,
                              activeColor: Colors.green,
                              onChanged: (checked) {
                                if (checked != null) {
                                  _toggleStatus(item, checked);
                                }
                              },
                            ),
                            title: Row(
                              children: [
                                Text(
                                  item['number']?.toString() ?? '',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isPaid ? Colors.green.shade50 : Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isPaid ? Colors.green.shade200 : Colors.orange.shade200,
                                    ),
                                  ),
                                  child: Text(
                                    isPaid ? 'Paid' : 'Unpaid',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isPaid ? Colors.green.shade700 : Colors.orange.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              '${item['customerName'] ?? 'No Customer'}',
                              style: const TextStyle(color: AppColors.muted),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '\$${total.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                  onPressed: () => _deleteInvoice(item),
                                  tooltip: 'Delete Invoice',
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}