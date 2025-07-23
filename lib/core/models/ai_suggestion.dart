enum AISuggestionType {
  command,
  script,
  explanation,
  package,
  file,
  help,
}

class AISuggestion {
  final String text;
  final String description;
  final AISuggestionType type;
  final String? category;
  final Map<String, dynamic>? metadata;
  final double? confidence;

  const AISuggestion({
    required this.text,
    required this.description,
    required this.type,
    this.category,
    this.metadata,
    this.confidence,
  });

  factory AISuggestion.fromJson(Map<String, dynamic> json) {
    return AISuggestion(
      text: json['text'] ?? '',
      description: json['description'] ?? '',
      type: AISuggestionType.values.firstWhere(
        (e) => e.toString() == 'AISuggestionType.${json['type']}',
        orElse: () => AISuggestionType.command,
      ),
      category: json['category'],
      metadata: json['metadata'],
      confidence: json['confidence']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'description': description,
      'type': type.toString().split('.').last,
      'category': category,
      'metadata': metadata,
      'confidence': confidence,
    };
  }

  AISuggestion copyWith({
    String? text,
    String? description,
    AISuggestionType? type,
    String? category,
    Map<String, dynamic>? metadata,
    double? confidence,
  }) {
    return AISuggestion(
      text: text ?? this.text,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      metadata: metadata ?? this.metadata,
      confidence: confidence ?? this.confidence,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AISuggestion && other.text == text && other.type == type;
  }

  @override
  int get hashCode => text.hashCode ^ type.hashCode;

  @override
  String toString() {
    return 'AISuggestion(text: $text, type: $type, description: $description)';
  }
}