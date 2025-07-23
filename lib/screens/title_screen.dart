import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'puzzle_screen.dart';

/// ゲームのタイトル画面
class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key});

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen>
    with TickerProviderStateMixin {
  late AnimationController _titleController;
  late AnimationController _buttonController;
  late Animation<double> _titleAnimation;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _titleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _titleController,
      curve: Curves.elasticOut,
    ));

    _buttonAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.bounceOut,
    ));

    // アニメーション開始
    _titleController.forward();
    Future.delayed(const Duration(milliseconds: 800), () {
      _buttonController.forward();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.lightBlue.shade300,
              Colors.lightBlue.shade100,
              Colors.orange.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              
              // ゲームタイトル
              AnimatedBuilder(
                animation: _titleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _titleAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            '迷子パズルタウン',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown.shade700,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  offset: const Offset(2, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Puzzle Town',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.brown.shade500,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const Spacer(),

              // 街の簡易イラスト
              AnimatedBuilder(
                animation: _titleAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _titleAnimation.value,
                    child: _buildCityIllustration(),
                  );
                },
              ),

              const Spacer(),

              // ゲーム開始ボタン
              AnimatedBuilder(
                animation: _buttonAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _buttonAnimation.value,
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () => _startGame(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade400,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 8,
                          ),
                          child: const Text(
                            'はじめる',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // 設定ボタン（将来の拡張用）
                        OutlinedButton(
                          onPressed: () => _showSettings(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.brown.shade600,
                            side: BorderSide(color: Colors.brown.shade600),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            'せってい',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  /// 街のイラストを描画
  Widget _buildCityIllustration() {
    return Container(
      width: 250,
      height: 150,
      child: CustomPaint(
        painter: CityPainter(),
      ),
    );
  }

  /// ゲーム開始
  void _startGame(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const PuzzleScreen(),
      ),
    );
  }

  /// 設定画面を表示
  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('設定'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Consumer<AppProvider>(
              builder: (context, appProvider, child) {
                return SwitchListTile(
                  title: const Text('ストーリーモード'),
                  subtitle: const Text('会話パートを表示'),
                  value: appProvider.isStoryMode,
                  onChanged: (value) {
                    appProvider.toggleStoryMode();
                  },
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
}

/// 街の簡易イラストを描画するCustomPainter
class CityPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // 空と地面
    paint.color = Colors.lightBlue.shade200;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.7),
      paint,
    );

    paint.color = Colors.green.shade300;
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.7, size.width, size.height * 0.3),
      paint,
    );

    // 建物を描画
    _drawBuilding(canvas, 20, size.height * 0.4, 40, 50, Colors.red.shade300);
    _drawBuilding(canvas, 80, size.height * 0.3, 35, 60, Colors.blue.shade300);
    _drawBuilding(canvas, 140, size.height * 0.45, 45, 45, Colors.yellow.shade300);
    _drawBuilding(canvas, 200, size.height * 0.35, 30, 55, Colors.purple.shade300);

    // 道路
    paint.color = Colors.grey.shade400;
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.65, size.width, 10),
      paint,
    );

    // 雲
    _drawCloud(canvas, 50, 20, Colors.white);
    _drawCloud(canvas, 150, 30, Colors.white);
  }

  void _drawBuilding(Canvas canvas, double x, double y, double width, double height, Color color) {
    final paint = Paint()..color = color;
    canvas.drawRect(Rect.fromLTWH(x, y, width, height), paint);
    
    // 屋根
    paint.color = Colors.brown.shade400;
    final path = Path();
    path.moveTo(x - 5, y);
    path.lineTo(x + width / 2, y - 15);
    path.lineTo(x + width + 5, y);
    path.close();
    canvas.drawPath(path, paint);

    // 窓
    paint.color = Colors.yellow.shade200;
    canvas.drawRect(Rect.fromLTWH(x + 5, y + 10, 8, 8), paint);
    canvas.drawRect(Rect.fromLTWH(x + width - 13, y + 10, 8, 8), paint);
  }

  void _drawCloud(Canvas canvas, double x, double y, Color color) {
    final paint = Paint()..color = color;
    canvas.drawCircle(Offset(x, y), 12, paint);
    canvas.drawCircle(Offset(x + 15, y), 10, paint);
    canvas.drawCircle(Offset(x + 25, y + 5), 8, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
