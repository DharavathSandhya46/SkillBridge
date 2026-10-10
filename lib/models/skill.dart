class Skill {
  final String id;
  String name;
  String category;
  int level;
  int progress;

  Skill({
    required this.id,
    required this.name,
    required this.category,
    required this.level,
    required this.progress,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'level': level,
        'progress': progress,
      };

  factory Skill.fromJson(Map<String, dynamic> json) => Skill(
        id: json['id'],
        name: json['name'],
        category: json['category'],
        level: json['level'],
        progress: json['progress'],
      );
}
