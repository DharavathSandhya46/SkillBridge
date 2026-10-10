import 'package:flutter/material.dart';
import '../models/skill.dart';
import '../services/app_store.dart';
import '../theme/app_theme.dart';
import 'skill_dialog.dart';

class SkillCard extends StatelessWidget {
  final Skill skill;
  final AppStore store;

  const SkillCard({super.key, required this.skill, required this.store});

  Future<void> _confirmDelete(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete skill?'),
        content: Text('Remove "${skill.name}" from your skills?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) {
      final name = skill.name;
      await store.removeSkill(skill.id);
      messenger.showSnackBar(SnackBar(content: Text('$name removed.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forProgress(skill.progress);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 6, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.15),
                  child: Text(
                    skill.name[0].toUpperCase(),
                    style: TextStyle(color: color, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(skill.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(skill.category, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                ),
                Text('Level ${skill.level}/5', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                PopupMenuButton<String>(
                  tooltip: 'Skill options',
                  onSelected: (value) {
                    if (value == 'edit') showSkillDialog(context, store, existing: skill);
                    if (value == 'delete') _confirmDelete(context);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit skill')),
                    PopupMenuItem(value: 'delete', child: Text('Delete skill')),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10, top: 6),
              child: Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: skill.progress / 100,
                      minHeight: 8,
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('${skill.progress}%'),
                ],
              ),
            ),
            Slider(
              value: skill.progress.toDouble(),
              min: 0,
              max: 100,
              divisions: 20,
              label: '${skill.progress}%',
              onChanged: (value) => store.updateSkillProgress(skill.id, value.round()),
            ),
          ],
        ),
      ),
    );
  }
}
