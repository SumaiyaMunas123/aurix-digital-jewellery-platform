import 'package:flutter/material.dart';
import 'package:aurix/core/widgets/aurix_page_scaffold.dart';
import 'package:aurix/core/widgets/aurix_glass_card.dart';
import 'package:aurix/core/navigation/nav.dart';
import 'package:aurix/dev/dummy_data/dummy_jewellers.dart';
import 'package:aurix/core/theme/app_colors.dart';
import 'package:aurix/features/customer/jewellers/jeweller_detail_screen.dart';

class VerifiedJewellersScreen extends StatelessWidget {
  const VerifiedJewellersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = DummyJewellers.items;

    return AurixPageScaffold(
      title: "Verified Jewellers",
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final j = items[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AurixGlassCard(
              child: ListTile(
                onTap: () => Nav.push(
                  context,
                  JewellerDetailScreen(
                    jewellerName: j['name'] ?? 'Jeweller',
                    city: j['city'] ?? '-',
                  ),
                ),
                leading: CircleAvatar(
                  backgroundColor: AppColors.gold.withValues(alpha: 0.18),
                  child:
                      const Icon(Icons.verified_rounded, color: AppColors.gold),
                ),
                title: Text(j["name"]!,
                    style: const TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text(j["city"]!),
                trailing: const Icon(Icons.chevron_right_rounded),
              ),
            ),
          );
        },
      ),
    );
  }
}
