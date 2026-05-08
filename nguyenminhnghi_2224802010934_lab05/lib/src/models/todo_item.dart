class TodoItem {
  const TodoItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
  });

  final String id;
  final String userId;
  final String title;
  final String description;

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json["_id"]?.toString() ?? "",
      userId: json["userId"]?.toString() ?? "",
      title: json["title"]?.toString() ?? "",
      description: json["description"]?.toString() ?? "",
    );
  }

  TodoItem copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
  }) {
    return TodoItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }
}
