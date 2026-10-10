import 'package:flutter/material.dart';
import '../services/app_store.dart';
import '../theme/app_theme.dart';
import '../utils/navigation.dart';
import '../widgets/app_background.dart';
import '../widgets/opportunity_card.dart';

class SavedScreen extends StatelessWidget {
  final AppStore store;
  const SavedScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final saved = store.savedOpportunities;
        return AppBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(title: const Text('Saved opportunities')),
            body: saved.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bookmark_border, size: 52, color: AppColors.purple),
                          const SizedBox(height: 12),
                          const Text('Nothing saved yet', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                          const SizedBox(height: 6),
                          const Text(
                            'Tap the bookmark on any opportunity to keep it here.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () => openTab(context, store, Tabs.explore),
                            icon: const Icon(Icons.search),
                            label: const Text('Explore opportunities'),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
                    children: [
                      Text(
                        '${saved.length} saved',
                        style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      ...saved.map((o) => OpportunityCard(opportunity: o, store: store)),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
