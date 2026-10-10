import 'package:flutter/material.dart';
import '../models/skill.dart';
import '../services/app_store.dart';

/// Opens the add-skill dialog, or the edit dialog when [existing] is given.
Future<void> showSkillDialog(BuildContext context, AppStore store, {Skill? existing}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _SkillDialog(store: store, existing: existing),
  );
}

class _SkillDialog extends StatefulWidget {
  final AppStore store;
  final Skill? existing;
  const _SkillDialog({required this.store, this.existing});

  @override
  State<_SkillDialog> createState() => _SkillDialogState();
}

class _SkillDialogState extends State<_SkillDialog> {
  late final TextEditingController name =
      TextEditingController(text: widget.existing?.name ?? '');
  late final TextEditingController category =
      TextEditingController(text: widget.existing?.category ?? '');
  int level = 3;
  String? error;

  @override
  void dispose() {
    name.dispose();
    category.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (name.text.trim().isEmpty) {
      setState(() => error = 'Please enter a skill name');
      return;
    }
    final existing = widget.existing;
    if (existing == null) {
      final ok = await widget.store.addSkill(name.text, category.text, level);
      if (!ok) {
        setState(() => error = 'This skill is already in your list');
        return;
      }
    } else {
      await widget.store.editSkill(existing.id, name.text, category.text);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existing != null;
    return AlertDialog(
      title: Text(editing ? 'Edit skill' : 'Add a skill'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              autofocus: true,
              decoration: InputDecoration(labelText: 'Skill name', errorText: error),
              onChanged: (_) {
                if (error != null) setState(() => error = null);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: category,
              decoration: const InputDecoration(labelText: 'Category (e.g. Programming)'),
            ),
            if (!editing) ...[
              const SizedBox(height: 14),
              DropdownButtonFormField<int>(
                value: level,
                decoration: const InputDecoration(labelText: 'Level'),
                items: [1, 2, 3, 4, 5]
                    .map((e) => DropdownMenuItem(value: e, child: Text('$e / 5')))
                    .toList(),
                onChanged: (v) => setState(() => level = v ?? 3),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _submit, child: Text(editing ? 'Save' : 'Add')),
      ],
    );
  }
}
