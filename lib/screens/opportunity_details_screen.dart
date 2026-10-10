import 'package:flutter/material.dart';
import '../models/opportunity.dart';
import '../services/app_store.dart';
import '../theme/app_theme.dart';
import '../utils/navigation.dart';
import '../widgets/app_background.dart';
import '../widgets/opportunity_card.dart';

class OpportunityDetailsScreen extends StatelessWidget {
  final Opportunity opportunity;
  final AppStore store;

  const OpportunityDetailsScreen({super.key, required this.opportunity, required this.store});

  String _matchMessage(int percent) {
    if (percent >= 80) return 'Great fit! You already have most of the required skills.';
    if (percent >= 50) return 'Good start. Close a few gaps to strengthen your application.';
    return 'Build the skills below to become a stronger candidate.';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final applied = store.hasApplied(opportunity.id);
        final match = store.matchFor(opportunity);
        final similar = store.similarTo(opportunity);
        final days = opportunity.daysLeft;
        final matchColor = AppColors.forMatch(match.percent);

        String deadlineText = opportunity.deadline;
        if (days != null && days >= 0) {
          deadlineText += days == 0 ? '  (closes today)' : '  ($days days left)';
        }

        return AppBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: const Text('Opportunity'),
              actions: [
                IconButton(
                  tooltip: opportunity.saved ? 'Remove from saved' : 'Save',
                  onPressed: () => store.toggleSaved(opportunity.id),
                  icon: Icon(opportunity.saved ? Icons.bookmark : Icons.bookmark_border),
                ),
              ],
            ),
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: applied
                    ? FilledButton.icon(
                        onPressed: () => openTab(context, store, Tabs.tracker),
                        icon: const Icon(Icons.track_changes),
                        label: const Text('Applied - view in tracker'),
                      )
                    : FilledButton.icon(
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          await store.apply(opportunity);
                          messenger.showSnackBar(
                            SnackBar(
                              content: const Text('Application added to your tracker.'),
                              action: SnackBarAction(
                                label: 'View',
                                onPressed: () => openTab(context, store, Tabs.tracker),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.send),
                        label: const Text('Apply & track'),
                      ),
              ),
            ),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 30),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.heroGradient,
                    borderRadius: BorderRadius.circular(24),
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
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Text(
                          opportunity.company[0],
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        opportunity.title,
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(opportunity.company, style: const TextStyle(color: Colors.white70, fontSize: 16)),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _Pill(text: opportunity.type, icon: Icons.work_outline),
                          _Pill(text: opportunity.mode, icon: Icons.laptop_mac),
                          _Pill(text: opportunity.location, icon: Icons.place_outlined),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 66,
                              height: 66,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox.expand(
                                    child: CircularProgressIndicator(
                                      value: match.percent / 100,
                                      strokeWidth: 7,
                                      color: matchColor,
                                      backgroundColor: matchColor.withValues(alpha: 0.15),
                                    ),
                                  ),
                                  Text('${match.percent}%', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Your skill match', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                                  const SizedBox(height: 4),
                                  Text(_matchMessage(match.percent), style: TextStyle(color: Colors.grey.shade600, height: 1.35)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (match.matched.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text('You have', style: TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: match.matched
                                .map((s) => Chip(
                                      avatar: const Icon(Icons.check_circle, size: 18, color: AppColors.success),
                                      label: Text(s),
                                    ))
                                .toList(),
                          ),
                        ],
                        if (match.learning.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          const Text('Still learning', style: TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: match.learning
                                .map((s) => ActionChip(
                                      avatar: const Icon(Icons.school_outlined, size: 18, color: AppColors.primary),
                                      label: Text(s),
                                      onPressed: () => store.goToTab(Tabs.skills),
                                    ))
                                .toList(),
                          ),
                        ],
                        if (match.missing.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          const Text('Skills to learn (tap to add)', style: TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: match.missing
                                .map((s) => ActionChip(
                                      avatar: const Icon(Icons.add_circle_outline, size: 18, color: AppColors.warning),
                                      label: Text(s),
                                      onPressed: () async {
                                        final messenger = ScaffoldMessenger.of(context);
                                        final added = await store.addSkill(s, 'Learning', 1);
                                        messenger.showSnackBar(SnackBar(
                                          content: Text(added ? '$s added to your skills.' : '$s is already in your skills.'),
                                        ));
                                      },
                                    ))
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoRow(icon: Icons.event, label: 'Deadline', value: deadlineText),
                        const SizedBox(height: 14),
                        _InfoRow(icon: Icons.place_outlined, label: 'Location', value: opportunity.location),
                        const SizedBox(height: 14),
                        _InfoRow(icon: Icons.laptop_mac, label: 'Work mode', value: opportunity.mode),
                        const SizedBox(height: 18),
                        const Text('About the opportunity', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text(opportunity.description, style: const TextStyle(height: 1.5)),
                      ],
                    ),
                  ),
                ),
                if (similar.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  Text('Similar opportunities', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ...similar.map((o) => OpportunityCard(opportunity: o, store: store, compact: true)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final IconData icon;
  const _Pill({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: Colors.white),
            const SizedBox(width: 6),
            Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      );
}
