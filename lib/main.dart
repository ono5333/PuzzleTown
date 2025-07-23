import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'screens/title_screen.dart';

void main() {
  runApp(const PuzzleTownApp());
}

/// 迷子パズルタウンのメインアプリケーション
class PuzzleTownApp extends StatelessWidget {
  const PuzzleTownApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ゲーム状態管理
        ChangeNotifierProvider(create: (_) => GameProvider()),
        // アプリ全体の状態管理
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: MaterialApp(
        title: '迷子パズルタウン',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.orange,
          fontFamily: 'NotoSansJP', // 日本語フォント（システムデフォルト）
          visualDensity: VisualDensity.adaptivePlatformDensity,
          
          // アプリ全体のテーマ設定
          scaffoldBackgroundColor: Colors.orange.shade50,
          
          // AppBarのテーマ
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.orange.shade400,
            foregroundColor: Colors.white,
            elevation: 4,
            centerTitle: true,
            titleTextStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          // ボタンのテーマ
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          
          // カードのテーマ
          cardTheme: CardTheme(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          
          // ダイアログのテーマ
          dialogTheme: DialogTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        
        // ダークテーマ（将来の拡張用）
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.orange,
          fontFamily: 'NotoSansJP',
          scaffoldBackgroundColor: Colors.grey.shade900,
        ),
        
        // テーマモード
        themeMode: ThemeMode.system,
        
        // 初期画面はタイトル画面
        home: const TitleScreen(),
        
        // ルート設定（将来の拡張用）
        routes: {
          '/title': (context) => const TitleScreen(),
          // '/puzzle': (context) => const PuzzleScreen(),
          // 他のルートは必要に応じて追加
        },
        
        // エラー処理
        builder: (context, child) {
          // エラーウィジェットのカスタマイズ
          ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
            return MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('エラーが発生しました'),
                  backgroundColor: Colors.red,
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'アプリでエラーが発生しました',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        errorDetails.exception.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          // アプリを再起動（実際の実装では他の方法を使用）
                          // SystemNavigator.pop();
                        },
                        child: const Text('アプリを再起動'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          };
          
          return child ?? const SizedBox.shrink();
        },
      ),
    );
  }
}
