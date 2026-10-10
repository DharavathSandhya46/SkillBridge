import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/skill.dart';
import '../models/opportunity.dart';
import '../models/application.dart';

/// How well the student's skills cover an opportunity's required skills.
class MatchResult {
  final List<String> matched;
  final List<String> learning;
  final List<String> missing;
  final int percent;

  const MatchResult({
    required this.matched,
    required this.learning,
    required this.missing,
    required this.percent,
  });
}

/// A skill that appears in many listings but is not yet in the student's list.
class SkillDemand {
  final String name;
  final int count;
  const SkillDemand(this.name, this.count);
}

class AppStore extends ChangeNotifier {
  static const _skillsKey = 'skills';
  static const _opportunitiesKey = 'opportunities';
  static const _applicationsKey = 'applications';
  static const _nameKey = 'student_name';
  static const _collegeKey = 'college';
  static const _emailKey = 'email';
  static const _branchKey = 'branch';
  static const _yearKey = 'grad_year';
  static const _roleKey = 'target_role';
  static const _aboutKey = 'about';
  static const _darkKey = 'dark_mode';

  /// A skill counts towards a match once progress reaches this percentage.
  static const matchThreshold = 30;

  static const _defaultName = 'Sandhya';
  static const _defaultCollege = 'BVRIT Hyderabad';
  static const _defaultEmail = 'student@example.com';
  static const _defaultBranch = 'Computer Science';
  static const _defaultYear = '2027';
  static const _defaultRole = 'Software Developer';
  static const _defaultAbout =
      'Student who enjoys building software and learning new technologies.';

  /// Currently selected bottom-navigation tab (0 Home, 1 Skills, 2 Explore, 3 Tracker, 4 Profile).
  final ValueNotifier<int> tabIndex = ValueNotifier<int>(0);

  List<Skill> skills = [];
  List<Opportunity> opportunities = [];
  List<Application> applications = [];
  String studentName = _defaultName;
  String college = _defaultCollege;
  String email = _defaultEmail;
  String branch = _defaultBranch;
  String gradYear = _defaultYear;
  String targetRole = _defaultRole;
  String about = _defaultAbout;
  bool darkMode = false;

  void goToTab(int index) {
    tabIndex.value = index;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    studentName = prefs.getString(_nameKey) ?? studentName;
    college = prefs.getString(_collegeKey) ?? college;
    email = prefs.getString(_emailKey) ?? email;
    branch = prefs.getString(_branchKey) ?? branch;
    gradYear = prefs.getString(_yearKey) ?? gradYear;
    targetRole = prefs.getString(_roleKey) ?? targetRole;
    about = prefs.getString(_aboutKey) ?? about;
    darkMode = prefs.getBool(_darkKey) ?? darkMode;

    final skillsJson = prefs.getString(_skillsKey);
    final oppJson = prefs.getString(_opportunitiesKey);
    final appJson = prefs.getString(_applicationsKey);

    if (skillsJson == null) {
      skills = _defaultSkills();
    } else {
      skills = (jsonDecode(skillsJson) as List)
          .map((e) => Skill.fromJson(e))
          .toList();
    }

    if (oppJson == null) {
      opportunities = _defaultOpportunities();
    } else {
      opportunities = (jsonDecode(oppJson) as List)
          .map((e) => Opportunity.fromJson(e))
          .toList();
      // Add newly bundled opportunities without removing the user's saved/applied state.
      final existingIds = opportunities.map((o) => o.id).toSet();
      opportunities.addAll(
        _defaultOpportunities().where((o) => !existingIds.contains(o.id)),
      );
    }

    if (appJson != null) {
      applications = (jsonDecode(appJson) as List)
          .map((e) => Application.fromJson(e))
          .toList();
    }

    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_skillsKey, jsonEncode(skills.map((e) => e.toJson()).toList()));
    await prefs.setString(_opportunitiesKey, jsonEncode(opportunities.map((e) => e.toJson()).toList()));
    await prefs.setString(_applicationsKey, jsonEncode(applications.map((e) => e.toJson()).toList()));
    await prefs.setString(_nameKey, studentName);
    await prefs.setString(_collegeKey, college);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_branchKey, branch);
    await prefs.setString(_yearKey, gradYear);
    await prefs.setString(_roleKey, targetRole);
    await prefs.setString(_aboutKey, about);
    await prefs.setBool(_darkKey, darkMode);
  }

  // ---------------------------------------------------------------- skills

  /// Returns false if a skill with the same name already exists.
  Future<bool> addSkill(String name, String category, int level) async {
    final cleaned = name.trim();
    if (cleaned.isEmpty) return false;
    final exists = skills.any((s) => s.name.trim().toLowerCase() == cleaned.toLowerCase());
    if (exists) return false;
    skills.add(Skill(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: cleaned,
      category: category.trim().isEmpty ? 'Other' : category.trim(),
      level: level,
      progress: level * 20,
    ));
    await _save();
    notifyListeners();
    return true;
  }

  Future<void> editSkill(String id, String name, String category) async {
    final skill = skills.firstWhere((s) => s.id == id);
    if (name.trim().isNotEmpty) skill.name = name.trim();
    if (category.trim().isNotEmpty) skill.category = category.trim();
    await _save();
    notifyListeners();
  }

  Future<void> removeSkill(String id) async {
    skills.removeWhere((s) => s.id == id);
    await _save();
    notifyListeners();
  }

  Future<void> updateSkillProgress(String id, int progress) async {
    final skill = skills.firstWhere((s) => s.id == id);
    skill.progress = progress.clamp(0, 100);
    skill.level = ((skill.progress / 20).ceil()).clamp(1, 5);
    await _save();
    notifyListeners();
  }

  // ------------------------------------------------------- skill matching

  static const Map<String, String> _aliases = {
    'dsa': 'data structures',
    'data structure': 'data structures',
    'js': 'javascript',
    'reactjs': 'react',
    'react.js': 'react',
    'node': 'node.js',
    'nodejs': 'node.js',
    'mysql': 'sql',
    'postgresql': 'sql',
    'postgres': 'sql',
    'sqlite': 'sql',
    'ml': 'machine learning',
    'rest': 'rest api',
    'restful api': 'rest api',
    'oops': 'oop',
  };

  String _norm(String value) {
    final t = value.trim().toLowerCase();
    return _aliases[t] ?? t;
  }

  Map<String, int> _skillProgress() {
    final map = <String, int>{};
    for (final s in skills) {
      final key = _norm(s.name);
      final current = map[key];
      if (current == null || s.progress > current) map[key] = s.progress;
    }
    // Knowing Flutter implies working knowledge of Dart.
    if (map.containsKey('flutter') && !map.containsKey('dart')) {
      map['dart'] = map['flutter']!;
    }
    return map;
  }

  MatchResult matchFor(Opportunity opportunity) {
    final progress = _skillProgress();
    final matched = <String>[];
    final learning = <String>[];
    final missing = <String>[];
    for (final skill in opportunity.skills) {
      final p = progress[_norm(skill)];
      if (p == null) {
        missing.add(skill);
      } else if (p >= matchThreshold) {
        matched.add(skill);
      } else {
        learning.add(skill);
      }
    }
    final total = opportunity.skills.length;
    final percent = total == 0 ? 0 : ((matched.length / total) * 100).round();
    return MatchResult(
      matched: matched,
      learning: learning,
      missing: missing,
      percent: percent,
    );
  }

  /// Skills most requested across listings that the student does not have yet.
  List<SkillDemand> suggestedSkills({int limit = 8}) {
    final progress = _skillProgress();
    final counts = <String, int>{};
    final display = <String, String>{};
    for (final o in opportunities) {
      for (final s in o.skills) {
        final key = _norm(s);
        if (progress.containsKey(key)) continue;
        counts[key] = (counts[key] ?? 0) + 1;
        display.putIfAbsent(key, () => s);
      }
    }
    final entries = counts.entries.toList()
      ..sort((a, b) {
        final c = b.value.compareTo(a.value);
        return c != 0 ? c : a.key.compareTo(b.key);
      });
    return entries
        .take(limit)
        .map((e) => SkillDemand(display[e.key] ?? e.key, e.value))
        .toList();
  }

  // ---------------------------------------------------------- opportunities

  Opportunity? findOpportunity(String id) {
    for (final o in opportunities) {
      if (o.id == id) return o;
    }
    return null;
  }

  List<Opportunity> get savedOpportunities =>
      opportunities.where((o) => o.saved).toList();

  /// Best-matching opportunities the student has not applied to yet.
  List<Opportunity> recommended({int limit = 3}) {
    final list = opportunities.where((o) => !hasApplied(o.id)).toList();
    list.sort((a, b) {
      final c = matchFor(b).percent.compareTo(matchFor(a).percent);
      return c != 0 ? c : a.title.compareTo(b.title);
    });
    return list.take(limit).toList();
  }

  List<Opportunity> similarTo(Opportunity opportunity, {int limit = 3}) {
    final mine = opportunity.skills.map(_norm).toSet();
    final scored = <MapEntry<Opportunity, int>>[];
    for (final other in opportunities) {
      if (other.id == opportunity.id) continue;
      final shared = other.skills.where((s) => mine.contains(_norm(s))).length;
      if (shared == 0) continue;
      scored.add(MapEntry(other, shared * 2 + (other.type == opportunity.type ? 1 : 0)));
    }
    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored.take(limit).map((e) => e.key).toList();
  }

  Future<void> toggleSaved(String id) async {
    final opportunity = opportunities.firstWhere((o) => o.id == id);
    opportunity.saved = !opportunity.saved;
    await _save();
    notifyListeners();
  }

  // ----------------------------------------------------------- applications

  bool hasApplied(String opportunityId) =>
      applications.any((a) => a.opportunityId == opportunityId);

  Future<void> apply(Opportunity opportunity) async {
    if (hasApplied(opportunity.id)) return;
    applications.insert(
      0,
      Application(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        opportunityId: opportunity.id,
        title: opportunity.title,
        company: opportunity.company,
        status: 'Applied',
        appliedOn: DateTime.now().toString().split(' ').first,
      ),
    );
    await _save();
    notifyListeners();
  }

  Future<void> updateApplicationStatus(String id, String status) async {
    final application = applications.firstWhere((a) => a.id == id);
    application.status = status;
    await _save();
    notifyListeners();
  }

  Future<void> removeApplication(String id) async {
    applications.removeWhere((a) => a.id == id);
    await _save();
    notifyListeners();
  }

  // ---------------------------------------------------------------- profile

  Future<void> updateProfile({
    required String name,
    required String collegeName,
    required String branchName,
    required String year,
    required String mail,
    required String role,
    required String aboutText,
  }) async {
    studentName = name.trim().isEmpty ? studentName : name.trim();
    college = collegeName.trim().isEmpty ? college : collegeName.trim();
    branch = branchName.trim().isEmpty ? branch : branchName.trim();
    gradYear = year.trim().isEmpty ? gradYear : year.trim();
    email = mail.trim().isEmpty ? email : mail.trim();
    targetRole = role.trim().isEmpty ? targetRole : role.trim();
    about = aboutText.trim();
    await _save();
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    darkMode = value;
    await _save();
    notifyListeners();
  }

  Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    studentName = _defaultName;
    college = _defaultCollege;
    email = _defaultEmail;
    branch = _defaultBranch;
    gradYear = _defaultYear;
    targetRole = _defaultRole;
    about = _defaultAbout;
    darkMode = false;
    skills = _defaultSkills();
    opportunities = _defaultOpportunities();
    applications = [];
    tabIndex.value = 0;
    notifyListeners();
  }

  List<Skill> _defaultSkills() => [
        Skill(id: '1', name: 'Python', category: 'Programming', level: 4, progress: 78),
        Skill(id: '2', name: 'Java', category: 'Programming', level: 3, progress: 62),
        Skill(id: '3', name: 'Data Structures', category: 'Core CS', level: 3, progress: 58),
        Skill(id: '4', name: 'MySQL', category: 'Database', level: 3, progress: 55),
        Skill(id: '5', name: 'Flutter', category: 'Mobile Development', level: 2, progress: 40),
      ];

  List<Opportunity> _defaultOpportunities() => [
        Opportunity(
          id: 'o1',
          title: 'Software Engineering Intern',
          company: 'TechNova',
          type: 'Internship',
          location: 'Hyderabad, India',
          mode: 'Hybrid',
          deadline: '20 Oct 2026',
          description: 'Build and test software features with an engineering team. Great for students interested in application development and problem solving.',
          skills: ['Java', 'DSA', 'Git'],
        ),
        Opportunity(
          id: 'o2',
          title: 'Flutter Developer Intern',
          company: 'AppForge',
          type: 'Internship',
          location: 'Remote, India',
          mode: 'Remote',
          deadline: '25 Oct 2026',
          description: 'Work on cross-platform mobile applications using Flutter and Dart. Learn UI development, state management and API integration.',
          skills: ['Flutter', 'Dart', 'UI/UX'],
        ),
        Opportunity(
          id: 'o3',
          title: 'AI & Data Hackathon',
          company: 'InnovateHub',
          type: 'Hackathon',
          location: 'Online',
          mode: 'Remote',
          deadline: '31 Oct 2026',
          description: 'Solve a real-world problem using AI, data or software engineering. Build a prototype and present your solution.',
          skills: ['Python', 'AI', 'Data Science'],
        ),
        Opportunity(
          id: 'o4',
          title: 'Junior Software Developer',
          company: 'CodeCraft',
          type: 'Job',
          location: 'Bengaluru, India',
          mode: 'On-site',
          deadline: '05 Nov 2026',
          description: 'Entry-level software development role focused on coding, testing and maintaining web and backend applications.',
          skills: ['Java', 'SQL', 'Git'],
        ),
        Opportunity(
          id: 'o5', title: 'Full Stack Developer Intern', company: 'WebNest', type: 'Internship',
          location: 'Remote, India', mode: 'Remote', deadline: '12 Nov 2026',
          description: 'Build responsive user interfaces and connect them to backend APIs. Practice end-to-end web development.',
          skills: ['HTML', 'CSS', 'JavaScript', 'React', 'Node.js'],
        ),
        Opportunity(
          id: 'o6', title: 'Frontend Developer Intern', company: 'PixelSpring', type: 'Internship',
          location: 'Hyderabad, India', mode: 'Hybrid', deadline: '15 Nov 2026',
          description: 'Create accessible, responsive web pages and reusable UI components with a product team.',
          skills: ['HTML', 'CSS', 'JavaScript', 'React'],
        ),
        Opportunity(
          id: 'o7', title: 'Backend Developer Intern', company: 'CloudBridge', type: 'Internship',
          location: 'Remote, India', mode: 'Remote', deadline: '18 Nov 2026',
          description: 'Develop API endpoints, work with databases, and learn testing and backend best practices.',
          skills: ['Python', 'Java', 'SQL', 'REST API'],
        ),
        Opportunity(
          id: 'o8', title: 'Python Developer Intern', company: 'DataSprout', type: 'Internship',
          location: 'Remote, India', mode: 'Remote', deadline: '20 Nov 2026',
          description: 'Write Python utilities, automate small workflows, and help build data-driven application features.',
          skills: ['Python', 'Git', 'SQL'],
        ),
        Opportunity(
          id: 'o9', title: 'Java Developer Trainee', company: 'CoreStack', type: 'Job',
          location: 'Pune, India', mode: 'On-site', deadline: '22 Nov 2026',
          description: 'Entry-level training role covering Java, object-oriented programming, debugging and application testing.',
          skills: ['Java', 'OOP', 'DSA', 'SQL'],
        ),
        Opportunity(
          id: 'o10', title: 'Data Analyst Intern', company: 'InsightLoop', type: 'Internship',
          location: 'Hyderabad, India', mode: 'Hybrid', deadline: '24 Nov 2026',
          description: 'Clean datasets, create dashboards, and summarize findings to support business decisions.',
          skills: ['Python', 'SQL', 'Excel', 'Tableau'],
        ),
        Opportunity(
          id: 'o11', title: 'AI/ML Engineer Intern', company: 'NeuralWorks', type: 'Internship',
          location: 'Remote, India', mode: 'Remote', deadline: '27 Nov 2026',
          description: 'Explore machine learning workflows, prepare datasets and evaluate beginner-friendly model prototypes.',
          skills: ['Python', 'Machine Learning', 'Pandas'],
        ),
        Opportunity(
          id: 'o12', title: 'UI/UX Design Intern', company: 'BrightCanvas', type: 'Internship',
          location: 'Remote, India', mode: 'Remote', deadline: '30 Nov 2026',
          description: 'Create wireframes and prototypes, review user flows, and collaborate with developers on polished interfaces.',
          skills: ['Figma', 'UI/UX', 'Prototyping'],
        ),
        Opportunity(
          id: 'o13', title: 'QA / Software Test Intern', company: 'QualityGrid', type: 'Internship',
          location: 'Chennai, India', mode: 'Hybrid', deadline: '02 Dec 2026',
          description: 'Write test cases, report bugs clearly, and learn manual and automated software testing basics.',
          skills: ['Testing', 'Java', 'Python', 'Attention to detail'],
        ),
        Opportunity(
          id: 'o14', title: 'Cloud Support Associate', company: 'SkyLayer', type: 'Job',
          location: 'Bengaluru, India', mode: 'Hybrid', deadline: '05 Dec 2026',
          description: 'Help troubleshoot cloud application issues and learn deployment, monitoring and support workflows.',
          skills: ['Linux', 'Networking', 'Cloud', 'Python'],
        ),
        Opportunity(
          id: 'o15', title: 'Cybersecurity Intern', company: 'SecureTrail', type: 'Internship',
          location: 'Remote, India', mode: 'Remote', deadline: '08 Dec 2026',
          description: 'Learn security fundamentals, document findings, and assist with safe vulnerability assessment exercises.',
          skills: ['Networking', 'Linux', 'Security'],
        ),
        Opportunity(
          id: 'o16', title: 'Business Analyst Intern', company: 'Planwise', type: 'Internship',
          location: 'Hyderabad, India', mode: 'Hybrid', deadline: '10 Dec 2026',
          description: 'Translate business questions into requirements, document workflows and build simple reports.',
          skills: ['Excel', 'SQL', 'Communication', 'Analytics'],
        ),
        Opportunity(
          id: 'o17', title: 'Graduate Software Engineer', company: 'LaunchPad Systems', type: 'Job',
          location: 'Remote, India', mode: 'Remote', deadline: '15 Dec 2026',
          description: 'Junior engineering opportunity for candidates interested in coding, collaboration and continuous learning.',
          skills: ['Java', 'Python', 'DSA', 'Git'],
        ),
      ];
}
