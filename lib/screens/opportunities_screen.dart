import 'package:flutter/material.dart';
import '../models/opportunity.dart';
import '../services/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/opportunity_card.dart';

class OpportunitiesScreen extends StatefulWidget {
  final AppStore store;
  const OpportunitiesScreen({super.key, required this.store});

  @override
  State<OpportunitiesScreen> createState() => _OpportunitiesScreenState();
}

class _OpportunitiesScreenState extends State<OpportunitiesScreen> {
  String filter = 'All';
  String modeFilter = 'Any';
  String sort = 'Best match';
  String search = '';
  final controller = TextEditingController();

  static const typeFilters = ['All', 'Internship', 'Job', 'Hackathon'];
  static const modeFilters = ['Any', 'Remote', 'Hybrid', 'On-site'];
  static const sortOptions = ['Best match', 'Deadline'];
  static const roleSuggestions = [
    'Software Developer', 'Full Stack Developer', 'Frontend Developer',
    'Backend Developer', 'Python Developer', 'Java Developer',
    'Data Analyst', 'AI/ML Engineer', 'Flutter Developer', 'Cybersecurity',
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  bool matchesSearch(Opportunity opportunity) {
    final query = search.trim().toLowerCase();
    if (query.isEmpty) return true;
    final words = query.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    final text = '${opportunity.title} ${opportunity.company} ${opportunity.skills.join(' ')} ${opportunity.description} ${opportunity.type} ${opportunity.location}'.toLowerCase();
    // Match all words, so typing a role or skill returns related listings.
    return words.every((word) => text.contains(word));
  }

  void chooseRole(String role) {
    controller.text = role;
    setState(() => search = role);
  }

  void resetAll() {
    controller.clear();
    setState(() {
      search = '';
      filter = 'All';
      modeFilter = 'Any';
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final results = store.opportunities.where((o) {
      return (filter == 'All' || o.type == filter) &&
          (modeFilter == 'Any' || o.mode == modeFilter) &&
          matchesSearch(o);
    }).toList();

    if (sort == 'Best match') {
      results.sort((a, b) {
        final c = store.matchFor(b).percent.compareTo(store.matchFor(a).percent);
        return c != 0 ? c : a.title.compareTo(b.title);
      });
    } else {
      final far = DateTime.utc(2100);
      results.sort((a, b) => (a.deadlineDate ?? far).compareTo(b.deadlineDate ?? far));
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Explore opportunities')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Find your next opportunity', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800)),
                SizedBox(height: 6),
                Text('Search any role, company, or skill to see matching opportunities.', style: TextStyle(color: Colors.white, height: 1.4)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            onChanged: (value) => setState(() => search = value),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'e.g. Data Analyst, Java Developer...',
              suffixIcon: search.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        controller.clear();
                        setState(() => search = '');
                      },
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Popular roles', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: roleSuggestions
                .map((role) => ActionChip(label: Text(role), onPressed: () => chooseRole(role)))
                .toList(),
          ),
          const SizedBox(height: 18),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: typeFilters
                  .map((f) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(f),
                          selected: filter == f,
                          onSelected: (_) => setState(() => filter = f),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Icon(Icons.place_outlined, size: 18),
                const SizedBox(width: 8),
                ...modeFilters.map((m) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(m),
                        selected: modeFilter == m,
                        onSelected: (_) => setState(() => modeFilter = m),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${results.length} opportunities found',
                  style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Sort',
                initialValue: sort,
                onSelected: (value) => setState(() => sort = value),
                itemBuilder: (_) => sortOptions
                    .map((s) => PopupMenuItem(value: s, child: Text(s)))
                    .toList(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.sort, size: 18),
                      const SizedBox(width: 4),
                      Text(sort, style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...results.map((o) => OpportunityCard(opportunity: o, store: store)),
          if (results.isEmpty)
            Card(
              margin: const EdgeInsets.only(top: 18),
              child: Padding(
                padding: const EdgeInsets.all(26),
                child: Column(
                  children: [
                    const Icon(Icons.search_off_rounded, size: 42, color: AppColors.purple),
                    const SizedBox(height: 10),
                    const Text('No exact matches yet', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                    const SizedBox(height: 6),
                    const Text(
                      'Try a shorter role name, company name, or skill such as Python, Java, SQL, or React.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(onPressed: resetAll, child: const Text('Show all opportunities')),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
