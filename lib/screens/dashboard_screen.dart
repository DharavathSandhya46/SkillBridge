import 'package:flutter/material.dart';
import '../services/app_store.dart';
import '../theme/app_theme.dart';
import '../utils/navigation.dart';
import '../widgets/opportunity_card.dart';
import '../widgets/skill_dialog.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends StatelessWidget {
  final AppStore store;

  const DashboardScreen({super.key, required this.store});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final applied = store.applications.length;
    final interviews = store.applications.where((a) => a.status == 'Interview').length;
    final saved = store.savedOpportunities.length;
    final avg = store.skills.isEmpty
        ? 0
        : (store.skills.map((s) => s.progress).reduce((a, b) => a + b) / store.skills.length).round();
    final recommended = store.recommended();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_greeting()}, ${store.studentName} 👋',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Build skills. Find opportunities. Track your growth.',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                customBorder: const CircleBorder(),
                onTap: () => store.goToTab(Tabs.profile),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    store.studentName.isNotEmpty ? store.studentName[0].toUpperCase() : 'S',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.28),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.rocket_launch_rounded, size: 30, color: Colors.white),
                    const SizedBox(width: 12),
                    Text(
                      'Career readiness',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                LinearProgressIndicator(
                  value: avg / 100,
                  minHeight: 9,
                  color: Colors.white,
                  backgroundColor: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$avg% overall skill progress',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(foregroundColor: Colors.white),
                      onPressed: () => store.goToTab(Tabs.skills),
                      icon: const Icon(Icons.arrow_forward, size: 18),
                      label: const Text('Improve skills'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.auto_awesome,
                  value: '${store.skills.length}',
                  label: 'Skills',
                  color: AppColors.primary,
                  onTap: () => store.goToTab(Tabs.skills),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  icon: Icons.bookmark,
                  value: '$saved',
                  label: 'Saved',
                  color: AppColors.purple,
                  onTap: () => openSaved(context, store),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  icon: Icons.send,
                  value: '$applied',
                  label: 'Applied',
                  color: AppColors.success,
                  onTap: () => store.goToTab(Tabs.tracker),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  icon: Icons.event_available,
                  value: '$interviews',
                  label: 'Interviews',
                  color: AppColors.warning,
                  onTap: () => store.goToTab(Tabs.tracker),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text('Quick actions', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _QuickAction(
                  icon: Icons.search,
                  label: 'Explore',
                  color: AppColors.primary,
                  onTap: () => store.goToTab(Tabs.explore),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickAction(
                  icon: Icons.add_circle_outline,
                  label: 'Add skill',
                  color: AppColors.purple,
                  onTap: () => showSkillDialog(context, store),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickAction(
                  icon: Icons.track_changes,
                  label: 'Tracker',
                  color: AppColors.success,
                  onTap: () => store.goToTab(Tabs.tracker),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickAction(
                  icon: Icons.bookmark_outline,
                  label: 'Saved',
                  color: AppColors.warning,
                  onTap: () => openSaved(context, store),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recommended for you', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              TextButton(onPressed: () => store.goToTab(Tabs.explore), child: const Text('See all')),
            ],
          ),
          const SizedBox(height: 8),
          if (recommended.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Text('You have applied to everything available. Check the tracker for updates.'),
              ),
            ),
          ...recommended.map(
            (o) => OpportunityCard(opportunity: o, store: store, compact: true),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
