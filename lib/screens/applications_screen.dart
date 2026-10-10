import 'package:flutter/material.dart';
import '../models/application.dart';
import '../services/app_store.dart';
import '../theme/app_theme.dart';
import '../utils/navigation.dart';

class ApplicationsScreen extends StatefulWidget {
  final AppStore store;
  const ApplicationsScreen({super.key, required this.store});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  static const statuses = ['Applied', 'Interview', 'Selected', 'Rejected'];
  String filter = 'All';

  Color _statusColor(String status) {
    if (status == 'Selected') return AppColors.success;
    if (status == 'Rejected') return AppColors.danger;
    if (status == 'Interview') return AppColors.warning;
    return AppColors.primary;
  }

  Future<void> _remove(Application a) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove application?'),
        content: Text('Remove your application for "${a.title}" at ${a.company} from the tracker?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Remove')),
        ],
      ),
    );
    if (ok == true) {
      await widget.store.removeApplication(a.id);
      messenger.showSnackBar(const SnackBar(content: Text('Application removed.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final all = store.applications;
    final shown = filter == 'All' ? all : all.where((a) => a.status == filter).toList();
    int count(String s) => all.where((a) => a.status == s).length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Application Tracker')),
      body: all.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.track_changes, size: 52, color: AppColors.purple),
                    const SizedBox(height: 12),
                    const Text('No applications yet', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                    const SizedBox(height: 6),
                    const Text('Explore opportunities and apply to start tracking.', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => store.goToTab(Tabs.explore),
                      icon: const Icon(Icons.search),
                      label: const Text('Explore opportunities'),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 25),
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', ...statuses]
                        .map((s) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(s == 'All' ? 'All (${all.length})' : '$s (${count(s)})'),
                                selected: filter == s,
                                onSelected: (_) => setState(() => filter = s),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 14),
                if (shown.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text('No applications with this status.')),
                  ),
                ...shown.map((a) {
                  final color = _statusColor(a.status);
                  final opportunity = store.findOpportunity(a.opportunityId);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: opportunity == null ? null : () => openOpportunity(context, store, opportunity),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(17, 14, 6, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: color.withValues(alpha: 0.15),
                                  child: Text(a.company[0], style: TextStyle(color: color, fontWeight: FontWeight.w800)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(a.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text(a.company, style: TextStyle(color: Colors.grey.shade600)),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  tooltip: 'Update status',
                                  onSelected: (value) {
                                    if (value == 'remove') {
                                      _remove(a);
                                    } else {
                                      store.updateApplicationStatus(a.id, value);
                                    }
                                  },
                                  itemBuilder: (_) => <PopupMenuEntry<String>>[
                                    ...statuses.map((s) => PopupMenuItem<String>(value: s, child: Text('Mark as $s'))),
                                    const PopupMenuDivider(),
                                    const PopupMenuItem<String>(value: 'remove', child: Text('Remove application')),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.only(right: 11),
                              child: Row(
                                children: [
                                  Icon(Icons.circle, size: 10, color: color),
                                  const SizedBox(width: 7),
                                  Text(a.status, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                                  const Spacer(),
                                  Text('Applied ${a.appliedOn}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}
