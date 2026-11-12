import 'package:flutter/material.dart';
import '../../human_resources/screens/human_resources_screen.dart';
import '../../inventory/screens/inventory_screen.dart';
import '../../sales/screens/sales_screen.dart';
import '../../purchasing/screens/purchasing_screen.dart';
import '../../finance/screens/finance_screen.dart';
import '../../projects/screens/projects_screen.dart';
import '../../warehouse/screens/warehouse_screen.dart';
import '../../manufacturing/screens/manufacturing_screen.dart';
import '../../reports/screens/reports_screen.dart';
import '../../approvals/screens/approvals_screen.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../settings/screens/settings_screen.dart';

class ErpModule {
  const ErpModule(this.title, this.icon, this.subtitle, this.screen);
  final String title;
  final IconData icon;
  final String subtitle;
  final Widget screen;
}

const erpModules = <ErpModule>[
    ErpModule('Human Resources', Icons.people_outline_rounded, 'Employees, leave, payroll', HumanResourcesScreen()),
    ErpModule('Inventory', Icons.inventory_2_outlined, 'Products and stock', InventoryScreen()),
    ErpModule('Sales & CRM', Icons.shopping_cart_outlined, 'Customers and orders', SalesScreen()),
    ErpModule('Purchasing', Icons.local_shipping_outlined, 'Vendors and POs', PurchasingScreen()),
    ErpModule('Finance', Icons.account_balance_wallet_outlined, 'Accounting and expenses', FinanceScreen()),
    ErpModule('Projects', Icons.folder_copy_outlined, 'Tasks and milestones', ProjectsScreen()),
    ErpModule('Warehouse', Icons.warehouse_outlined, 'Locations and transfers', WarehouseScreen()),
    ErpModule('Manufacturing', Icons.precision_manufacturing_outlined, 'Production workflows', ManufacturingScreen()),
    ErpModule('Reports', Icons.bar_chart_rounded, 'Insights and exports', ReportsScreen()),
    ErpModule('Approvals', Icons.fact_check_outlined, 'Review requests', ApprovalsScreen()),
    ErpModule('Notifications', Icons.notifications_none_rounded, 'Alerts and updates', NotificationsScreen()),
    ErpModule('Settings', Icons.settings_outlined, 'Company preferences', SettingsScreen()),
];
