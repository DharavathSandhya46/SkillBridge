import 'package:flutter/material.dart';
import '../services/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/skill_card.dart';
import '../widgets/skill_dialog.dart';

class SkillsScreen extends StatelessWidget {
  final AppStore store;
  const SkillsScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final suggestions = store.suggestedSkills();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('My Skills'),
        actions: [
          IconButton(
            tooltip: 'Add skill',
            onPressed: () => showSkillDialog(context, store),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 90),
        children: [
          Text('Track your strengths and keep improving.', style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 18),
          if (store.skills.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    const Icon(Icons.auto_awesome, size: 40, color: AppColors.purple),
                    const SizedBox(height: 10),
                    const Text('No skills yet', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                    const SizedBox(height: 6),
                    const Text('Add your first skill to start tracking progress.', textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () => showSkillDialog(context, store),
                      icon: const Icon(Icons.add),
                      label: const Text('Add skill'),
                    ),
                  ],
                ),
              ),
            ),
          ...store.skills.map((skill) => SkillCard(key: ValueKey(skill.id), skill: skill, store: store)),
          if (suggestions.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text('Skills worth learning', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              'Most requested in current listings. Tap one to add it to your list.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: suggestions
                  .map(
                    (s) => ActionChip(
                      avatar: const Icon(Icons.add, size: 16),
                      label: Text('${s.name} • ${s.count} ${s.count == 1 ? 'role' : 'roles'}'),
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await store.addSkill(s.name, 'Learning', 1);
                        messenger.showSnackBar(SnackBar(content: Text('${s.name} added to your skills.')));
                      },
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showSkillDialog(context, store),
        icon: const Icon(Icons.add),
        label: const Text('Add skill'),
      ),
    );
  }
}
