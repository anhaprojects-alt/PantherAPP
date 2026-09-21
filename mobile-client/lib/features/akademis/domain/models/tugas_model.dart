class TugasModel {
  final int id;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isCompleted;

  TugasModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
  });

  factory TugasModel.fromJson(Map<String, dynamic> json) {
    return TugasModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['due_date']),
      isCompleted: json['status'] == 'completed',
    );
  }
}
