import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WebBrowserScreen extends ConsumerStatefulWidget {
  final String? initialUrl;
  
  const WebBrowserScreen({super.key, this.initialUrl});

  @override
  ConsumerState<WebBrowserScreen> createState() => _WebBrowserScreenState();
}

class _WebBrowserScreenState extends ConsumerState<WebBrowserScreen> {
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = false;
  String _currentUrl = '';
  bool _canGoBack = false;
  bool _canGoForward = false;

  final List<String> _bookmarks = [
    'https://github.com',
    'https://stackoverflow.com',
    'https://flutter.dev',
    'https://pub.dev',
    'https://termux.com',
  ];

  final List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.initialUrl ?? 'https://github.com';
    _urlController.text = _currentUrl;
    _loadPage(_currentUrl);
  }

  void _loadPage(String url) {
    setState(() {
      _isLoading = true;
      _currentUrl = url;
      _urlController.text = url;
    });

    // Simulate page loading
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
        if (!_history.contains(url)) {
          _history.add(url);
        }
      });
    });
  }

  void _navigateToUrl() {
    final url = _urlController.text;
    if (url.isNotEmpty) {
      _loadPage(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ROS Browser'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Navigation buttons
                IconButton(
                  onPressed: _canGoBack ? () {} : null,
                  icon: const Icon(Icons.arrow_back),
                ),
                IconButton(
                  onPressed: _canGoForward ? () {} : null,
                  icon: const Icon(Icons.arrow_forward),
                ),
                IconButton(
                  onPressed: () => _loadPage(_currentUrl),
                  icon: const Icon(Icons.refresh),
                ),
                
                // URL bar
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: _urlController,
                      decoration: InputDecoration(
                        hintText: 'Enter URL or search...',
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          _isLoading ? Icons.hourglass_empty : Icons.public,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onSubmitted: (_) => _navigateToUrl(),
                    ),
                  ),
                ),
                
                // Menu button
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    switch (value) {
                      case 'bookmarks':
                        _showBookmarks();
                        break;
                      case 'history':
                        _showHistory();
                        break;
                      case 'share':
                        // Share URL
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'bookmarks',
                      child: Row(
                        children: [
                          Icon(Icons.bookmark),
                          SizedBox(width: 8),
                          Text('Bookmarks'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'history',
                      child: Row(
                        children: [
                          Icon(Icons.history),
                          SizedBox(width: 8),
                          Text('History'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Icons.share),
                          SizedBox(width: 8),
                          Text('Share'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Web content area
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current URL: $_currentUrl',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                
                // Simulated web content
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _isLoading
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text('Loading...'),
                              ],
                            ),
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ROS Browser',
                                  style: Theme.of(context).textTheme.headlineMedium,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Welcome to the ROS integrated web browser! This is a simulated web page.',
                                ),
                                const SizedBox(height: 16),
                                
                                // Sample content based on URL
                                if (_currentUrl.contains('github'))
                                  _buildGitHubContent()
                                else if (_currentUrl.contains('flutter'))
                                  _buildFlutterContent()
                                else if (_currentUrl.contains('termux'))
                                  _buildTermuxContent()
                                else
                                  _buildGenericContent(),
                              ],
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          
          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGitHubContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('🐙 GitHub', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        const Text('Where the world builds software'),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {},
          child: const Text('Sign up for GitHub'),
        ),
        const SizedBox(height: 16),
        const Text('Popular repositories:'),
        ...[
          'flutter/flutter',
          'termux/termux-app',
          'microsoft/vscode',
          'facebook/react',
        ].map((repo) => ListTile(
          leading: const Icon(Icons.code),
          title: Text(repo),
          subtitle: const Text('Public repository'),
          trailing: const Icon(Icons.star),
        )),
      ],
    );
  }

  Widget _buildFlutterContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('📱 Flutter', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        const Text('Build apps for any screen'),
        const SizedBox(height: 16),
        const Text('Flutter transforms the entire app development process:'),
        const SizedBox(height: 8),
        ...[
          'Fast development',
          'Expressive and flexible UI',
          'Native performance',
        ].map((feature) => ListTile(
          leading: const Icon(Icons.check_circle, color: Colors.green),
          title: Text(feature),
        )),
      ],
    );
  }

  Widget _buildTermuxContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('🔧 Termux', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        const Text('Terminal emulator for Android'),
        const SizedBox(height: 16),
        const Text('Termux combines powerful terminal emulation with an extensive Linux package collection.'),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {},
          child: const Text('Download from F-Droid'),
        ),
      ],
    );
  }

  Widget _buildGenericContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('🌐 Web Page', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        const Text('This is a simulated web page in the ROS browser.'),
        const SizedBox(height: 16),
        const Text('Features:'),
        ...[
          'URL navigation',
          'Bookmarks',
          'History',
          'Share functionality',
        ].map((feature) => ListTile(
          leading: const Icon(Icons.web),
          title: Text(feature),
        )),
      ],
    );
  }

  void _showBookmarks() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bookmarks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _bookmarks.length,
                itemBuilder: (context, index) {
                  final bookmark = _bookmarks[index];
                  return ListTile(
                    leading: const Icon(Icons.bookmark),
                    title: Text(bookmark),
                    onTap: () {
                      Navigator.pop(context);
                      _loadPage(bookmark);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  final historyItem = _history[index];
                  return ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(historyItem),
                    onTap: () {
                      Navigator.pop(context);
                      _loadPage(historyItem);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}