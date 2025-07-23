import 'package:flutter/foundation.dart';
import '../models/puzzle_stage.dart';
import '../models/puzzle_tile.dart';

/// パズルゲームの状態を管理するProvider
class GameProvider extends ChangeNotifier {
  PuzzleStage? _currentStage;
  int _currentStageIndex = 0;
  bool _isCompleted = false;
  bool _isAnimating = false;

  // Getters
  PuzzleStage? get currentStage => _currentStage;
  int get currentStageIndex => _currentStageIndex;
  bool get isCompleted => _isCompleted;
  bool get isAnimating => _isAnimating;

  /// 新しいステージを開始
  void startStage(PuzzleStage stage) {
    _currentStage = stage;
    _isCompleted = false;
    _isAnimating = false;
    notifyListeners();
  }

  /// タイルを移動
  bool moveTile(int fromRow, int fromCol, int toRow, int toCol) {
    if (_currentStage == null || _isAnimating || _isCompleted) return false;

    // 移動先が空のタイルかチェック
    final targetTile = _currentStage!.getTileAt(toRow, toCol);
    if (targetTile.type != TileType.empty) return false;

    // 移動元のタイルを取得
    final sourceTile = _currentStage!.getTileAt(fromRow, fromCol);
    if (sourceTile.isFixed) return false;

    // タイルを交換
    final newGrid = _copyGrid(_currentStage!.grid);
    newGrid[toRow][toCol] = sourceTile.copyWith(row: toRow, col: toCol);
    newGrid[fromRow][fromCol] = targetTile.copyWith(row: fromRow, col: fromCol);

    _currentStage = _currentStage!.copyWith(grid: newGrid);

    // クリア状態をチェック（安全版）
    _checkCompletionSafely();
    
    notifyListeners();
    return true;
  }

  /// タイルを回転
  void rotateTile(int row, int col) {
    if (_currentStage == null || _isAnimating || _isCompleted) return;

    final tile = _currentStage!.getTileAt(row, col);
    if (tile.isFixed || tile.type == TileType.empty) return;

    // 安全な回転処理
    TileRotation newRotation;
    switch (tile.rotation) {
      case TileRotation.deg0:
        newRotation = TileRotation.deg90;
        break;
      case TileRotation.deg90:
        newRotation = TileRotation.deg180;
        break;
      case TileRotation.deg180:
        newRotation = TileRotation.deg270;
        break;
      case TileRotation.deg270:
        newRotation = TileRotation.deg0;
        break;
      default:
        newRotation = TileRotation.deg0; // フォールバック
    }
    
    final newGrid = _copyGrid(_currentStage!.grid);
    newGrid[row][col] = tile.copyWith(rotation: newRotation);

    _currentStage = _currentStage!.copyWith(grid: newGrid);

    // クリア状態をチェック（安全版）
    _checkCompletionSafely();
    
    notifyListeners();
  }

  /// ステージをリセット
  void resetStage() {
    if (_currentStage == null) return;
    
    // デフォルトのステージデータを再生成（実装時にはここでオリジナルデータを復元）
    _isCompleted = false;
    _isAnimating = false;
    notifyListeners();
  }

  /// 次のステージへ進む
  void nextStage() {
    _currentStageIndex++;
    _isCompleted = false;
    notifyListeners();
  }

  /// アニメーション状態を設定
  void setAnimating(bool animating) {
    _isAnimating = animating;
    notifyListeners();
  }

  /// クリア状態をチェック（安全版）
  void _checkCompletionSafely() {
    try {
      if (_currentStage != null && _currentStage!.isCompleted()) {
        _isCompleted = true;
        print('ステージクリア！');
        // クリア演出のため少し遅延
        Future.delayed(const Duration(milliseconds: 500), () {
          setAnimating(true);
        });
      }
    } catch (e) {
      print('クリア判定エラー: $e');
      // エラーが発生した場合は何もしない
    }
  }

  /// クリア状態をチェック
  void _checkCompletion() {
    // 一時的に手動でクリア判定を無効化
    // プレイヤーが手動でクリアボタンを押すか、別の方法で判定
    _isCompleted = false;
  }

  /// 手動でクリア状態を設定（デバッグ用）
  void setCompleted(bool completed) {
    _isCompleted = completed;
    if (completed) {
      // クリア演出のため少し遅延
      Future.delayed(const Duration(milliseconds: 500), () {
        setAnimating(true);
      });
    }
    notifyListeners();
  }

  /// グリッドの深いコピーを作成
  List<List<PuzzleTile>> _copyGrid(List<List<PuzzleTile>> original) {
    return original.map((row) => List<PuzzleTile>.from(row)).toList();
  }
}

/// アプリ全体の状態を管理するProvider
class AppProvider extends ChangeNotifier {
  int _currentStageId = 1;
  bool _isStoryMode = true;
  static const int maxStages = 5; // 最大ステージ数

  // Getters
  int get currentStageId => _currentStageId;
  bool get isStoryMode => _isStoryMode;
  int get maxStageCount => maxStages;
  bool get isLastStage => _currentStageId >= maxStages;

  /// ストーリーモードの切り替え
  void toggleStoryMode() {
    _isStoryMode = !_isStoryMode;
    notifyListeners();
  }

  /// 現在のステージIDを設定
  void setCurrentStageId(int stageId) {
    if (stageId >= 1 && stageId <= maxStages) {
      _currentStageId = stageId;
      notifyListeners();
    }
  }

  /// 次のステージに進む
  void advanceToNextStage() {
    if (_currentStageId < maxStages) {
      _currentStageId++;
      notifyListeners();
    }
  }

  /// ステージをリセット
  void resetToFirstStage() {
    _currentStageId = 1;
    notifyListeners();
  }
}
