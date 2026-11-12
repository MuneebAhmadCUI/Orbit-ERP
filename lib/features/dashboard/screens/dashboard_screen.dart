import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/section_card.dart';
import '../../../core/services/local_erp_store.dart';
import '../../customers/screens/add_customer_screen.dart';
import '../../customers/screens/customers_screen.dart';
import '../../vendors/screens/add_vendor_screen.dart';
import '../../vendors/screens/vendors_screen.dart';
import '../../sales/screens/create_invoice_screen.dart';
import '../../sales/screens/invoices_screen.dart';

class _PixelBounce extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _PixelBounce({required this.child, this.onTap});

  @override
  State<_PixelBounce> createState() => _PixelBounceState();
}

class _PixelBounceState extends State<_PixelBounce> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
  late final Animation<double> _scale = Tween<double>(begin: 1.0, end: 0.98).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) { _controller.reverse(); widget.onTap?.call(); },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardData {
  const _DashboardData({
    required this.unpaidCount,
    required this.totalSalesFormatted,
    required this.totalOrders,
    required this.tasksCount,
    required this.activities,
  });

  final int unpaidCount;
  final String totalSalesFormatted;
  final int totalOrders;
  final int tasksCount;
  final List<Map<String, dynamic>> activities;
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<_DashboardData> _dashboardData;
  String _selectedYear = '2026';
  int _refreshKey = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    setState(() {
      _dashboardData = _fetchDashboardData();
    });
  }

  static Future<_DashboardData> _fetchDashboardData() async {
    final invoices = await LocalErpStore.load('invoices');
    final activities = await LocalErpStore.load('activities');

    final unpaidInvoices = invoices.where((inv) => inv['status'] == 'Unpaid').toList();
    final paidInvoices = invoices.where((inv) => inv['status'] == 'Paid').toList();

    double totalSales = 0.0;
    for (final inv in paidInvoices) {
      totalSales += (inv['total'] as num?)?.toDouble() ?? 0.0;
    }

    String formattedSales;
    if (totalSales >= 1000000) {
      formattedSales = '\$${(totalSales / 1000000).toStringAsFixed(1)}M';
    } else if (totalSales >= 1000) {
      formattedSales = '\$${(totalSales / 1000).toStringAsFixed(0)}K';
    } else {
      formattedSales = '\$${totalSales.toStringAsFixed(0)}';
    }

    return _DashboardData(
      unpaidCount: unpaidInvoices.length,
      totalSalesFormatted: formattedSales,
      totalOrders: invoices.length,
      tasksCount: unpaidInvoices.length,
      activities: activities,
    );
  }

  Future<void> _navigateAndRefresh(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    _loadDashboardData();
    setState(() {
      _refreshKey++;
    });
  }

  String _formatActivityTime(String? timestampStr) {
    if (timestampStr == null) return 'Recently';
    final dt = DateTime.tryParse(timestampStr);
    if (dt == null) return timestampStr;

    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  IconData _getIconForType(String? type) {
    switch (type) {
      case 'invoice':
        return Icons.receipt_long_rounded;
      case 'customer':
        return Icons.person_outline_rounded;
      case 'vendor':
        return Icons.business_outlined;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_DashboardData>(
      future: _dashboardData,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final unpaidCount = data?.unpaidCount ?? 0;
        final salesVal = data?.totalSalesFormatted ?? '\$0';
        final ordersVal = (data?.totalOrders ?? 0).toString();
        final tasksVal = (data?.tasksCount ?? 0).toString();
        final activitiesList = data?.activities ?? [];
        final displayActivities = activitiesList.take(5).toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.dark)),
            const SizedBox(height: 12),
            SizedBox(
              height: 202,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(32)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(children: [Icon(Icons.description_outlined, color: Colors.white, size: 22), SizedBox(width: 8), Flexible(child: Text('Invoices', style: TextStyle(color: Colors.white, fontSize: 15)))]),
                          const Spacer(),
                          Text('$unpaidCount', style: const TextStyle(color: Colors.white, fontSize: 43, fontWeight: FontWeight.w300, height: 1)),
                          const Text('Unpaid', style: TextStyle(color: Colors.white, fontSize: 14)),
                          const SizedBox(height: 15),
                          SizedBox(
                            width: double.infinity,
                            height: 36,
                            child: FilledButton(
                              style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primary, padding: EdgeInsets.zero),
                              onPressed: () => _navigateAndRefresh(const InvoicesScreen()),
                              child: const Text('View All', style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      children: [
                        _QuickAction(icon: Icons.person_add_alt_1_outlined, label: 'Add Customer', onTap: () => _navigateAndRefresh(const AddCustomerScreen())),
                        const SizedBox(height: 8),
                        _QuickAction(icon: Icons.receipt_long_outlined, label: 'Create Invoice', onTap: () => _navigateAndRefresh(const CreateInvoiceScreen())),
                        const SizedBox(height: 8),
                        _QuickAction(icon: Icons.work_outline_rounded, label: 'Add Vendor', onTap: () => _navigateAndRefresh(const AddVendorScreen())),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              OutlinedButton.icon(icon: const Icon(Icons.people_outline, size: 17), label: const Text('Customers'),
                onPressed: () => _navigateAndRefresh(const CustomersScreen())),
              OutlinedButton.icon(icon: const Icon(Icons.local_shipping_outlined, size: 17), label: const Text('Vendors'),
                onPressed: () => _navigateAndRefresh(const VendorsScreen())),
              OutlinedButton.icon(icon: const Icon(Icons.receipt_long_outlined, size: 17), label: const Text('Invoices'),
                onPressed: () => _navigateAndRefresh(const InvoicesScreen())),
            ]),
            const SizedBox(height: 12),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Expanded(child: Text('Company Turnover', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.dark))),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedYear,
                        isDense: true,
                        style: const TextStyle(color: AppColors.muted, fontSize: 14),
                        items: const [
                          DropdownMenuItem(value: '2026', child: Text('2026')),
                          DropdownMenuItem(value: '2025', child: Text('2025')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedYear = val);
                        },
                      ),
                    ),
                  ]),
                  const SizedBox(height: 14),
                  const Wrap(spacing: 14, runSpacing: 4, children: [
                    _Legend(color: Color(0xFFCDE0D5), label: 'Existing Customers'),
                    _Legend(color: AppColors.primary, label: 'New Customers'),
                  ]),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 155,
                    child: _TurnoverChart(
                      key: ValueKey('$_selectedYear-$_refreshKey'),
                      selectedYear: _selectedYear,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Current Week Performance', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.dark)),
                  const SizedBox(height: 18),
                  Row(children: [
                    Expanded(child: _Kpi(label: 'Sales', value: salesVal, icon: Icons.trending_up_rounded)),
                    const SizedBox(width: 8),
                    Expanded(child: _Kpi(label: 'Orders', value: ordersVal, icon: Icons.shopping_bag_outlined)),
                    const SizedBox(width: 8),
                    Expanded(child: _Kpi(label: 'Tasks', value: tasksVal, icon: Icons.task_alt_rounded)),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Recent activity', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.dark)),
                  const SizedBox(height: 12),
                  if (displayActivities.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('No recent activity recorded.', style: TextStyle(color: AppColors.muted)),
                    )
                  else
                    ...List.generate(displayActivities.length, (i) {
                      final act = displayActivities[i];
                      final title = act['title']?.toString() ?? 'Activity';
                      final subtitle = act['subtitle']?.toString() ?? '';
                      final timeStr = _formatActivityTime(act['timestamp']?.toString());
                      final fullSubtitle = subtitle.isNotEmpty ? '$subtitle • $timeStr' : timeStr;
                      final icon = _getIconForType(act['iconType']?.toString());

                      return Column(
                        children: [
                          if (i > 0) const Divider(color: AppColors.border),
                          _Activity(
                            icon: icon,
                            title: title,
                            subtitle: fullSubtitle,
                          ),
                        ],
                      );
                    }),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: _PixelBounce(
        onTap: onTap,
        child: Material(
          color: AppColors.pale,
          shape: RoundedRectangleBorder(side: const BorderSide(color: AppColors.border), borderRadius: BorderRadius.circular(28)),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(28),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(children: [
                CircleAvatar(radius: 20, backgroundColor: AppColors.primary, child: Icon(icon, size: 19, color: Colors.white)),
                const SizedBox(width: 7),
                Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.dark), maxLines: 2)),
                const Icon(Icons.chevron_right_rounded, color: AppColors.primary, size: 20),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 9, height: 9, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 5),
    Text(label, style: const TextStyle(fontSize: 10, color: AppColors.muted)),
  ]);
}

class _TurnoverChart extends StatefulWidget {
  const _TurnoverChart({super.key, required this.selectedYear});
  final String selectedYear;

  @override
  State<_TurnoverChart> createState() => _TurnoverChartState();
}

class _TurnoverChartState extends State<_TurnoverChart> {
  late Future<_TurnoverData> _futureData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(covariant _TurnoverChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedYear != widget.selectedYear) {
      _loadData();
    }
  }

  void _loadData() {
    _futureData = _calculateTurnover(widget.selectedYear);
  }

  static Future<_TurnoverData> _calculateTurnover(String yearStr) async {
    final year = int.tryParse(yearStr) ?? 2026;
    final invoices = await LocalErpStore.load('invoices');
    final customers = await LocalErpStore.load('customers');

    final customerCreatedMap = <String, DateTime>{};
    for (final c in customers) {
      final id = c['id']?.toString() ?? '';
      if (id.isEmpty) continue;

      DateTime? created;
      if (c['createdAt'] != null) {
        created = DateTime.tryParse(c['createdAt'].toString());
      }
      if (created == null) {
        final micro = int.tryParse(id);
        if (micro != null) {
          created = DateTime.fromMicrosecondsSinceEpoch(micro);
        }
      }
      customerCreatedMap[id] = created ?? DateTime(2020);
    }

    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep'];
    final newCustomers = List<double>.filled(months.length, 0.0);
    final existingCustomers = List<double>.filled(months.length, 0.0);

    for (final inv in invoices) {
      final issuedAtStr = inv['issuedAt']?.toString();
      if (issuedAtStr == null) continue;
      final issuedAt = DateTime.tryParse(issuedAtStr);
      if (issuedAt == null || issuedAt.year != year) continue;

      final monthIdx = issuedAt.month - 1;
      if (monthIdx < 0 || monthIdx >= months.length) continue;

      final total = (inv['total'] as num?)?.toDouble() ?? 0.0;
      final custId = inv['customerId']?.toString() ?? '';
      final custCreated = customerCreatedMap[custId] ?? DateTime(2020);

      final isNew = (custCreated.year == issuedAt.year && custCreated.month == issuedAt.month);

      if (isNew) {
        newCustomers[monthIdx] += total;
      } else {
        existingCustomers[monthIdx] += total;
      }
    }

    double maxVal = 0.0;
    for (int i = 0; i < months.length; i++) {
      final monthlySum = newCustomers[i] + existingCustomers[i];
      if (monthlySum > maxVal) maxVal = monthlySum;
    }

    if (maxVal == 0) maxVal = 40000;

    return _TurnoverData(
      months: months,
      newCustomers: newCustomers,
      existingCustomers: existingCustomers,
      maxVal: maxVal,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_TurnoverData>(
      future: _futureData,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!;
        final maxVal = data.maxVal;

        String formatVal(double val) {
          if (val >= 1000000) return '${(val / 1000000).toStringAsFixed(0)}M';
          if (val >= 1000) return '${(val / 1000).toStringAsFixed(0)}K';
          return val.toStringAsFixed(0);
        }

        final topLabel = formatVal(maxVal);
        final midHighLabel = formatVal(maxVal * 0.75);
        final midLabel = formatVal(maxVal * 0.50);
        final midLowLabel = formatVal(maxVal * 0.25);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 21, right: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(topLabel, style: const TextStyle(fontSize: 9, color: AppColors.muted)),
                  Text(midHighLabel, style: const TextStyle(fontSize: 9, color: AppColors.muted)),
                  Text(midLabel, style: const TextStyle(fontSize: 9, color: AppColors.muted)),
                  Text(midLowLabel, style: const TextStyle(fontSize: 9, color: AppColors.muted)),
                  const Text('0', style: TextStyle(fontSize: 9, color: AppColors.muted)),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(data.months.length, (i) {
                        final newAmt = data.newCustomers[i];
                        final existAmt = data.existingCustomers[i];
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final maxHeight = constraints.maxHeight;
                                final scale = maxVal > 0 ? maxHeight / maxVal : 0;
                                final existHeight = (existAmt * scale).clamp(0.0, maxHeight);
                                final newHeight = (newAmt * scale).clamp(0.0, maxHeight);

                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (existHeight > 0)
                                      Container(
                                        height: existHeight,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFCDE0D5),
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                                        ),
                                      ),
                                    if (newHeight > 0)
                                      Container(
                                        height: newHeight,
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: data.months
                        .map((month) => Expanded(
                              child: Text(
                                month,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 9, color: AppColors.dark),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TurnoverData {
  const _TurnoverData({
    required this.months,
    required this.newCustomers,
    required this.existingCustomers,
    required this.maxVal,
  });
  final List<String> months;
  final List<double> newCustomers;
  final List<double> existingCustomers;
  final double maxVal;
}

class _Kpi extends StatelessWidget {
  const _Kpi({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.pale, borderRadius: BorderRadius.circular(24)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: AppColors.primary, size: 24),
      const SizedBox(height: 12),
      Text(value, style: const TextStyle(fontSize: 26, color: AppColors.dark, fontWeight: FontWeight.w700)),
      Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
    ]),
  );
}

class _Activity extends StatelessWidget {
  const _Activity({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: CircleAvatar(backgroundColor: AppColors.pale, child: Icon(icon, color: AppColors.primary)),
    title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
    subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
  );
}