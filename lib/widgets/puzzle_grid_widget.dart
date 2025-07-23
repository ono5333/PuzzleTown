import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/puzzle_tile.dart';
import '../providers/game_provider.dart';
import 'tile_widget.dart';

/// パズルのグリッドを表示するウィジェット
class PuzzleGridWidget extends StatefulWidget {
  const PuzzleGridWidget({super.key});

  @override
  State<PuzzleGridWidget> createState() => _PuzzleGridWidgetState();
}

class _PuzzleGridWidgetState extends State<PuzzleGridWidget>
    with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final stage = gameProvider.currentStage;
        if (stage == null) {
          return const Center(
            child: Text('ステージが読み込まれていません'),
          );
        }

        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        
        // 画面の幅と高さのうち、小さい方を基準にサイズを決定
        final availableSize = min(screenWidth * 0.9, screenHeight * 0.6);
        final gridSize = availableSize;
        final tileSize = (gridSize - 32) / 4 - 8; // パディングとマージンを考慮

        return AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            // 震えエフェクト：左右に小さく揺らす
            final offset = sin(_shakeAnimation.value * 3.14159 * 4) * 3;
            return Transform.translate(
              offset: Offset(offset, 0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: gridSize,
                  maxHeight: gridSize,
                ),
                child: Container(
                  width: gridSize,
                  height: gridSize,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.brown.shade100,
                    border: Border.all(color: Colors.brown.shade400, width: 2),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: child,
                ),
              ),
            );
          },
            child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: 16,
            itemBuilder: (context, index) {
              final row = index ~/ 4;
              final col = index % 4;
              final tile = stage.getTileAt(row, col);

              return DragTarget<PuzzleTile>(
                onAccept: (draggedTile) {
                  // 隣接チェック：空のタイルと隣接している場合のみ移動可能
                  if (_isAdjacentToEmpty(draggedTile, row, col, gameProvider.currentStage)) {
                    gameProvider.moveTile(
                      draggedTile.row,
                      draggedTile.col,
                      row,
                      col,
                    );
                  }
                },
                onWillAccept: (draggedTile) {
                  // 空のタイルで、かつ隣接している場合のみドロップ可能
                  return draggedTile != null &&
                         tile.type == TileType.empty && 
                         _isAdjacentToEmpty(draggedTile, row, col, gameProvider.currentStage);
                },
                builder: (context, candidateData, rejectedData) {
                  return _buildTileWithDrag(
                    context,
                    tile,
                    tileSize,
                    gameProvider,
                    candidateData.isNotEmpty,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  /// ドラッグ可能なタイルを構築
  Widget _buildTileWithDrag(
    BuildContext context,
    PuzzleTile tile,
    double tileSize,
    GameProvider gameProvider,
    bool isTargeted,
  ) {
    // 空のタイルや固定タイルはドラッグ不可
    if (tile.type == TileType.empty || tile.isFixed) {
      return Container(
        decoration: isTargeted
            ? BoxDecoration(
                border: Border.all(color: Colors.blue, width: 3),
                borderRadius: BorderRadius.circular(8),
              )
            : null,
        child: TileWidget(
          tile: tile,
          size: tileSize,
          onLongPress: () => _rotateTile(gameProvider, tile),
          isAnimating: gameProvider.isAnimating,
        ),
      );
    }

    return Draggable<PuzzleTile>(
      data: tile,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.1,
          child: TileWidget(
            tile: tile,
            size: tileSize,
            isAnimating: false,
          ),
        ),
      ),
      childWhenDragging: Container(
        width: tileSize,
        height: tileSize,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.open_with,
          color: Colors.grey.shade600,
          size: tileSize * 0.5,
        ),
      ),
      child: TileWidget(
        tile: tile,
        size: tileSize,
        onTap: () => _attemptMoveToEmpty(gameProvider, tile),
        onLongPress: () => _rotateTile(gameProvider, tile),
        isAnimating: gameProvider.isAnimating,
      ),
    );
  }

  /// タイルを空の場所に移動を試行（UIフィードバック付き）
  void _attemptMoveToEmpty(GameProvider gameProvider, PuzzleTile tile) {
    final stage = gameProvider.currentStage;
    if (stage == null) return;

    final emptyPos = stage.getEmptyTilePosition();
    if (emptyPos == null) return;

    final (emptyRow, emptyCol) = emptyPos;
    
    // 隣接している場合のみ移動可能
    final rowDiff = (tile.row - emptyRow).abs();
    final colDiff = (tile.col - emptyCol).abs();
    
    if ((rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1)) {
      gameProvider.moveTile(tile.row, tile.col, emptyRow, emptyCol);
    } else {
      // 移動できない場合は軽い震えエフェクト
      _showInvalidMoveAnimation();
    }
  }

  /// 無効な移動時の震えアニメーション
  void _showInvalidMoveAnimation() {
    _shakeController.forward().then((_) {
      _shakeController.reset();
    });
  }

  /// ドラッグされたタイルが指定位置（空のタイル）と隣接しているかチェック
  bool _isAdjacentToEmpty(PuzzleTile draggedTile, int emptyRow, int emptyCol, stage) {
    if (stage == null) return false;
    
    // ドラッグされたタイルの現在位置と空のタイルの位置の距離を計算
    final rowDiff = (draggedTile.row - emptyRow).abs();
    final colDiff = (draggedTile.col - emptyCol).abs();
    
    // 隣接している場合のみtrue（上下左右のみ、斜めは不可）
    return (rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1);
  }

  /// タイルを回転
  void _rotateTile(GameProvider gameProvider, PuzzleTile tile) {
    if (tile.type != TileType.empty && !tile.isFixed) {
      gameProvider.rotateTile(tile.row, tile.col);
    }
  }
}
