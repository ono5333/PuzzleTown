import 'puzzle_tile.dart';

/// パズルステージを表すモデル
class PuzzleStage {
  final int id;                          // ステージID
  final String name;                     // ステージ名
  final List<List<PuzzleTile>> grid;     // 4x4のタイルグリッド
  final int startRow;                    // スタート地点の行
  final int startCol;                    // スタート地点の列
  final int goalRow;                     // ゴール地点の行
  final int goalCol;                     // ゴール地点の列
  final int difficulty;                  // 難易度（1-5）

  const PuzzleStage({
    required this.id,
    required this.name,
    required this.grid,
    required this.startRow,
    required this.startCol,
    required this.goalRow,
    required this.goalCol,
    this.difficulty = 1,
  });

  /// ステージをコピーして新しいインスタンスを作成
  PuzzleStage copyWith({
    int? id,
    String? name,
    List<List<PuzzleTile>>? grid,
    int? startRow,
    int? startCol,
    int? goalRow,
    int? goalCol,
    int? difficulty,
  }) {
    return PuzzleStage(
      id: id ?? this.id,
      name: name ?? this.name,
      grid: grid ?? this.grid,
      startRow: startRow ?? this.startRow,
      startCol: startCol ?? this.startCol,
      goalRow: goalRow ?? this.goalRow,
      goalCol: goalCol ?? this.goalCol,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  /// 指定した位置のタイルを取得
  PuzzleTile getTileAt(int row, int col) {
    if (row >= 0 && row < 4 && col >= 0 && col < 4) {
      return grid[row][col];
    }
    throw ArgumentError('Invalid position: ($row, $col)');
  }

  /// グリッドを一次元リストとして取得
  List<PuzzleTile> getTilesAsList() {
    return grid.expand((row) => row).toList();
  }

  /// 空のタイルの位置を取得
  (int row, int col)? getEmptyTilePosition() {
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 4; col++) {
        if (grid[row][col].type == TileType.empty) {
          return (row, col);
        }
      }
    }
    return null;
  }

  /// パズルがクリアされているかチェック
  bool isCompleted() {
    try {
      // 安全なクリア判定：スタートからゴールまでの経路が存在するかをチェック
      return _hasPathFromStartToGoal();
    } catch (e) {
      print('isCompleted エラー: $e');
      // エラーが発生した場合は未完成として扱う
      return false;
    }
  }

  /// スタートからゴールまでの経路があるかチェック（安全版）
  bool _hasPathFromStartToGoal() {
    try {
      final visited = List.generate(4, (_) => List.filled(4, false));
      return _safeDfs(startRow, startCol, visited);
    } catch (e) {
      print('_hasPathFromStartToGoal エラー: $e');
      return false;
    }
  }

  /// 安全な深さ優先探索でゴールを探す
  bool _safeDfs(int row, int col, List<List<bool>> visited) {
    try {
      // 範囲外チェック
      if (row < 0 || row >= 4 || col < 0 || col >= 4) return false;
      
      // 既に訪問済みチェック
      if (visited[row][col]) return false;
      
      visited[row][col] = true;
      
      // ゴールに到達
      if (row == goalRow && col == goalCol) return true;
      
      final currentTile = grid[row][col];
      final connections = _getSafeConnections(currentTile);
      
      // 隣接するタイルをチェック
      for (final direction in connections) {
        int nextRow = row;
        int nextCol = col;
        
        switch (direction) {
          case Direction.up:
            nextRow--;
            break;
          case Direction.down:
            nextRow++;
            break;
          case Direction.left:
            nextCol--;
            break;
          case Direction.right:
            nextCol++;
            break;
        }
        
        // 隣接タイルが範囲内で、かつ現在のタイルと接続可能かチェック
        if (nextRow >= 0 && nextRow < 4 && nextCol >= 0 && nextCol < 4) {
          final nextTile = grid[nextRow][nextCol];
          if (_safeCanConnect(direction, nextTile, nextRow - row, nextCol - col)) {
            if (_safeDfs(nextRow, nextCol, visited)) return true;
          }
        }
      }
      
      return false;
    } catch (e) {
      print('_safeDfs エラー: $e');
      return false;
    }
  }

  /// 安全なタイル接続情報取得
  List<Direction> _getSafeConnections(PuzzleTile tile) {
    try {
      return tile.getConnections();
    } catch (e) {
      print('_getSafeConnections エラー: $e');
      // エラー時は空のリストを返す
      return [];
    }
  }

  /// 安全な接続可能性チェック
  bool _safeCanConnect(Direction fromDirection, PuzzleTile toTile, int deltaRow, int deltaCol) {
    try {
      final toConnections = _getSafeConnections(toTile);
      
      // 逆方向の接続があるかチェック
      Direction oppositeDirection;
      if (deltaRow == -1) oppositeDirection = Direction.down;      // 上に移動 -> 下から接続
      else if (deltaRow == 1) oppositeDirection = Direction.up;    // 下に移動 -> 上から接続
      else if (deltaCol == -1) oppositeDirection = Direction.right;// 左に移動 -> 右から接続
      else oppositeDirection = Direction.left;                     // 右に移動 -> 左から接続
      
      return toConnections.contains(oppositeDirection);
    } catch (e) {
      print('_safeCanConnect エラー: $e');
      return false;
    }
  }
}
