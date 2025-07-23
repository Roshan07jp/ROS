import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import 'package:crypto/crypto.dart';
import '../platform/platform_service.dart';
import '../error_handling/error_handler.dart';
import '../permissions/permission_manager.dart';

enum FileType {
  file,
  directory,
  symlink,
  unknown,
}

enum FileOperation {
  copy,
  move,
  delete,
  compress,
  extract,
  sync,
}

class ROSFileInfo {
  final String name;
  final String path;
  final String absolutePath;
  final FileType type;
  final int size;
  final DateTime modified;
  final DateTime? created;
  final DateTime? accessed;
  final String permissions;
  final String? owner;
  final String? group;
  final bool isHidden;
  final bool isReadOnly;
  final String? mimeType;
  final String? extension;
  final Map<String, dynamic> metadata;

  const ROSFileInfo({
    required this.name,
    required this.path,
    required this.absolutePath,
    required this.type,
    required this.size,
    required this.modified,
    this.created,
    this.accessed,
    required this.permissions,
    this.owner,
    this.group,
    required this.isHidden,
    required this.isReadOnly,
    this.mimeType,
    this.extension,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'absolutePath': absolutePath,
      'type': type.name,
      'size': size,
      'modified': modified.toIso8601String(),
      'created': created?.toIso8601String(),
      'accessed': accessed?.toIso8601String(),
      'permissions': permissions,
      'owner': owner,
      'group': group,
      'isHidden': isHidden,
      'isReadOnly': isReadOnly,
      'mimeType': mimeType,
      'extension': extension,
      'metadata': metadata,
    };
  }

  factory ROSFileInfo.fromJson(Map<String, dynamic> json) {
    return ROSFileInfo(
      name: json['name'],
      path: json['path'],
      absolutePath: json['absolutePath'],
      type: FileType.values.firstWhere((t) => t.name == json['type']),
      size: json['size'],
      modified: DateTime.parse(json['modified']),
      created: json['created'] != null ? DateTime.parse(json['created']) : null,
      accessed: json['accessed'] != null ? DateTime.parse(json['accessed']) : null,
      permissions: json['permissions'],
      owner: json['owner'],
      group: json['group'],
      isHidden: json['isHidden'],
      isReadOnly: json['isReadOnly'],
      mimeType: json['mimeType'],
      extension: json['extension'],
      metadata: json['metadata'] ?? {},
    );
  }
}

class GitInfo {
  final bool isGitRepo;
  final String? branch;
  final String? status;
  final int? ahead;
  final int? behind;
  final List<String> modifiedFiles;
  final List<String> stagedFiles;
  final List<String> untrackedFiles;
  final String? lastCommit;
  final String? remoteUrl;

  const GitInfo({
    required this.isGitRepo,
    this.branch,
    this.status,
    this.ahead,
    this.behind,
    this.modifiedFiles = const [],
    this.stagedFiles = const [],
    this.untrackedFiles = const [],
    this.lastCommit,
    this.remoteUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'isGitRepo': isGitRepo,
      'branch': branch,
      'status': status,
      'ahead': ahead,
      'behind': behind,
      'modifiedFiles': modifiedFiles,
      'stagedFiles': stagedFiles,
      'untrackedFiles': untrackedFiles,
      'lastCommit': lastCommit,
      'remoteUrl': remoteUrl,
    };
  }
}

class FileOperationProgress {
  final FileOperation operation;
  final String source;
  final String? destination;
  final double progress;
  final String currentFile;
  final int filesProcessed;
  final int totalFiles;
  final int bytesProcessed;
  final int totalBytes;

  const FileOperationProgress({
    required this.operation,
    required this.source,
    this.destination,
    required this.progress,
    required this.currentFile,
    required this.filesProcessed,
    required this.totalFiles,
    required this.bytesProcessed,
    required this.totalBytes,
  });
}

class ROSFileManager {
  static const String _bookmarksFile = 'ros_file_bookmarks.json';
  static const String _historyFile = 'ros_file_history.json';
  
  String _currentDirectory = '';
  final List<String> _navigationHistory = [];
  final List<String> _bookmarks = [];
  final List<Function(FileOperationProgress)> _progressListeners = [];
  final Map<String, GitInfo> _gitCache = {};

  // Initialize file manager
  Future<void> initialize() async {
    await _loadBookmarks();
    await _loadHistory();
    _currentDirectory = await _getHomeDirectory();
  }

  Future<String> _getHomeDirectory() async {
    try {
      if (kIsWeb) {
        return '/';
      } else if (Platform.isWindows) {
        return Platform.environment['USERPROFILE'] ?? 'C:\\';
      } else {
        return Platform.environment['HOME'] ?? '/';
      }
    } catch (e) {
      return '/';
    }
  }

  // Directory navigation
  Future<List<ROSFileInfo>> listDirectory(String? directoryPath) async {
    try {
      final targetPath = directoryPath ?? _currentDirectory;
      final directory = Directory(targetPath);
      
      if (!await directory.exists()) {
        throw Exception('Directory does not exist: $targetPath');
      }

      final List<ROSFileInfo> files = [];
      final entities = await directory.list().toList();

      for (final entity in entities) {
        try {
          final fileInfo = await _getFileInfo(entity);
          files.add(fileInfo);
        } catch (e) {
          // Skip files that can't be accessed
          continue;
        }
      }

      // Sort files: directories first, then by name
      files.sort((a, b) {
        if (a.type == FileType.directory && b.type != FileType.directory) {
          return -1;
        } else if (a.type != FileType.directory && b.type == FileType.directory) {
          return 1;
        } else {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        }
      });

      if (directoryPath != null) {
        _currentDirectory = targetPath;
        _addToHistory(targetPath);
      }

      return files;
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Listing directory: $directoryPath');
      rethrow;
    }
  }

  Future<ROSFileInfo> _getFileInfo(FileSystemEntity entity) async {
    final stat = await entity.stat();
    final entityPath = entity.path;
    final fileName = path.basename(entityPath);
    final isHidden = fileName.startsWith('.');
    
    FileType fileType;
    if (stat.type == FileSystemEntityType.directory) {
      fileType = FileType.directory;
    } else if (stat.type == FileSystemEntityType.link) {
      fileType = FileType.symlink;
    } else if (stat.type == FileSystemEntityType.file) {
      fileType = FileType.file;
    } else {
      fileType = FileType.unknown;
    }

    String permissions = '';
    if (!kIsWeb && !Platform.isWindows) {
      permissions = _formatUnixPermissions(stat.mode);
    }

    return ROSFileInfo(
      name: fileName,
      path: entityPath,
      absolutePath: path.absolute(entityPath),
      type: fileType,
      size: stat.size,
      modified: stat.modified,
      created: stat.changed,
      accessed: stat.accessed,
      permissions: permissions,
      isHidden: isHidden,
      isReadOnly: !await _isWritable(entity),
      mimeType: fileType == FileType.file ? lookupMimeType(entityPath) : null,
      extension: fileType == FileType.file ? path.extension(entityPath) : null,
    );
  }

  String _formatUnixPermissions(int mode) {
    final permissions = StringBuffer();
    
    // File type
    if ((mode & 0x4000) != 0) permissions.write('d');
    else if ((mode & 0xA000) != 0) permissions.write('l');
    else permissions.write('-');
    
    // Owner permissions
    permissions.write((mode & 0x100) != 0 ? 'r' : '-');
    permissions.write((mode & 0x080) != 0 ? 'w' : '-');
    permissions.write((mode & 0x040) != 0 ? 'x' : '-');
    
    // Group permissions
    permissions.write((mode & 0x020) != 0 ? 'r' : '-');
    permissions.write((mode & 0x010) != 0 ? 'w' : '-');
    permissions.write((mode & 0x008) != 0 ? 'x' : '-');
    
    // Other permissions
    permissions.write((mode & 0x004) != 0 ? 'r' : '-');
    permissions.write((mode & 0x002) != 0 ? 'w' : '-');
    permissions.write((mode & 0x001) != 0 ? 'x' : '-');
    
    return permissions.toString();
  }

  Future<bool> _isWritable(FileSystemEntity entity) async {
    try {
      if (entity is Directory) {
        final testFile = File(path.join(entity.path, '.ros_test'));
        await testFile.writeAsString('test');
        await testFile.delete();
        return true;
      } else if (entity is File) {
        final handle = await entity.open(mode: FileMode.append);
        await handle.close();
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  // File operations
  Future<void> copyFile(String source, String destination, {bool overwrite = false}) async {
    try {
      final sourceFile = File(source);
      final destFile = File(destination);
      
      if (!await sourceFile.exists()) {
        throw Exception('Source file does not exist: $source');
      }
      
      if (await destFile.exists() && !overwrite) {
        throw Exception('Destination file already exists: $destination');
      }

      await sourceFile.copy(destination);
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Copying file: $source -> $destination');
      rethrow;
    }
  }

  Future<void> moveFile(String source, String destination, {bool overwrite = false}) async {
    try {
      await copyFile(source, destination, overwrite: overwrite);
      await deleteFile(source);
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Moving file: $source -> $destination');
      rethrow;
    }
  }

  Future<void> deleteFile(String filePath) async {
    try {
      final entity = FileSystemEntity.typeSync(filePath);
      
      if (entity == FileSystemEntityType.file) {
        await File(filePath).delete();
      } else if (entity == FileSystemEntityType.directory) {
        await Directory(filePath).delete(recursive: true);
      } else {
        throw Exception('File does not exist: $filePath');
      }
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Deleting file: $filePath');
      rethrow;
    }
  }

  Future<void> createDirectory(String directoryPath) async {
    try {
      await Directory(directoryPath).create(recursive: true);
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Creating directory: $directoryPath');
      rethrow;
    }
  }

  Future<void> createFile(String filePath, {String? content}) async {
    try {
      final file = File(filePath);
      await file.writeAsString(content ?? '');
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Creating file: $filePath');
      rethrow;
    }
  }

  Future<String> readFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist: $filePath');
      }
      return await file.readAsString();
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Reading file: $filePath');
      rethrow;
    }
  }

  Future<void> writeFile(String filePath, String content) async {
    try {
      final file = File(filePath);
      await file.writeAsString(content);
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Writing file: $filePath');
      rethrow;
    }
  }

  // Git integration
  Future<GitInfo> getGitInfo(String directoryPath) async {
    if (_gitCache.containsKey(directoryPath)) {
      return _gitCache[directoryPath]!;
    }

    try {
      final gitDir = Directory(path.join(directoryPath, '.git'));
      if (!await gitDir.exists()) {
        final gitInfo = const GitInfo(isGitRepo: false);
        _gitCache[directoryPath] = gitInfo;
        return gitInfo;
      }

      final branch = await _getGitBranch(directoryPath);
      final status = await _getGitStatus(directoryPath);
      final remoteInfo = await _getGitRemoteInfo(directoryPath);
      final lastCommit = await _getLastCommit(directoryPath);

      final gitInfo = GitInfo(
        isGitRepo: true,
        branch: branch,
        status: status['status'],
        ahead: remoteInfo['ahead'],
        behind: remoteInfo['behind'],
        modifiedFiles: List<String>.from(status['modified'] ?? []),
        stagedFiles: List<String>.from(status['staged'] ?? []),
        untrackedFiles: List<String>.from(status['untracked'] ?? []),
        lastCommit: lastCommit,
        remoteUrl: remoteInfo['url'],
      );

      _gitCache[directoryPath] = gitInfo;
      return gitInfo;
    } catch (e) {
      final gitInfo = const GitInfo(isGitRepo: false);
      _gitCache[directoryPath] = gitInfo;
      return gitInfo;
    }
  }

  Future<String?> _getGitBranch(String repoPath) async {
    try {
      final result = await Process.run('git', ['branch', '--show-current'], 
          workingDirectory: repoPath);
      if (result.exitCode == 0) {
        return result.stdout.toString().trim();
      }
    } catch (e) {
      // Git not available or not a repo
    }
    return null;
  }

  Future<Map<String, dynamic>> _getGitStatus(String repoPath) async {
    try {
      final result = await Process.run('git', ['status', '--porcelain'], 
          workingDirectory: repoPath);
      if (result.exitCode == 0) {
        final lines = result.stdout.toString().split('\n').where((l) => l.isNotEmpty);
        
        final modified = <String>[];
        final staged = <String>[];
        final untracked = <String>[];
        
        for (final line in lines) {
          if (line.length >= 3) {
            final statusCode = line.substring(0, 2);
            final fileName = line.substring(3);
            
            if (statusCode[0] != ' ') staged.add(fileName);
            if (statusCode[1] != ' ') modified.add(fileName);
            if (statusCode == '??') untracked.add(fileName);
          }
        }
        
        String status = 'clean';
        if (modified.isNotEmpty || staged.isNotEmpty || untracked.isNotEmpty) {
          status = 'dirty';
        }
        
        return {
          'status': status,
          'modified': modified,
          'staged': staged,
          'untracked': untracked,
        };
      }
    } catch (e) {
      // Git not available
    }
    return {'status': 'unknown'};
  }

  Future<Map<String, dynamic>> _getGitRemoteInfo(String repoPath) async {
    try {
      // Get remote URL
      final urlResult = await Process.run('git', ['remote', 'get-url', 'origin'], 
          workingDirectory: repoPath);
      
      // Get ahead/behind info
      final statusResult = await Process.run(
          'git', ['status', '--porcelain=v1', '--branch'], 
          workingDirectory: repoPath);
      
      String? remoteUrl;
      int? ahead, behind;
      
      if (urlResult.exitCode == 0) {
        remoteUrl = urlResult.stdout.toString().trim();
      }
      
      if (statusResult.exitCode == 0) {
        final statusLine = statusResult.stdout.toString().split('\n').first;
        final aheadMatch = RegExp(r'ahead (\d+)').firstMatch(statusLine);
        final behindMatch = RegExp(r'behind (\d+)').firstMatch(statusLine);
        
        if (aheadMatch != null) ahead = int.parse(aheadMatch.group(1)!);
        if (behindMatch != null) behind = int.parse(behindMatch.group(1)!);
      }
      
      return {
        'url': remoteUrl,
        'ahead': ahead,
        'behind': behind,
      };
    } catch (e) {
      return {};
    }
  }

  Future<String?> _getLastCommit(String repoPath) async {
    try {
      final result = await Process.run(
          'git', ['log', '-1', '--pretty=format:%h %s'], 
          workingDirectory: repoPath);
      if (result.exitCode == 0) {
        return result.stdout.toString().trim();
      }
    } catch (e) {
      // Git not available
    }
    return null;
  }

  // File search
  Future<List<ROSFileInfo>> searchFiles({
    required String query,
    String? directory,
    bool caseSensitive = false,
    bool includeHidden = false,
    List<String>? extensions,
    int? maxResults,
  }) async {
    try {
      final searchDir = directory ?? _currentDirectory;
      final results = <ROSFileInfo>[];
      
      await _searchInDirectory(
        Directory(searchDir),
        query,
        results,
        caseSensitive: caseSensitive,
        includeHidden: includeHidden,
        extensions: extensions,
        maxResults: maxResults,
      );
      
      return results;
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Searching files: $query');
      return [];
    }
  }

  Future<void> _searchInDirectory(
    Directory directory,
    String query,
    List<ROSFileInfo> results, {
    bool caseSensitive = false,
    bool includeHidden = false,
    List<String>? extensions,
    int? maxResults,
  }) async {
    try {
      final entities = await directory.list().toList();
      
      for (final entity in entities) {
        if (maxResults != null && results.length >= maxResults) break;
        
        final fileName = path.basename(entity.path);
        
        if (!includeHidden && fileName.startsWith('.')) continue;
        
        final matchesQuery = caseSensitive 
            ? fileName.contains(query)
            : fileName.toLowerCase().contains(query.toLowerCase());
            
        if (matchesQuery) {
          if (extensions == null || 
              (entity is File && extensions.contains(path.extension(entity.path)))) {
            try {
              final fileInfo = await _getFileInfo(entity);
              results.add(fileInfo);
            } catch (e) {
              // Skip files that can't be accessed
            }
          }
        }
        
        // Recursively search subdirectories
        if (entity is Directory) {
          await _searchInDirectory(
            entity,
            query,
            results,
            caseSensitive: caseSensitive,
            includeHidden: includeHidden,
            extensions: extensions,
            maxResults: maxResults,
          );
        }
      }
    } catch (e) {
      // Skip directories that can't be accessed
    }
  }

  // Bookmarks management
  Future<void> addBookmark(String path, {String? name}) async {
    final bookmarkName = name ?? path.split('/').last;
    final bookmark = '$bookmarkName|$path';
    
    if (!_bookmarks.contains(bookmark)) {
      _bookmarks.add(bookmark);
      await _saveBookmarks();
    }
  }

  Future<void> removeBookmark(String path) async {
    _bookmarks.removeWhere((bookmark) => bookmark.endsWith('|$path'));
    await _saveBookmarks();
  }

  List<Map<String, String>> getBookmarks() {
    return _bookmarks.map((bookmark) {
      final parts = bookmark.split('|');
      return {
        'name': parts[0],
        'path': parts[1],
      };
    }).toList();
  }

  // CLI interface
  Future<String> executeFileCommand(List<String> args) async {
    if (args.isEmpty) {
      return _getFileHelpText();
    }

    final command = args[0];
    final commandArgs = args.skip(1).toList();

    try {
      switch (command) {
        case 'ls':
        case 'list':
          return await _cliList(commandArgs);
        case 'cd':
          return await _cliChangeDirectory(commandArgs);
        case 'pwd':
          return _currentDirectory;
        case 'mkdir':
          return await _cliMakeDirectory(commandArgs);
        case 'touch':
          return await _cliCreateFile(commandArgs);
        case 'cp':
        case 'copy':
          return await _cliCopy(commandArgs);
        case 'mv':
        case 'move':
          return await _cliMove(commandArgs);
        case 'rm':
        case 'delete':
          return await _cliDelete(commandArgs);
        case 'cat':
        case 'read':
          return await _cliReadFile(commandArgs);
        case 'echo':
        case 'write':
          return await _cliWriteFile(commandArgs);
        case 'find':
        case 'search':
          return await _cliSearch(commandArgs);
        case 'git':
          return await _cliGit(commandArgs);
        case 'bookmark':
          return await _cliBookmark(commandArgs);
        case 'history':
          return _cliHistory();
        default:
          return 'Unknown command: $command\n\n${_getFileHelpText()}';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<String> _cliList(List<String> args) async {
    final directory = args.isNotEmpty ? args[0] : null;
    final files = await listDirectory(directory);
    
    final buffer = StringBuffer();
    for (final file in files) {
      final sizeStr = file.type == FileType.directory 
          ? '<DIR>' 
          : _formatFileSize(file.size);
      
      final typeIcon = _getFileTypeIcon(file);
      buffer.writeln('$typeIcon ${file.permissions} ${sizeStr.padLeft(10)} ${file.modified.toString().substring(0, 19)} ${file.name}');
    }
    
    return buffer.toString();
  }

  Future<String> _cliChangeDirectory(List<String> args) async {
    if (args.isEmpty) {
      _currentDirectory = await _getHomeDirectory();
      return 'Changed to home directory: $_currentDirectory';
    }
    
    final targetPath = args[0];
    String fullPath;
    
    if (path.isAbsolute(targetPath)) {
      fullPath = targetPath;
    } else {
      fullPath = path.join(_currentDirectory, targetPath);
    }
    
    fullPath = path.normalize(fullPath);
    
    final directory = Directory(fullPath);
    if (await directory.exists()) {
      _currentDirectory = fullPath;
      _addToHistory(fullPath);
      return 'Changed directory to: $fullPath';
    } else {
      return 'Directory does not exist: $fullPath';
    }
  }

  Future<String> _cliMakeDirectory(List<String> args) async {
    if (args.isEmpty) {
      return 'Usage: mkdir <directory>';
    }
    
    for (final dirName in args) {
      final fullPath = path.isAbsolute(dirName) 
          ? dirName 
          : path.join(_currentDirectory, dirName);
      await createDirectory(fullPath);
    }
    
    return 'Created ${args.length} director${args.length == 1 ? 'y' : 'ies'}';
  }

  Future<String> _cliCreateFile(List<String> args) async {
    if (args.isEmpty) {
      return 'Usage: touch <file>';
    }
    
    for (final fileName in args) {
      final fullPath = path.isAbsolute(fileName) 
          ? fileName 
          : path.join(_currentDirectory, fileName);
      await createFile(fullPath);
    }
    
    return 'Created ${args.length} file${args.length == 1 ? '' : 's'}';
  }

  Future<String> _cliCopy(List<String> args) async {
    if (args.length < 2) {
      return 'Usage: cp <source> <destination>';
    }
    
    final source = path.isAbsolute(args[0]) 
        ? args[0] 
        : path.join(_currentDirectory, args[0]);
    final destination = path.isAbsolute(args[1]) 
        ? args[1] 
        : path.join(_currentDirectory, args[1]);
    
    await copyFile(source, destination);
    return 'Copied: $source -> $destination';
  }

  Future<String> _cliMove(List<String> args) async {
    if (args.length < 2) {
      return 'Usage: mv <source> <destination>';
    }
    
    final source = path.isAbsolute(args[0]) 
        ? args[0] 
        : path.join(_currentDirectory, args[0]);
    final destination = path.isAbsolute(args[1]) 
        ? args[1] 
        : path.join(_currentDirectory, args[1]);
    
    await moveFile(source, destination);
    return 'Moved: $source -> $destination';
  }

  Future<String> _cliDelete(List<String> args) async {
    if (args.isEmpty) {
      return 'Usage: rm <file>';
    }
    
    for (final fileName in args) {
      final fullPath = path.isAbsolute(fileName) 
          ? fileName 
          : path.join(_currentDirectory, fileName);
      await deleteFile(fullPath);
    }
    
    return 'Deleted ${args.length} item${args.length == 1 ? '' : 's'}';
  }

  Future<String> _cliReadFile(List<String> args) async {
    if (args.isEmpty) {
      return 'Usage: cat <file>';
    }
    
    final fileName = args[0];
    final fullPath = path.isAbsolute(fileName) 
        ? fileName 
        : path.join(_currentDirectory, fileName);
    
    return await readFile(fullPath);
  }

  Future<String> _cliWriteFile(List<String> args) async {
    if (args.length < 2) {
      return 'Usage: echo <content> > <file>';
    }
    
    final content = args.take(args.length - 1).join(' ');
    final fileName = args.last;
    final fullPath = path.isAbsolute(fileName) 
        ? fileName 
        : path.join(_currentDirectory, fileName);
    
    await writeFile(fullPath, content);
    return 'Written to: $fullPath';
  }

  Future<String> _cliSearch(List<String> args) async {
    if (args.isEmpty) {
      return 'Usage: find <query> [directory]';
    }
    
    final query = args[0];
    final directory = args.length > 1 ? args[1] : null;
    
    final results = await searchFiles(
      query: query,
      directory: directory,
      maxResults: 50,
    );
    
    if (results.isEmpty) {
      return 'No files found matching: $query';
    }
    
    final buffer = StringBuffer();
    buffer.writeln('Found ${results.length} files:');
    for (final file in results) {
      buffer.writeln('${_getFileTypeIcon(file)} ${file.path}');
    }
    
    return buffer.toString();
  }

  Future<String> _cliGit(List<String> args) async {
    if (args.isEmpty) {
      final gitInfo = await getGitInfo(_currentDirectory);
      if (!gitInfo.isGitRepo) {
        return 'Not a git repository';
      }
      
      final buffer = StringBuffer();
      buffer.writeln('Git Repository Information:');
      buffer.writeln('Branch: ${gitInfo.branch ?? 'unknown'}');
      buffer.writeln('Status: ${gitInfo.status ?? 'unknown'}');
      if (gitInfo.ahead != null) buffer.writeln('Ahead: ${gitInfo.ahead}');
      if (gitInfo.behind != null) buffer.writeln('Behind: ${gitInfo.behind}');
      if (gitInfo.modifiedFiles.isNotEmpty) {
        buffer.writeln('Modified files: ${gitInfo.modifiedFiles.length}');
      }
      if (gitInfo.untrackedFiles.isNotEmpty) {
        buffer.writeln('Untracked files: ${gitInfo.untrackedFiles.length}');
      }
      if (gitInfo.lastCommit != null) {
        buffer.writeln('Last commit: ${gitInfo.lastCommit}');
      }
      
      return buffer.toString();
    } else {
      // Execute git command
      final result = await Process.run('git', args, workingDirectory: _currentDirectory);
      return '${result.stdout}${result.stderr}';
    }
  }

  Future<String> _cliBookmark(List<String> args) async {
    if (args.isEmpty) {
      final bookmarks = getBookmarks();
      if (bookmarks.isEmpty) {
        return 'No bookmarks saved';
      }
      
      final buffer = StringBuffer();
      buffer.writeln('Bookmarks:');
      for (final bookmark in bookmarks) {
        buffer.writeln('${bookmark['name']}: ${bookmark['path']}');
      }
      return buffer.toString();
    }
    
    final action = args[0];
    switch (action) {
      case 'add':
        final path = args.length > 1 ? args[1] : _currentDirectory;
        final name = args.length > 2 ? args[2] : null;
        await addBookmark(path, name: name);
        return 'Added bookmark: $path';
      case 'remove':
        if (args.length < 2) return 'Usage: bookmark remove <path>';
        await removeBookmark(args[1]);
        return 'Removed bookmark: ${args[1]}';
      default:
        return 'Usage: bookmark [add|remove] [path] [name]';
    }
  }

  String _cliHistory() {
    if (_navigationHistory.isEmpty) {
      return 'No navigation history';
    }
    
    final buffer = StringBuffer();
    buffer.writeln('Navigation History:');
    for (int i = 0; i < _navigationHistory.length; i++) {
      buffer.writeln('${i + 1}: ${_navigationHistory[i]}');
    }
    return buffer.toString();
  }

  String _getFileTypeIcon(ROSFileInfo file) {
    switch (file.type) {
      case FileType.directory:
        return '📁';
      case FileType.symlink:
        return '🔗';
      case FileType.file:
        if (file.extension != null) {
          switch (file.extension!.toLowerCase()) {
            case '.txt':
            case '.md':
              return '📄';
            case '.jpg':
            case '.jpeg':
            case '.png':
            case '.gif':
              return '🖼️';
            case '.mp3':
            case '.wav':
            case '.flac':
              return '🎵';
            case '.mp4':
            case '.avi':
            case '.mov':
              return '🎬';
            case '.zip':
            case '.tar':
            case '.gz':
              return '📦';
            case '.exe':
            case '.app':
              return '⚙️';
            case '.dart':
            case '.js':
            case '.py':
            case '.java':
              return '💻';
            default:
              return '📄';
          }
        }
        return '📄';
      default:
        return '❓';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / 1024 / 1024).toStringAsFixed(1)}MB';
    return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(1)}GB';
  }

  String _getFileHelpText() {
    return '''
ROS File Manager - Advanced file and directory management

Usage: ros file <command> [arguments]

Commands:
  ls [directory]        List files and directories
  cd [directory]        Change directory
  pwd                   Show current directory
  mkdir <dir>           Create directory
  touch <file>          Create empty file
  cp <src> <dest>       Copy file or directory
  mv <src> <dest>       Move file or directory
  rm <file>             Delete file or directory
  cat <file>            Read file content
  echo <text> > <file>  Write text to file
  find <query> [dir]    Search for files
  git [command]         Git operations and status
  bookmark [add|remove] Manage bookmarks
  history               Show navigation history

Examples:
  ros file ls
  ros file cd /home/user
  ros file mkdir newdir
  ros file cp file.txt backup.txt
  ros file find "*.dart"
  ros file git status
  ros file bookmark add /important/path
''';
  }

  // Utility methods
  void _addToHistory(String path) {
    if (_navigationHistory.isEmpty || _navigationHistory.last != path) {
      _navigationHistory.add(path);
      if (_navigationHistory.length > 100) {
        _navigationHistory.removeAt(0);
      }
      _saveHistory();
    }
  }

  void addProgressListener(Function(FileOperationProgress) listener) {
    _progressListeners.add(listener);
  }

  void removeProgressListener(Function(FileOperationProgress) listener) {
    _progressListeners.remove(listener);
  }

  // Persistence
  Future<void> _loadBookmarks() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/$_bookmarksFile');
      
      if (await file.exists()) {
        final data = jsonDecode(await file.readAsString()) as List;
        _bookmarks.clear();
        _bookmarks.addAll(data.cast<String>());
      }
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Loading bookmarks');
    }
  }

  Future<void> _saveBookmarks() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/$_bookmarksFile');
      await file.writeAsString(jsonEncode(_bookmarks));
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Saving bookmarks');
    }
  }

  Future<void> _loadHistory() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/$_historyFile');
      
      if (await file.exists()) {
        final data = jsonDecode(await file.readAsString()) as List;
        _navigationHistory.clear();
        _navigationHistory.addAll(data.cast<String>());
      }
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Loading history');
    }
  }

  Future<void> _saveHistory() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/$_historyFile');
      await file.writeAsString(jsonEncode(_navigationHistory));
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Saving history');
    }
  }

  // Getters
  String get currentDirectory => _currentDirectory;
  List<String> get navigationHistory => List.unmodifiable(_navigationHistory);
  List<String> get bookmarks => List.unmodifiable(_bookmarks);
}

// Riverpod providers
final rosFileManagerProvider = Provider<ROSFileManager>((ref) {
  return ROSFileManager();
});

final currentDirectoryProvider = StateNotifierProvider<CurrentDirectoryNotifier, String>((ref) {
  return CurrentDirectoryNotifier(ref.read(rosFileManagerProvider));
});

final currentDirectoryFilesProvider = StateNotifierProvider<DirectoryFilesNotifier, List<ROSFileInfo>>((ref) {
  return DirectoryFilesNotifier(ref.read(rosFileManagerProvider));
});

class CurrentDirectoryNotifier extends StateNotifier<String> {
  final ROSFileManager _fileManager;
  
  CurrentDirectoryNotifier(this._fileManager) : super('');

  Future<void> refresh() async {
    state = _fileManager.currentDirectory;
  }

  Future<void> changeDirectory(String path) async {
    await _fileManager.executeFileCommand(['cd', path]);
    await refresh();
  }
}

class DirectoryFilesNotifier extends StateNotifier<List<ROSFileInfo>> {
  final ROSFileManager _fileManager;
  
  DirectoryFilesNotifier(this._fileManager) : super([]);

  Future<void> refresh([String? directory]) async {
    try {
      final files = await _fileManager.listDirectory(directory);
      state = files;
    } catch (e) {
      ErrorHandler.reportException(e, context: 'Refreshing directory files');
      state = [];
    }
  }

  Future<void> createFile(String name) async {
    await _fileManager.createFile(name);
    await refresh();
  }

  Future<void> createDirectory(String name) async {
    await _fileManager.createDirectory(name);
    await refresh();
  }

  Future<void> deleteFile(String path) async {
    await _fileManager.deleteFile(path);
    await refresh();
  }
}