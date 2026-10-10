import 'package:flutter/material.dart';
import '../models/opportunity.dart';
import '../services/app_store.dart';
import '../theme/app_theme.dart';
import '../utils/navigation.dart';
import 'match_badge.dart';

class OpportunityCard extends StatelessWidget {
  final Opportunity opportunity;
  final AppStore store;
  final VoidCallback? onTap;
  final bool compact;

  const OpportunityCard({
    super.key,
    required this.opportunity,
    required this.store,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final applied = store.hasApplied(opportunity.id);
    final match = store.matchFor(opportunity);
    final days = opportunity.daysLeft;
    final typeColor = AppColors.forType(opportunity.type);

    String deadlineText = 'Deadline: ${opportunity.deadline}';
    if (days != null && days >= 0) {
      deadlineText += days == 0 ? ' • closes today' : ' • $days days left';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap ?? () => openOpportunity(context, store, opportunity),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: typeColor.withValues(alpha: 0.15),
                    child: Text(
                      opportunity.company[0],
                      style: TextStyle(color: typeColor, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          opportunity.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 3),
                        Text(opportunity.company, style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: opportunity.saved ? 'Remove from saved' : 'Save',
                    onPressed: () => store.toggleSaved(opportunity.id),
                    icon: Icon(
                      opportunity.saved ? Icons.bookmark : Icons.bookmark_border,
                      color: opportunity.saved ? AppColors.purple : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 5,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Chip(label: Text(opportunity.type), visualDensity: VisualDensity.compact),
                  Chip(label: Text(opportunity.mode), visualDensity: VisualDensity.compact),
                  MatchBadge(percent: match.percent),
                ],
              ),
              if (!compact) ...[
                const SizedBox(height: 8),
                Text(
                  '${opportunity.location} • $deadlineText',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    children: [
                      for (var i = 0; i < opportunity.skills.length; i++) ...[
                        if (i > 0) const TextSpan(text: ' • '),
                        TextSpan(
                          text: opportunity.skills[i],
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: match.matched.contains(opportunity.skills[i])
                                ? AppColors.success
                                : null,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              if (applied)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, size: 17, color: AppColors.success),
                      SizedBox(width: 5),
                      Text('Applied', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
