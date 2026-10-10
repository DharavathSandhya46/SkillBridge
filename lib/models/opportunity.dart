class Opportunity {
  final String id;
  final String title;
  final String company;
  final String type;
  final String location;
  final String mode;
  final String deadline;
  final String description;
  final List<String> skills;
  bool saved;

  Opportunity({
    required this.id,
    required this.title,
    required this.company,
    required this.type,
    required this.location,
    required this.mode,
    required this.deadline,
    required this.description,
    required this.skills,
    this.saved = false,
  });

  /// Parses deadlines written like "20 Oct 2026". Returns null if unparseable.
  DateTime? get deadlineDate {
    final parts = deadline.trim().split(RegExp(r'\s+'));
    if (parts.length != 3) return null;
    const months = {
      'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
      'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
    };
    final day = int.tryParse(parts[0]);
    final monthText = parts[1].toLowerCase();
    final month = months[monthText.length < 3 ? monthText : monthText.substring(0, 3)];
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime.utc(year, month, day);
  }

  /// Days remaining until the deadline (negative if passed), or null.
  int? get daysLeft {
    final date = deadlineDate;
    if (date == null) return null;
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);
    return date.difference(today).inDays;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'company': company,
        'type': type,
        'location': location,
        'mode': mode,
        'deadline': deadline,
        'description': description,
        'skills': skills,
        'saved': saved,
      };

  factory Opportunity.fromJson(Map<String, dynamic> json) => Opportunity(
        id: json['id'],
        title: json['title'],
        company: json['company'],
        type: json['type'],
        location: json['location'],
        mode: json['mode'],
        deadline: json['deadline'],
        description: json['description'],
        skills: List<String>.from(json['skills']),
        saved: json['saved'] ?? false,
      );
}
