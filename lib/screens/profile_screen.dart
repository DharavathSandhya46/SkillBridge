import 'package:flutter/material.dart';
import '../services/app_store.dart';
import '../theme/app_theme.dart';
import '../utils/navigation.dart';
import '../widgets/stat_card.dart';

class ProfileScreen extends StatelessWidget {
  final AppStore store;
  const ProfileScreen({super.key, required this.store});

  void _edit(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _EditProfileSheet(store: store),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset app data?'),
        content: const Text(
          'This clears your skills, saved opportunities, applications and profile, and restores the sample data.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Reset')),
        ],
      ),
    );
    if (ok == true) {
      await store.resetAll();
      messenger.showSnackBar(const SnackBar(content: Text('App data reset.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final topSkills = [...store.skills]..sort((a, b) => b.progress.compareTo(a.progress));
    final initial = store.studentName.isNotEmpty ? store.studentName[0].toUpperCase() : 'S';

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: Colors.white,
                  child: Text(
                    initial,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  store.studentName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(store.college, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 2),
                Text('${store.branch} • Class of ${store.gradYear}', style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 2),
                Text(store.email, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.flag_outlined, size: 16, color: Colors.white),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Target: ${store.targetRole}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                  ),
                  onPressed: () => _edit(context),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit profile'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
                  value: '${store.savedOpportunities.length}',
                  label: 'Saved',
                  color: AppColors.purple,
                  onTap: () => openSaved(context, store),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  icon: Icons.send,
                  value: '${store.applications.length}',
                  label: 'Applied',
                  color: AppColors.success,
                  onTap: () => store.goToTab(Tabs.tracker),
                ),
              ),
            ],
          ),
          if (store.about.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('About me', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(store.about, style: const TextStyle(height: 1.5)),
                  ],
                ),
              ),
            ),
          ],
          if (topSkills.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Top skills', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: topSkills
                          .take(6)
                          .map((s) => ActionChip(
                                label: Text('${s.name} • ${s.progress}%'),
                                onPressed: () => store.goToTab(Tabs.skills),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          _MenuTile(
            icon: Icons.auto_awesome,
            color: AppColors.primary,
            title: 'My skills',
            subtitle: 'Manage your technical and soft skills',
            onTap: () => store.goToTab(Tabs.skills),
          ),
          _MenuTile(
            icon: Icons.work_outline,
            color: AppColors.purple,
            title: 'Explore opportunities',
            subtitle: 'Find internships, jobs and hackathons',
            onTap: () => store.goToTab(Tabs.explore),
          ),
          _MenuTile(
            icon: Icons.bookmark_outline,
            color: AppColors.warning,
            title: 'Saved opportunities',
            subtitle: '${store.savedOpportunities.length} saved for later',
            onTap: () => openSaved(context, store),
          ),
          _MenuTile(
            icon: Icons.track_changes,
            color: AppColors.success,
            title: 'Application tracker',
            subtitle: 'Keep every application in one place',
            onTap: () => store.goToTab(Tabs.tracker),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: SwitchListTile(
              secondary: CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: Icon(store.darkMode ? Icons.dark_mode : Icons.light_mode, color: AppColors.primary),
              ),
              title: const Text('Dark mode', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Switch between light and dark theme'),
              value: store.darkMode,
              onChanged: store.setDarkMode,
            ),
          ),
          _MenuTile(
            icon: Icons.info_outline,
            color: AppColors.primary,
            title: 'About SkillBridge',
            subtitle: 'Version 1.1.0',
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'SkillBridge',
              applicationVersion: '1.1.0',
              children: const [
                SizedBox(height: 12),
                Text(
                  'Track your skills, discover opportunities and manage applications. '
                  'Listings are sample data - always check the employer\'s official careers page before applying.',
                ),
              ],
            ),
          ),
          _MenuTile(
            icon: Icons.restart_alt,
            color: AppColors.danger,
            title: 'Reset app data',
            subtitle: 'Restore sample data and default profile',
            onTap: () => _confirmReset(context),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          onTap: onTap,
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
        ),
      );
}

class _EditProfileSheet extends StatefulWidget {
  final AppStore store;
  const _EditProfileSheet({required this.store});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController name = TextEditingController(text: widget.store.studentName);
  late final TextEditingController college = TextEditingController(text: widget.store.college);
  late final TextEditingController branch = TextEditingController(text: widget.store.branch);
  late final TextEditingController year = TextEditingController(text: widget.store.gradYear);
  late final TextEditingController email = TextEditingController(text: widget.store.email);
  late final TextEditingController role = TextEditingController(text: widget.store.targetRole);
  late final TextEditingController about = TextEditingController(text: widget.store.about);

  @override
  void dispose() {
    for (final c in [name, college, branch, year, email, role, about]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    await widget.store.updateProfile(
      name: name.text,
      collegeName: college.text,
      branchName: branch.text,
      year: year.text,
      mail: email.text,
      role: role.text,
      aboutText: about.text,
    );
    if (mounted) Navigator.pop(context);
    messenger.showSnackBar(const SnackBar(content: Text('Profile updated.')));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit profile', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 10),
            TextField(controller: college, decoration: const InputDecoration(labelText: 'College')),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(controller: branch, decoration: const InputDecoration(labelText: 'Branch')),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: year,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Grad. year'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 10),
            TextField(controller: role, decoration: const InputDecoration(labelText: 'Target role')),
            const SizedBox(height: 10),
            TextField(
              controller: about,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'About me'),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(onPressed: _save, child: const Text('Save')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
