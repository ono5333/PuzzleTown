import 'package:flutter/material.dart';
import '../models/story_data.dart';

/// 会話を表示するウィジェット
class DialogueWidget extends StatefulWidget {
  final List<DialogueLine> dialogueLines;
  final VoidCallback onDialogueComplete;
  final String backgroundDescription;

  const DialogueWidget({
    super.key,
    required this.dialogueLines,
    required this.onDialogueComplete,
    required this.backgroundDescription,
  });

  @override
  State<DialogueWidget> createState() => _DialogueWidgetState();
}

class _DialogueWidgetState extends State<DialogueWidget>
    with TickerProviderStateMixin {
  int _currentLineIndex = 0;
  bool _isTyping = false;
  String _displayedText = '';
  late AnimationController _fadeController;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _startTyping();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 安全な範囲チェック
    if (widget.dialogueLines.isEmpty || _currentLineIndex >= widget.dialogueLines.length) {
      return const SizedBox.shrink();
    }

    final currentLine = widget.dialogueLines[_currentLineIndex];

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.orange.shade100,
            Colors.orange.shade200,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 背景説明エリア
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.backgroundDescription,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.brown.shade700,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            // メインコンテンツエリア
            Expanded(
              child: Center(
                child: FadeTransition(
                  opacity: _fadeController,
                  child: _buildDialogueBox(currentLine),
                ),
              ),
            ),

            // コントロールエリア
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_currentLineIndex + 1} / ${widget.dialogueLines.length}',
                    style: TextStyle(
                      color: Colors.brown.shade600,
                      fontSize: 12,
                    ),
                  ),
                  Row(
                    children: [
                      if (_currentLineIndex > 0)
                        ElevatedButton(
                          onPressed: _previousLine,
                          child: const Text('前へ'),
                        ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _isTyping ? _completeTyping : _nextLine,
                        child: Text(_isTyping ? 'スキップ' : '次へ'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 会話ボックスを構築
  Widget _buildDialogueBox(DialogueLine line) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 話し手の名前
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getSpeakerColor(line.speaker),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              line.speaker,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // セリフ内容
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            constraints: const BoxConstraints(minHeight: 80),
            child: Text(
              _displayedText,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ),
          
          // 感情表現（あれば）
          if (line.emotion != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    _getEmotionIcon(line.emotion!),
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    line.emotion!,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// 話し手に応じた色を取得
  Color _getSpeakerColor(String speaker) {
    switch (speaker.toLowerCase()) {
      case 'プレイヤー':
      case 'player':
        return Colors.blue.shade400;
      case '住民':
      case 'resident':
        return Colors.green.shade400;
      case 'ナレーター':
      case 'narrator':
        return Colors.purple.shade400;
      default:
        return Colors.orange.shade400;
    }
  }

  /// 感情に応じたアイコンを取得
  IconData _getEmotionIcon(String emotion) {
    switch (emotion.toLowerCase()) {
      case '嬉しい':
      case 'happy':
        return Icons.sentiment_very_satisfied;
      case '悲しい':
      case 'sad':
        return Icons.sentiment_very_dissatisfied;
      case '困る':
      case 'confused':
        return Icons.sentiment_neutral;
      case '驚く':
      case 'surprised':
        return Icons.sentiment_satisfied;
      default:
        return Icons.chat_bubble_outline;
    }
  }

  /// タイピング効果を開始
  void _startTyping() {
    if (_currentLineIndex >= widget.dialogueLines.length) return;

    setState(() {
      _isTyping = true;
      _displayedText = '';
    });

    // 安全な配列アクセス
    if (_currentLineIndex < widget.dialogueLines.length) {
      final fullText = widget.dialogueLines[_currentLineIndex].text;
      _typeText(fullText);
    }
  }

  /// テキストをタイピング効果で表示
  void _typeText(String fullText) {
    const typingSpeed = 50; // ミリ秒
    int currentIndex = 0;

    void typeNextChar() {
      if (currentIndex < fullText.length && _isTyping) {
        setState(() {
          _displayedText = fullText.substring(0, currentIndex + 1);
        });
        currentIndex++;
        Future.delayed(const Duration(milliseconds: typingSpeed), typeNextChar);
      } else {
        setState(() {
          _isTyping = false;
          _displayedText = fullText;
        });
      }
    }

    typeNextChar();
  }

  /// タイピングを完了
  void _completeTyping() {
    if (_currentLineIndex < widget.dialogueLines.length) {
      setState(() {
        _isTyping = false;
        _displayedText = widget.dialogueLines[_currentLineIndex].text;
      });
    }
  }

  /// 次の行へ
  void _nextLine() {
    if (_isTyping) {
      _completeTyping();
      return;
    }

    if (_currentLineIndex < widget.dialogueLines.length - 1) {
      setState(() {
        _currentLineIndex++;
      });
      _startTyping();
    } else {
      widget.onDialogueComplete();
    }
  }

  /// 前の行へ
  void _previousLine() {
    if (_currentLineIndex > 0 && _currentLineIndex - 1 < widget.dialogueLines.length) {
      setState(() {
        _currentLineIndex--;
        _isTyping = false;
        _displayedText = widget.dialogueLines[_currentLineIndex].text;
      });
    }
  }
}
