import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../data/module_catalog.dart';

class ModulesScreen extends StatelessWidget {
  const ModulesScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final columns = constraints.maxWidth >= 700 ? 4 : 2;
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('All Modules', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.dark)),
          const SizedBox(height: 6),
          const Text('Everything your business needs, in one place.', style: TextStyle(color: AppColors.muted, fontSize: 13)),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: erpModules.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 154,
            ),
            itemBuilder: (context, index) {
              final module = erpModules[index];
              return Material(
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => module.screen),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.pale, borderRadius: BorderRadius.circular(9)), child: Icon(module.icon, color: AppColors.blue, size: 25)),
                      const Spacer(),
                      Text(module.title, style: const TextStyle(color: AppColors.dark, fontWeight: FontWeight.w700, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(module.subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 11), maxLines: 2),
                    ]),
                  ),
                ),
              );
            },
          ),
        ],
      );
    });
  }
}

