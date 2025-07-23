/// タイルの種類を定義するenum
enum TileType {
  empty,      // 空のタイル
  straight,   // 直線道路
  curve,      // カーブ道路
  tShape,     // T字道路
  cross,      // 十字道路
  start,      // スタート地点
  goal,       // ゴール地点
}

/// タイルの回転角度を定義するenum
enum TileRotation {
  deg0,    // 0度
  deg90,   // 90度
  deg180,  // 180度
  deg270,  // 270度
}

/// パズルのタイルを表すモデルクラス
class PuzzleTile {
  final int id;                    // タイルのID
  final TileType type;            // タイルの種類
  final TileRotation rotation;    // タイルの回転角度
  final int row;                  // グリッド上の行位置
  final int col;                  // グリッド上の列位置
  final bool isFixed;             // 固定タイル（移動不可）かどうか

  const PuzzleTile({
    required this.id,
    required this.type,
    required this.rotation,
    required this.row,
    required this.col,
    this.isFixed = false,
  });

  /// タイルをコピーして新しいインスタンスを作成
  PuzzleTile copyWith({
    int? id,
    TileType? type,
    TileRotation? rotation,
    int? row,
    int? col,
    bool? isFixed,
  }) {
    return PuzzleTile(
      id: id ?? this.id,
      type: type ?? this.type,
      rotation: rotation ?? this.rotation,
      row: row ?? this.row,
      col: col ?? this.col,
      isFixed: isFixed ?? this.isFixed,
    );
  }

  /// タイルが接続可能な方向を取得（完全安全版）
  List<Direction> getConnections() {
    try {
      switch (type) {
        case TileType.straight:
          return _rotateDirections([Direction.up, Direction.down], rotation);
        case TileType.curve:
          return _rotateDirections([Direction.up, Direction.right], rotation);
        case TileType.tShape:
          return _rotateDirections([Direction.up, Direction.left, Direction.right], rotation);
        case TileType.cross:
          return [Direction.up, Direction.down, Direction.left, Direction.right];
        case TileType.start:
        case TileType.goal:
          return [Direction.up, Direction.down, Direction.left, Direction.right];
        case TileType.empty:
        default:
          return [];
      }
    } catch (e) {
      print('getConnections エラー: type=$type, rotation=$rotation, エラー=$e');
      // エラー時は安全な接続を返す
      return [Direction.up, Direction.down, Direction.left, Direction.right];
    }
  }

  /// 方向を回転させる（安全版）
  List<Direction> _rotateDirections(List<Direction> directions, TileRotation rotation) {
    try {
      // 入力チェック
      if (directions.isEmpty) {
        return [];
      }

      // TileRotation.degXXX から安全な回転ステップを取得
      int rotationSteps;
      switch (rotation) {
        case TileRotation.deg0:
          rotationSteps = 0;
          break;
        case TileRotation.deg90:
          rotationSteps = 1;
          break;
        case TileRotation.deg180:
          rotationSteps = 2;
          break;
        case TileRotation.deg270:
          rotationSteps = 3;
          break;
        default:
          rotationSteps = 0; // フォールバック
      }

      final result = <Direction>[];
      for (int i = 0; i < directions.length; i++) {
        final dir = directions[i];
        
        // Direction enumの安全な回転計算
        int dirIndex;
        switch (dir) {
          case Direction.up:
            dirIndex = 0;
            break;
          case Direction.right:
            dirIndex = 1;
            break;
          case Direction.down:
            dirIndex = 2;
            break;
          case Direction.left:
            dirIndex = 3;
            break;
          default:
            dirIndex = 0; // フォールバック
        }

        final newIndex = (dirIndex + rotationSteps) % 4;
        
        // 安全なDirection値の取得
        Direction newDirection;
        switch (newIndex) {
          case 0:
            newDirection = Direction.up;
            break;
          case 1:
            newDirection = Direction.right;
            break;
          case 2:
            newDirection = Direction.down;
            break;
          case 3:
            newDirection = Direction.left;
            break;
          default:
            newDirection = Direction.up; // フォールバック
        }
        
        result.add(newDirection);
      }
      
      return result;
    } catch (e) {
      print('_rotateDirections でエラー: $e');
      // エラー時は元の方向リストをそのまま返す
      return directions;
    }
  }
}

/// 方向を表すenum（上から時計回り）
enum Direction {
  up,     // 上
  right,  // 右
  down,   // 下
  left,   // 左
}
