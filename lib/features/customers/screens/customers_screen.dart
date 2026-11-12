import 'package:flutter/material.dart';
import '../../../core/services/local_erp_store.dart';
import '../../../core/theme/app_colors.dart';
import 'add_customer_screen.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});
  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  late Future<List<Map<String, dynamic>>> _items;
  bool _selectionMode = false;
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _items = LocalErpStore.load('customers');
    });
  }

  Future<void> _add() async {
    final saved = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const AddCustomerScreen()));
    if (saved == true) {
      _refresh();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Customer saved')));
    }
  }

  Future<void> _editCustomer(Map<String, dynamic> customer) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddCustomerScreen(customer: customer),
      ),
    );
    if (updated == true) {
      _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Customer updated')),
        );
      }
    }
  }

  Future<void> _deleteSingle(Map<String, dynamic> customer) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text('Are you sure you want to delete "${customer['name']}"?'),
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
      final id = customer['id']?.toString() ?? '';
      await LocalErpStore.remove('customers', id);
      _selectedIds.remove(id);
      if (_selectedIds.isEmpty) _selectionMode = false;
      _refresh();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Customer deleted')));
    }
  }

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) return;
    final count = _selectedIds.length;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Selected Customers'),
        content: Text('Are you sure you want to delete $count selected customer(s)?'),
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
      await LocalErpStore.removeMultiple('customers', _selectedIds);
      _selectedIds.clear();
      _selectionMode = false;
      _refresh();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$count customer(s) deleted')));
    }
  }

  void _toggleSelectAll(List<Map<String, dynamic>> allItems) {
    setState(() {
      if (_selectedIds.length == allItems.length) {
        _selectedIds.clear();
      } else {
        _selectedIds.clear();
        for (final item in allItems) {
          final id = item['id']?.toString();
          if (id != null) _selectedIds.add(id);
        }
      }
    });
  }

  void _toggleItem(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) _selectionMode = false;
      } else {
        _selectedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _items,
      builder: (context, snapshot) {
        final data = snapshot.data ?? [];
        final isLoading = !snapshot.hasData;
        final allSelected = data.isNotEmpty && _selectedIds.length == data.length;

        return Scaffold(
          appBar: AppBar(
            leading: _selectionMode
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() {
                      _selectionMode = false;
                      _selectedIds.clear();
                    }),
                  )
                : null,
            title: Text(_selectionMode ? '${_selectedIds.length} Selected' : 'Customers'),
            actions: [
              if (_selectionMode) ...[
                IconButton(
                  tooltip: allSelected ? 'Deselect All' : 'Select All',
                  icon: Icon(allSelected ? Icons.select_all_rounded : Icons.checklist_rounded),
                  onPressed: () => _toggleSelectAll(data),
                ),
                IconButton(
                  tooltip: 'Delete Selected',
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: _selectedIds.isNotEmpty ? _deleteSelected : null,
                ),
              ] else if (data.isNotEmpty) ...[
                IconButton(
                  tooltip: 'Select Items',
                  icon: const Icon(Icons.checklist_rounded),
                  onPressed: () => setState(() => _selectionMode = true),
                ),
              ],
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _add,
            icon: const Icon(Icons.add),
            label: const Text('Customer'),
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : data.isEmpty
                  ? const Center(child: Text('No customers yet. Tap + Customer to add one.'))
                  : Column(
                      children: [
                        if (!_selectionMode && data.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${data.length} Customers', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.muted)),
                                TextButton.icon(
                                  icon: const Icon(Icons.select_all_rounded, size: 18),
                                  label: const Text('Select All'),
                                  onPressed: () {
                                    setState(() {
                                      _selectionMode = true;
                                      _toggleSelectAll(data);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.all(12),
                            itemCount: data.length,
                            separatorBuilder: (_, __) => const Divider(),
                            itemBuilder: (_, i) {
                              final item = data[i];
                              final id = item['id']?.toString() ?? '';
                              final isSelected = _selectedIds.contains(id);

                              return ListTile(
                                leading: _selectionMode
                                    ? Checkbox(
                                        value: isSelected,
                                        onChanged: (_) => _toggleItem(id),
                                      )
                                    : const CircleAvatar(child: Icon(Icons.person_outline)),
                                title: Text('${item['name']}'),
                                subtitle: Text([
                                  item['company'],
                                  item['phone'],
                                  item['email']
                                ].where((x) => x != null && x.toString().isNotEmpty).join(' • ')),
                                trailing: _selectionMode
                                    ? null
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit_outlined, color: AppColors.blue),
                                            onPressed: () => _editCustomer(item),
                                            tooltip: 'Edit Customer',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                            onPressed: () => _deleteSingle(item),
                                            tooltip: 'Delete',
                                          ),
                                        ],
                                      ),
                                onTap: _selectionMode ? () => _toggleItem(id) : null,
                                onLongPress: () {
                                  if (!_selectionMode) {
                                    setState(() {
                                      _selectionMode = true;
                                      _toggleItem(id);
                                    });
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
        );
      },
    );
  }
}