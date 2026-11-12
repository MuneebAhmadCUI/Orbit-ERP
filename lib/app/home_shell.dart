import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/modules/screens/modules_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selected = 0;

  void _openModules() => setState(() => _selected = 1);

  void _onTab(int index) {
    if (index < 2) {
      setState(() => _selected = index);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${['', '', 'Search', 'Notifications', 'Profile'][index]} is planned for the next milestone.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['Dashboard', 'Modules'];
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: AppColors.primary),
          onPressed: _openModules,
          tooltip: 'Open modules',
        ),
        title: Text(titles[_selected], style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        actions: [
          if (_selected == 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: '2026',
                  items: const [DropdownMenuItem(value: '2026', child: Text('2026')), DropdownMenuItem(value: '2025', child: Text('2025'))],
                  onChanged: (_) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Year filtering will be connected to the reports API.'))),
                ),
              ),
            ),
        ],
      ),
      body: IndexedStack(
        index: _selected,
        children: const [DashboardScreen(), ModulesScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        height: 76,
        backgroundColor: Colors.white,
        indicatorColor: AppColors.pale,
        selectedIndex: _selected,
        onDestinationSelected: _onTab,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard_rounded, color: AppColors.primary), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view_rounded, color: AppColors.primary), label: 'Modules'),
          NavigationDestination(icon: Icon(Icons.search_rounded), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.notifications_none_rounded), label: 'Alerts'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), label: 'Account'),
        ],
      ),
    );
  }
}
