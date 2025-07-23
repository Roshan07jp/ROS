enum AIMessageType {
  user,
  assistant,
  system,
  error,
}

class AIMessage {
  final String id;
  final String content;
  final AIMessageType type;
  final DateTime timestamp;
  final String role;
  final Map<String, dynamic>? metadata;

  const AIMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    required this.role,
    this.metadata,
  });

  factory AIMessage.fromJson(Map<String, dynamic> json) {
    return AIMessage(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      type: AIMessageType.values.firstWhere(
        (e) => e.toString() == 'AIMessageType.${json['type']}',
        orElse: () => AIMessageType.user,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      role: json['role'] ?? 'user',
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'role': role,
      'metadata': metadata,
    };
  }

  AIMessage copyWith({
    String? id,
    String? content,
    AIMessageType? type,
    DateTime? timestamp,
    String? role,
    Map<String, dynamic>? metadata,
  }) {
    return AIMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      role: role ?? this.role,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AIMessage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AIMessage(id: $id, type: $type, role: $role, content: ${content.substring(0, content.length > 50 ? 50 : content.length)}...)';
  }
}