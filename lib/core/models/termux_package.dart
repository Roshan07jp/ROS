class TermuxPackage {
  final String name;
  final String version;
  final String description;
  final String category;
  final bool isInstalled;
  final String size;
  final List<String>? dependencies;
  final String? homepage;
  final String? maintainer;
  final DateTime? lastUpdated;
  final double? rating;
  final int? downloads;

  const TermuxPackage({
    required this.name,
    required this.version,
    required this.description,
    required this.category,
    required this.isInstalled,
    required this.size,
    this.dependencies,
    this.homepage,
    this.maintainer,
    this.lastUpdated,
    this.rating,
    this.downloads,
  });

  factory TermuxPackage.fromJson(Map<String, dynamic> json) {
    return TermuxPackage(
      name: json['name'] ?? '',
      version: json['version'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      isInstalled: json['isInstalled'] ?? false,
      size: json['size'] ?? '',
      dependencies: json['dependencies'] != null 
          ? List<String>.from(json['dependencies'])
          : null,
      homepage: json['homepage'],
      maintainer: json['maintainer'],
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : null,
      rating: json['rating']?.toDouble(),
      downloads: json['downloads'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'version': version,
      'description': description,
      'category': category,
      'isInstalled': isInstalled,
      'size': size,
      'dependencies': dependencies,
      'homepage': homepage,
      'maintainer': maintainer,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'rating': rating,
      'downloads': downloads,
    };
  }

  TermuxPackage copyWith({
    String? name,
    String? version,
    String? description,
    String? category,
    bool? isInstalled,
    String? size,
    List<String>? dependencies,
    String? homepage,
    String? maintainer,
    DateTime? lastUpdated,
    double? rating,
    int? downloads,
  }) {
    return TermuxPackage(
      name: name ?? this.name,
      version: version ?? this.version,
      description: description ?? this.description,
      category: category ?? this.category,
      isInstalled: isInstalled ?? this.isInstalled,
      size: size ?? this.size,
      dependencies: dependencies ?? this.dependencies,
      homepage: homepage ?? this.homepage,
      maintainer: maintainer ?? this.maintainer,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      rating: rating ?? this.rating,
      downloads: downloads ?? this.downloads,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TermuxPackage && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() {
    return 'TermuxPackage(name: $name, version: $version, category: $category, isInstalled: $isInstalled)';
  }
}