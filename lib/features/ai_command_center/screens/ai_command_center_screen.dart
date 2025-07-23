import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/gemini_service.dart';

class AICommandCenterScreen extends ConsumerStatefulWidget {
  const AICommandCenterScreen({super.key});

  @override
  ConsumerState<AICommandCenterScreen> createState() => _AICommandCenterScreenState();
}

class _AICommandCenterScreenState extends ConsumerState<AICommandCenterScreen> {
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  String _selectedMode = 'Terminal Assistant';
  final List<String> _aiModes = [
    'Terminal Assistant',
    'Code Generator',
    'Security Auditor',
    'System Optimizer',
    'Network Analyzer',
    'Script Writer',
    'Documentation Creator',
    'Bug Detector',
    'Performance Analyzer',
    'Learning Assistant',
  ];

  final List<Map<String, dynamic>> _conversation = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Command Center'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.psychology),
            onSelected: (mode) => setState(() => _selectedMode = mode),
            itemBuilder: (context) => _aiModes
                .map((mode) => PopupMenuItem(value: mode, child: Text(mode)))
                .toList(),
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () => setState(() => _conversation.clear()),
          ),
        ],
      ),
      body: Column(
        children: [
          // AI Mode Selector
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade500],
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Mode: $_selectedMode',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Gemini AI',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          // Conversation Area
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _conversation.length,
              itemBuilder: (context, index) {
                final message = _conversation[index];
                final isUser = message['isUser'] as bool;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isUser) ...[
                        CircleAvatar(
                          backgroundColor: Colors.deepPurple,
                          radius: 16,
                          child: const Icon(Icons.android, color: Colors.white, size: 16),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: isUser 
                                ? Colors.blue.shade100 
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isUser 
                                  ? Colors.blue.shade300 
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isUser ? 'You' : 'Gemini AI',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isUser ? Colors.blue.shade700 : Colors.deepPurple,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                message['content'] as String,
                                style: GoogleFonts.jetBrainsMono(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                message['timestamp'] as String,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isUser) ...[
                        const SizedBox(width: 8),
                        CircleAvatar(
                          backgroundColor: Colors.blue,
                          radius: 16,
                          child: const Icon(Icons.person, color: Colors.white, size: 16),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),

          // Quick Action Buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildQuickActionButton('Generate Script', Icons.code, () {
                  _promptController.text = 'Create a bash script that ';
                }),
                _buildQuickActionButton('Explain Command', Icons.help, () {
                  _promptController.text = 'Explain this command: ';
                }),
                _buildQuickActionButton('Security Audit', Icons.security, () {
                  _promptController.text = 'Perform security audit on: ';
                }),
                _buildQuickActionButton('Optimize Code', Icons.speed, () {
                  _promptController.text = 'Optimize this code for performance: ';
                }),
                _buildQuickActionButton('Debug Issue', Icons.bug_report, () {
                  _promptController.text = 'Help debug this issue: ';
                }),
              ],
            ),
          ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promptController,
                    maxLines: 3,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: 'Ask Gemini AI anything about terminal commands, coding, or system administration...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  backgroundColor: Colors.deepPurple,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(String label, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(right: 8.0),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple.shade50,
          foregroundColor: Colors.deepPurple,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  void _sendMessage() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    // Add user message
    setState(() {
      _conversation.add({
        'content': prompt,
        'isUser': true,
        'timestamp': DateTime.now().toString().substring(11, 19),
      });
    });

    _promptController.clear();
    _scrollToBottom();

    // Add loading message
    setState(() {
      _conversation.add({
        'content': 'Generating response...',
        'isUser': false,
        'timestamp': DateTime.now().toString().substring(11, 19),
      });
    });

    try {
      // Get response from Gemini AI
      final geminiService = ref.read(geminiServiceProvider);
      String response;

      switch (_selectedMode) {
        case 'Terminal Assistant':
          response = await geminiService.generateTerminalCommand(prompt);
          break;
        case 'Code Generator':
          response = await geminiService.generateBashScript(prompt);
          break;
        case 'Security Auditor':
          response = await geminiService.auditCommand(prompt);
          break;
        case 'System Optimizer':
          response = await geminiService.optimizeSystem(prompt);
          break;
        case 'Network Analyzer':
          response = await geminiService.explainNetworkScan(prompt);
          break;
        default:
          response = await geminiService.generateContent(
            'As a $_selectedMode, please help with: $prompt'
          );
      }

      // Update the last message with the response
      setState(() {
        _conversation.last['content'] = response;
      });
    } catch (e) {
      setState(() {
        _conversation.last['content'] = 'Error: Unable to generate response. ${e.toString()}';
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}