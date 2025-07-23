class TermuxEnvironment {
  final String home;
  final String prefix;
  final String shell;
  final String path;
  final bool isInitialized;
  final int installedPackages;
  final String? termuxVersion;
  final Map<String, String>? environmentVariables;
  final List<String>? availableShells;

  const TermuxEnvironment({
    required this.home,
    required this.prefix,
    required this.shell,
    required this.path,
    required this.isInitialized,
    required this.installedPackages,
    this.termuxVersion,
    this.environmentVariables,
    this.availableShells,
  });

  factory TermuxEnvironment.fromJson(Map<String, dynamic> json) {
    return TermuxEnvironment(
      home: json['home'] ?? '',
      prefix: json['prefix'] ?? '',
      shell: json['shell'] ?? '',
      path: json['path'] ?? '',
      isInitialized: json['isInitialized'] ?? false,
      installedPackages: json['installedPackages'] ?? 0,
      termuxVersion: json['termuxVersion'],
      environmentVariables: json['environmentVariables'] != null
          ? Map<String, String>.from(json['environmentVariables'])
          : null,
      availableShells: json['availableShells'] != null
          ? List<String>.from(json['availableShells'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'home': home,
      'prefix': prefix,
      'shell': shell,
      'path': path,
      'isInitialized': isInitialized,
      'installedPackages': installedPackages,
      'termuxVersion': termuxVersion,
      'environmentVariables': environmentVariables,
      'availableShells': availableShells,
    };
  }

  TermuxEnvironment copyWith({
    String? home,
    String? prefix,
    String? shell,
    String? path,
    bool? isInitialized,
    int? installedPackages,
    String? termuxVersion,
    Map<String, String>? environmentVariables,
    List<String>? availableShells,
  }) {
    return TermuxEnvironment(
      home: home ?? this.home,
      prefix: prefix ?? this.prefix,
      shell: shell ?? this.shell,
      path: path ?? this.path,
      isInitialized: isInitialized ?? this.isInitialized,
      installedPackages: installedPackages ?? this.installedPackages,
      termuxVersion: termuxVersion ?? this.termuxVersion,
      environmentVariables: environmentVariables ?? this.environmentVariables,
      availableShells: availableShells ?? this.availableShells,
    );
  }

  @override
  String toString() {
    return 'TermuxEnvironment(home: $home, prefix: $prefix, shell: $shell, isInitialized: $isInitialized, installedPackages: $installedPackages)';
  }
}