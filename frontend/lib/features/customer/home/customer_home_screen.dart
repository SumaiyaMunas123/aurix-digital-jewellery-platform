import 'package:flutter/material.dart';

import 'package:aurix/features/customer/home/widgets/live_gold_rate_card.dart';
import 'package:aurix/features/customer/home/widgets/section_header.dart';
import 'package:aurix/features/customer/home/widgets/featured_products_section.dart';
import 'package:aurix/features/customer/home/widgets/categories_row.dart';
import 'package:aurix/features/customer/home/widgets/deals_section.dart';
import 'package:aurix/features/customer/home/widgets/new_arrivals_section.dart';
import 'package:aurix/features/customer/home/widgets/verified_jewellers_section.dart';
import 'package:aurix/features/customer/home/widgets/trending_designs_section.dart';

import 'package:aurix/features/customer/see_all/categories_screen.dart';
import 'package:aurix/features/customer/see_all/deals_screen.dart';
import 'package:aurix/features/customer/see_all/new_arrivals_screen.dart';
import 'package:aurix/features/customer/see_all/verified_jewellers_screen.dart';
import 'package:aurix/features/customer/see_all/trending_screen.dart';

import 'package:aurix/core/navigation/nav.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ bottom padding so scrolling content doesn’t feel cramped near nav
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LiveGoldRateCard(),
          const SizedBox(height: 18),

          SectionHeader(
            title: "Featured",
            actionText: "See all",
            onAction: () => Nav.push(context, const NewArrivalsScreen(titleOverride: "Featured")),
          ),
          const SizedBox(height: 10),
          const FeaturedProductsSection(),
          const SizedBox(height: 18),

          SectionHeader(
            title: "Categories",
            actionText: "See all",
            onAction: () => Nav.push(context, const CategoriesScreen()),
          ),
          const SizedBox(height: 10),
          const CategoriesRow(),
          const SizedBox(height: 18),

          SectionHeader(
            title: "Deals",
            actionText: "See all",
            onAction: () => Nav.push(context, const DealsScreen()),
          ),
          const SizedBox(height: 10),
          const DealsSection(),
          const SizedBox(height: 18),

          SectionHeader(
            title: "New Arrivals",
            actionText: "See all",
            onAction: () => Nav.push(context, const NewArrivalsScreen()),
          ),
          const SizedBox(height: 10),
          const NewArrivalsSection(),
          const SizedBox(height: 18),

          SectionHeader(
            title: "Verified Jewellers",
            actionText: "See all",
            onAction: () => Nav.push(context, const VerifiedJewellersScreen()),
          ),
          const SizedBox(height: 10),
          const VerifiedJewellersSection(),
          const SizedBox(height: 18),

          SectionHeader(
            title: "Trending",
            actionText: "See all",
            onAction: () => Nav.push(context, const TrendingScreen()),
          ),
          const SizedBox(height: 10),
          const TrendingDesignsSection(),
        ],
      ),
    );
  }
}