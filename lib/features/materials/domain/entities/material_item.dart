class MaterialItem {
  final String id;
  final String title;
  final String subjectId;
  final String subjectName;
  final String fileUrl;
  final String type;
  final String description;
  final String fileSize;
  final DateTime uploadedAt;
  final bool isFavorite;

  MaterialItem({
    required this.id,
    required this.title,
    required this.subjectId,
    required this.subjectName,
    required this.fileUrl,
    required this.type,
    required this.description,
    required this.fileSize,
    required this.uploadedAt,
    this.isFavorite = false,
  });

  MaterialItem copyWith({
    String? id,
    String? title,
    String? subjectId,
    String? subjectName,
    String? fileUrl,
    String? type,
    String? description,
    String? fileSize,
    DateTime? uploadedAt,
    bool? isFavorite,
  }) {
    return MaterialItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      fileUrl: fileUrl ?? this.fileUrl,
      type: type ?? this.type,
      description: description ?? this.description,
      fileSize: fileSize ?? this.fileSize,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'fileUrl': fileUrl,
      'type': type,
      'description': description,
      'fileSize': fileSize,
      'uploadedAt': uploadedAt.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  factory MaterialItem.fromJson(Map<String, dynamic> json) {
    return MaterialItem(
      id: json['id'] as String,
      title: json['title'] as String,
      subjectId: json['subjectId'] as String,
      subjectName: json['subjectName'] as String,
      fileUrl: json['fileUrl'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      fileSize: json['fileSize'] as String,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }
}
