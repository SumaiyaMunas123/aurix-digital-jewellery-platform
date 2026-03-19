import 'package:flutter/material.dart';

import '../../../core/navigation/nav.dart';
import '../../../core/widgets/aurix_background.dart';
import '../see_all/categories_screen.dart';
import '../see_all/deals_screen.dart';
import '../see_all/new_arrivals_screen.dart';
import '../see_all/trending_screen.dart';
import '../see_all/verified_jewellers_screen.dart';

import 'widgets/categories_row.dart';
import 'widgets/deals_section.dart';
import 'widgets/featured_products_section.dart';
import 'widgets/metals_rates_carousel.dart';
import 'widgets/new_arrivals_section.dart';
import 'widgets/section_header.dart';
import 'widgets/trending_designs_section.dart';
import 'widgets/verified_jewellers_section.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AurixBackground(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
        children: [
          const SizedBox(height: 4),

          const SectionHeader(title: 'Metal Rate'),
          const SizedBox(height: 12),
          const MetalsRatesCarousel(),

          const SizedBox(height: 20),

          SectionHeader(
            title: 'Featured',
            onSeeAll: () => Nav.push(context, const DealsScreen()),
          ),
          const SizedBox(height: 12),
          const FeaturedProductsSection(),

          const SizedBox(height: 20),

          SectionHeader(
            title: 'Categories',
            onSeeAll: () => Nav.push(context, const CategoriesScreen()),
          ),
          const SizedBox(height: 12),
          const CategoriesRow(),

          const SizedBox(height: 20),

          SectionHeader(
            title: 'New Arrivals',
            onSeeAll: () => Nav.push(context, const NewArrivalsScreen()),
          ),
          const SizedBox(height: 12),
          const NewArrivalsSection(),

          const SizedBox(height: 20),

          SectionHeader(
            title: 'Trending Designs',
            onSeeAll: () => Nav.push(context, const TrendingScreen()),
          ),
          const SizedBox(height: 12),
          const TrendingDesignsSection(),

          const SizedBox(height: 20),

          SectionHeader(
            title: 'Verified Jewellers',
            onSeeAll: () => Nav.push(context, const VerifiedJewellersScreen()),
          ),
          const SizedBox(height: 12),
          const VerifiedJewellersSection(),

          const SizedBox(height: 20),

          SectionHeader(
            title: 'Deals',
            onSeeAll: () => Nav.push(context, const DealsScreen()),
          ),
          const SizedBox(height: 12),
          const DealsSection(),
        ],
      ),
    );
  }
}