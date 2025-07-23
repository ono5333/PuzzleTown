import 'package:flutter/material.dart';
import '../models/puzzle_tile.dart';

/// パズルタイルを表示するウィジェット
class TileWidget extends StatelessWidget {
  final PuzzleTile tile;
  final double size;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isAnimating;

  const TileWidget({
    super.key,
    required this.tile,
    required this.size,
    this.onTap,
    this.onLongPress,
    this.isAnimating = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: Duration(milliseconds: isAnimating ? 300 : 0),
        width: size,
        height: size,
        margin: const EdgeInsets.all(0.5), // マージンを最小に
        decoration: BoxDecoration(
          color: _getTileColor(),
          border: tile.type != TileType.empty && tile.type != TileType.start && tile.type != TileType.goal
              ? null // 道路タイルはボーダーなし
              : Border.all(
                  color: Colors.grey.shade400,
                  width: 0.5,
                ),
          borderRadius: BorderRadius.circular(4), // 角丸も小さく
          boxShadow: tile.type != TileType.empty
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 1,
                    offset: const Offset(0.5, 0.5),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: _buildTileContent(),
        ),
      ),
    );
  }

  /// タイルの色を取得
  Color _getTileColor() {
    switch (tile.type) {
      case TileType.empty:
        return Colors.grey.shade200;
      case TileType.start:
        return Colors.green.shade300;
      case TileType.goal:
        return Colors.red.shade300;
      case TileType.straight:
      case TileType.curve:
      case TileType.tShape:
      case TileType.cross:
        return Colors.brown.shade200;
    }
  }

  /// タイルの内容を構築
  Widget _buildTileContent() {
    if (tile.type == TileType.empty) {
      return const SizedBox.shrink();
    }

    return Transform.rotate(
      angle: tile.rotation.index * 1.5708, // 90度 = π/2 ラジアン
      child: _buildRoadPattern(),
    );
  }

  /// 道路パターンを構築
  Widget _buildRoadPattern() {
    return CustomPaint(
      painter: RoadPainter(tile.type),
      size: Size(size, size),
    );
  }
}

/// 道路パターンを描画するCustomPainter
class RoadPainter extends CustomPainter {
  final TileType tileType;

  RoadPainter(this.tileType);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown.shade600
      ..strokeWidth = size.width * 0.25  // 線の太さを調整
      ..strokeCap = StrokeCap.square;     // 四角い端にして枠にぴったり合わせる

    final center = Offset(size.width / 2, size.height / 2);

    switch (tileType) {
      case TileType.straight:
        // 縦の直線（枠いっぱいまで）
        canvas.drawLine(
          Offset(center.dx, 0),
          Offset(center.dx, size.height),
          paint,
        );
        break;

      case TileType.curve:
        // 上から右へのL字型カーブ（枠いっぱいまで）
        // 縦の線（上から中央まで）
        canvas.drawLine(
          Offset(center.dx, 0),
          center,
          paint,
        );
        // 横の線（中央から右まで）
        canvas.drawLine(
          center,
          Offset(size.width, center.dy),
          paint,
        );
        break;

      case TileType.tShape:
        // T字型（上、左、右）（枠いっぱいまで）
        canvas.drawLine(Offset(center.dx, 0), center, paint);
        canvas.drawLine(Offset(0, center.dy), center, paint);
        canvas.drawLine(center, Offset(size.width, center.dy), paint);
        break;

      case TileType.cross:
        // 十字型（枠いっぱいまで）
        canvas.drawLine(
          Offset(center.dx, 0),
          Offset(center.dx, size.height),
          paint,
        );
        canvas.drawLine(
          Offset(0, center.dy),
          Offset(size.width, center.dy),
          paint,
        );
        break;

      case TileType.start:
        // スタート地点（緑の円）
        canvas.drawCircle(
          center,
          size.width * 0.3,
          Paint()..color = Colors.green.shade700,
        );
        // 「S」の文字
        final textPainter = TextPainter(
          text: TextSpan(
            text: 'S',
            style: TextStyle(
              color: Colors.white,
              fontSize: size.width * 0.4,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            center.dx - textPainter.width / 2,
            center.dy - textPainter.height / 2,
          ),
        );
        break;

      case TileType.goal:
        // ゴール地点（赤の円）
        canvas.drawCircle(
          center,
          size.width * 0.3,
          Paint()..color = Colors.red.shade700,
        );
        // 「G」の文字
        final textPainter = TextPainter(
          text: TextSpan(
            text: 'G',
            style: TextStyle(
              color: Colors.white,
              fontSize: size.width * 0.4,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            center.dx - textPainter.width / 2,
            center.dy - textPainter.height / 2,
          ),
        );
        break;

      case TileType.empty:
        // 何も描画しない
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
