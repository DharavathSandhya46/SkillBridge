class Application {
  final String id;
  final String opportunityId;
  final String title;
  final String company;
  String status;
  final String appliedOn;

  Application({
    required this.id,
    required this.opportunityId,
    required this.title,
    required this.company,
    required this.status,
    required this.appliedOn,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'opportunityId': opportunityId,
        'title': title,
        'company': company,
        'status': status,
        'appliedOn': appliedOn,
      };

  factory Application.fromJson(Map<String, dynamic> json) => Application(
        id: json['id'],
        opportunityId: json['opportunityId'],
        title: json['title'],
        company: json['company'],
        status: json['status'],
        appliedOn: json['appliedOn'],
      );
}
