class Document {
  final int? id;
  final int bucketId;
  final String name;
  final String note;
  final List<String> filePaths; // local file paths to images/PDFs
  final int fileSizeBytes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Document({
    this.id,
    required this.bucketId,
    required this.name,
    this.note = '',
    required this.filePaths,
    required this.fileSizeBytes,
    required this.createdAt,
    required this.updatedAt,
  });

  int get pageCount => filePaths.length;

  String get formattedSize {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Document copyWith({
    int? id,
    int? bucketId,
    String? name,
    String? note,
    List<String>? filePaths,
    int? fileSizeBytes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Document(
      id: id ?? this.id,
      bucketId: bucketId ?? this.bucketId,
      name: name ?? this.name,
      note: note ?? this.note,
      filePaths: filePaths ?? this.filePaths,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'bucket_id': bucketId,
      'name': name,
      'note': note,
      'file_paths': filePaths.join('|'), // stored as pipe-separated string
      'file_size_bytes': fileSizeBytes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Document.fromMap(Map<String, dynamic> map) {
    final rawPaths = map['file_paths'] as String? ?? '';
    return Document(
      id: map['id'] as int?,
      bucketId: map['bucket_id'] as int,
      name: map['name'] as String,
      note: map['note'] as String? ?? '',
      filePaths: rawPaths.isEmpty ? [] : rawPaths.split('|'),
      fileSizeBytes: map['file_size_bytes'] as int? ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  @override
  String toString() => 'Document(id: $id, name: $name, bucketId: $bucketId)';
}
