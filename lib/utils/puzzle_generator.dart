import '../models/puzzle_tile.dart';
import '../models/puzzle_stage.dart';
import 'dart:math';

/// 必ずクリアできるパズルステージを生成するクラス
class PuzzleGenerator {
  static final Random _random = Random();

  /// 解答可能なステージを生成
  static PuzzleStage generateSolvableStage(int stageId) {
    try {
      // ステージごとに手動で作成した固定パターンを使用
      final grid = _createFixedPuzzlePattern(stageId);
      
      print('ステージ$stageId: 固定パターンを使用');
      
      return PuzzleStage(
        id: stageId,
        name: 'ステージ $stageId',
        startRow: 0,
        startCol: 0,
        goalRow: 3,
        goalCol: 3,
        difficulty: stageId,
        grid: grid,
      );
    } catch (e) {
      print('generateSolvableStage でエラー (ステージ$stageId): $e');
      // エラーが発生した場合は最小限のパズルを返す
      return _createFallbackStage(stageId);
    }
  }

  /// ステージごとの固定パズルパターンを作成
  static List<List<PuzzleTile>> _createFixedPuzzlePattern(int stageId) {
    switch (stageId) {
      case 1:
        return [
          [
            const PuzzleTile(id: 1, type: TileType.start, rotation: TileRotation.deg0, row: 0, col: 0, isFixed: true),
            const PuzzleTile(id: 2, type: TileType.straight, rotation: TileRotation.deg0, row: 0, col: 1),
            const PuzzleTile(id: 3, type: TileType.curve, rotation: TileRotation.deg90, row: 0, col: 2),
            const PuzzleTile(id: 4, type: TileType.straight, rotation: TileRotation.deg90, row: 0, col: 3),
          ],
          [
            const PuzzleTile(id: 5, type: TileType.straight, rotation: TileRotation.deg90, row: 1, col: 0),
            const PuzzleTile(id: 6, type: TileType.curve, rotation: TileRotation.deg180, row: 1, col: 1),
            const PuzzleTile(id: 7, type: TileType.straight, rotation: TileRotation.deg0, row: 1, col: 2),
            const PuzzleTile(id: 8, type: TileType.straight, rotation: TileRotation.deg0, row: 1, col: 3),
          ],
          [
            const PuzzleTile(id: 9, type: TileType.straight, rotation: TileRotation.deg0, row: 2, col: 0),
            const PuzzleTile(id: 10, type: TileType.empty, rotation: TileRotation.deg0, row: 2, col: 1),
            const PuzzleTile(id: 11, type: TileType.curve, rotation: TileRotation.deg0, row: 2, col: 2),
            const PuzzleTile(id: 12, type: TileType.straight, rotation: TileRotation.deg0, row: 2, col: 3),
          ],
          [
            const PuzzleTile(id: 13, type: TileType.curve, rotation: TileRotation.deg0, row: 3, col: 0),
            const PuzzleTile(id: 14, type: TileType.straight, rotation: TileRotation.deg90, row: 3, col: 1),
            const PuzzleTile(id: 15, type: TileType.straight, rotation: TileRotation.deg90, row: 3, col: 2),
            const PuzzleTile(id: 16, type: TileType.goal, rotation: TileRotation.deg0, row: 3, col: 3, isFixed: true),
          ],
        ];

      case 2:
        return [
          [
            const PuzzleTile(id: 1, type: TileType.start, rotation: TileRotation.deg0, row: 0, col: 0, isFixed: true),
            const PuzzleTile(id: 2, type: TileType.curve, rotation: TileRotation.deg270, row: 0, col: 1),
            const PuzzleTile(id: 3, type: TileType.straight, rotation: TileRotation.deg90, row: 0, col: 2),
            const PuzzleTile(id: 4, type: TileType.straight, rotation: TileRotation.deg0, row: 0, col: 3),
          ],
          [
            const PuzzleTile(id: 5, type: TileType.straight, rotation: TileRotation.deg0, row: 1, col: 0),
            const PuzzleTile(id: 6, type: TileType.straight, rotation: TileRotation.deg90, row: 1, col: 1),
            const PuzzleTile(id: 7, type: TileType.curve, rotation: TileRotation.deg180, row: 1, col: 2),
            const PuzzleTile(id: 8, type: TileType.empty, rotation: TileRotation.deg0, row: 1, col: 3),
          ],
          [
            const PuzzleTile(id: 9, type: TileType.curve, rotation: TileRotation.deg0, row: 2, col: 0),
            const PuzzleTile(id: 10, type: TileType.straight, rotation: TileRotation.deg90, row: 2, col: 1),
            const PuzzleTile(id: 11, type: TileType.curve, rotation: TileRotation.deg90, row: 2, col: 2),
            const PuzzleTile(id: 12, type: TileType.straight, rotation: TileRotation.deg0, row: 2, col: 3),
          ],
          [
            const PuzzleTile(id: 13, type: TileType.straight, rotation: TileRotation.deg90, row: 3, col: 0),
            const PuzzleTile(id: 14, type: TileType.curve, rotation: TileRotation.deg180, row: 3, col: 1),
            const PuzzleTile(id: 15, type: TileType.straight, rotation: TileRotation.deg0, row: 3, col: 2),
            const PuzzleTile(id: 16, type: TileType.goal, rotation: TileRotation.deg0, row: 3, col: 3, isFixed: true),
          ],
        ];

      case 3:
        return [
          [
            const PuzzleTile(id: 1, type: TileType.start, rotation: TileRotation.deg0, row: 0, col: 0, isFixed: true),
            const PuzzleTile(id: 2, type: TileType.straight, rotation: TileRotation.deg90, row: 0, col: 1),
            const PuzzleTile(id: 3, type: TileType.curve, rotation: TileRotation.deg90, row: 0, col: 2),
            const PuzzleTile(id: 4, type: TileType.curve, rotation: TileRotation.deg270, row: 0, col: 3),
          ],
          [
            const PuzzleTile(id: 5, type: TileType.curve, rotation: TileRotation.deg0, row: 1, col: 0),
            const PuzzleTile(id: 6, type: TileType.straight, rotation: TileRotation.deg90, row: 1, col: 1),
            const PuzzleTile(id: 7, type: TileType.straight, rotation: TileRotation.deg0, row: 1, col: 2),
            const PuzzleTile(id: 8, type: TileType.straight, rotation: TileRotation.deg90, row: 1, col: 3),
          ],
          [
            const PuzzleTile(id: 9, type: TileType.straight, rotation: TileRotation.deg90, row: 2, col: 0),
            const PuzzleTile(id: 10, type: TileType.curve, rotation: TileRotation.deg180, row: 2, col: 1),
            const PuzzleTile(id: 11, type: TileType.empty, rotation: TileRotation.deg0, row: 2, col: 2),
            const PuzzleTile(id: 12, type: TileType.curve, rotation: TileRotation.deg180, row: 2, col: 3),
          ],
          [
            const PuzzleTile(id: 13, type: TileType.curve, rotation: TileRotation.deg0, row: 3, col: 0),
            const PuzzleTile(id: 14, type: TileType.straight, rotation: TileRotation.deg90, row: 3, col: 1),
            const PuzzleTile(id: 15, type: TileType.straight, rotation: TileRotation.deg90, row: 3, col: 2),
            const PuzzleTile(id: 16, type: TileType.goal, rotation: TileRotation.deg0, row: 3, col: 3, isFixed: true),
          ],
        ];

      case 4:
        return [
          [
            const PuzzleTile(id: 1, type: TileType.start, rotation: TileRotation.deg0, row: 0, col: 0, isFixed: true),
            const PuzzleTile(id: 2, type: TileType.curve, rotation: TileRotation.deg270, row: 0, col: 1),
            const PuzzleTile(id: 3, type: TileType.tShape, rotation: TileRotation.deg180, row: 0, col: 2),
            const PuzzleTile(id: 4, type: TileType.curve, rotation: TileRotation.deg180, row: 0, col: 3),
          ],
          [
            const PuzzleTile(id: 5, type: TileType.straight, rotation: TileRotation.deg0, row: 1, col: 0),
            const PuzzleTile(id: 6, type: TileType.straight, rotation: TileRotation.deg90, row: 1, col: 1),
            const PuzzleTile(id: 7, type: TileType.straight, rotation: TileRotation.deg0, row: 1, col: 2),
            const PuzzleTile(id: 8, type: TileType.empty, rotation: TileRotation.deg0, row: 1, col: 3),
          ],
          [
            const PuzzleTile(id: 9, type: TileType.curve, rotation: TileRotation.deg0, row: 2, col: 0),
            const PuzzleTile(id: 10, type: TileType.straight, rotation: TileRotation.deg90, row: 2, col: 1),
            const PuzzleTile(id: 11, type: TileType.curve, rotation: TileRotation.deg90, row: 2, col: 2),
            const PuzzleTile(id: 12, type: TileType.straight, rotation: TileRotation.deg0, row: 2, col: 3),
          ],
          [
            const PuzzleTile(id: 13, type: TileType.straight, rotation: TileRotation.deg90, row: 3, col: 0),
            const PuzzleTile(id: 14, type: TileType.curve, rotation: TileRotation.deg180, row: 3, col: 1),
            const PuzzleTile(id: 15, type: TileType.straight, rotation: TileRotation.deg0, row: 3, col: 2),
            const PuzzleTile(id: 16, type: TileType.goal, rotation: TileRotation.deg0, row: 3, col: 3, isFixed: true),
          ],
        ];

      case 5:
        return [
          [
            const PuzzleTile(id: 1, type: TileType.start, rotation: TileRotation.deg0, row: 0, col: 0, isFixed: true),
            const PuzzleTile(id: 2, type: TileType.tShape, rotation: TileRotation.deg270, row: 0, col: 1),
            const PuzzleTile(id: 3, type: TileType.straight, rotation: TileRotation.deg90, row: 0, col: 2),
            const PuzzleTile(id: 4, type: TileType.curve, rotation: TileRotation.deg180, row: 0, col: 3),
          ],
          [
            const PuzzleTile(id: 5, type: TileType.curve, rotation: TileRotation.deg0, row: 1, col: 0),
            const PuzzleTile(id: 6, type: TileType.straight, rotation: TileRotation.deg0, row: 1, col: 1),
            const PuzzleTile(id: 7, type: TileType.curve, rotation: TileRotation.deg180, row: 1, col: 2),
            const PuzzleTile(id: 8, type: TileType.straight, rotation: TileRotation.deg0, row: 1, col: 3),
          ],
          [
            const PuzzleTile(id: 9, type: TileType.straight, rotation: TileRotation.deg90, row: 2, col: 0),
            const PuzzleTile(id: 10, type: TileType.empty, rotation: TileRotation.deg0, row: 2, col: 1),
            const PuzzleTile(id: 11, type: TileType.straight, rotation: TileRotation.deg0, row: 2, col: 2),
            const PuzzleTile(id: 12, type: TileType.curve, rotation: TileRotation.deg270, row: 2, col: 3),
          ],
          [
            const PuzzleTile(id: 13, type: TileType.curve, rotation: TileRotation.deg0, row: 3, col: 0),
            const PuzzleTile(id: 14, type: TileType.straight, rotation: TileRotation.deg90, row: 3, col: 1),
            const PuzzleTile(id: 15, type: TileType.straight, rotation: TileRotation.deg90, row: 3, col: 2),
            const PuzzleTile(id: 16, type: TileType.goal, rotation: TileRotation.deg0, row: 3, col: 3, isFixed: true),
          ],
        ];

      default:
        // 範囲外のステージはフォールバックを使用
        return _createFallbackStage(stageId).grid;
    }
  }

  /// シンプルなシャッフル（エラーを回避）
  static List<List<PuzzleTile>> _simpleShuffleFromSolved(List<List<PuzzleTile>> solvedGrid) {
    try {
      // 深いコピーを作成
      final shuffledGrid = solvedGrid.map((row) => 
        row.map((tile) => tile.copyWith()).toList()
      ).toList();

      // 少ない移動回数でシンプルにシャッフル
      final shuffleMoves = 10 + (_random.nextInt(10)); // 10-20回の移動
      
      for (int i = 0; i < shuffleMoves; i++) {
        _performRandomValidMove(shuffledGrid);
      }

      // 位置情報を更新
      _updateTilePositions(shuffledGrid);
      
      return shuffledGrid;
    } catch (e) {
      print('_simpleShuffleFromSolved でエラー: $e');
      // エラーが発生した場合は元のグリッドを返す
      return solvedGrid;
    }
  }

  /// フォールバック用の簡単なステージを作成
  static PuzzleStage _createFallbackStage(int stageId) {
    final grid = [
      [
        const PuzzleTile(id: 1, type: TileType.start, rotation: TileRotation.deg0, row: 0, col: 0, isFixed: true),
        const PuzzleTile(id: 2, type: TileType.straight, rotation: TileRotation.deg90, row: 0, col: 1),
        const PuzzleTile(id: 3, type: TileType.straight, rotation: TileRotation.deg90, row: 0, col: 2),
        const PuzzleTile(id: 4, type: TileType.empty, rotation: TileRotation.deg0, row: 0, col: 3),
      ],
      [
        const PuzzleTile(id: 5, type: TileType.straight, rotation: TileRotation.deg0, row: 1, col: 0),
        const PuzzleTile(id: 6, type: TileType.curve, rotation: TileRotation.deg0, row: 1, col: 1),
        const PuzzleTile(id: 7, type: TileType.straight, rotation: TileRotation.deg90, row: 1, col: 2),
        const PuzzleTile(id: 8, type: TileType.curve, rotation: TileRotation.deg90, row: 1, col: 3),
      ],
      [
        const PuzzleTile(id: 9, type: TileType.straight, rotation: TileRotation.deg0, row: 2, col: 0),
        const PuzzleTile(id: 10, type: TileType.straight, rotation: TileRotation.deg90, row: 2, col: 1),
        const PuzzleTile(id: 11, type: TileType.curve, rotation: TileRotation.deg180, row: 2, col: 2),
        const PuzzleTile(id: 12, type: TileType.straight, rotation: TileRotation.deg0, row: 2, col: 3),
      ],
      [
        const PuzzleTile(id: 13, type: TileType.curve, rotation: TileRotation.deg0, row: 3, col: 0),
        const PuzzleTile(id: 14, type: TileType.straight, rotation: TileRotation.deg90, row: 3, col: 1),
        const PuzzleTile(id: 15, type: TileType.straight, rotation: TileRotation.deg90, row: 3, col: 2),
        const PuzzleTile(id: 16, type: TileType.goal, rotation: TileRotation.deg0, row: 3, col: 3, isFixed: true),
      ],
    ];

    return PuzzleStage(
      id: stageId,
      name: 'ステージ $stageId (セーフモード)',
      startRow: 0,
      startCol: 0,
      goalRow: 3,
      goalCol: 3,
      difficulty: stageId,
      grid: grid,
    );
  }

  /*
  /// 完成された状態のパズルを作成
  static List<List<PuzzleTile>> _createSolvedPuzzle() {
    return [
      [
        const PuzzleTile(id: 1, type: TileType.start, rotation: TileRotation.deg0, row: 0, col: 0, isFixed: true),
        const PuzzleTile(id: 2, type: TileType.straight, rotation: TileRotation.deg90, row: 0, col: 1),
        const PuzzleTile(id: 3, type: TileType.curve, rotation: TileRotation.deg180, row: 0, col: 2),
        const PuzzleTile(id: 4, type: TileType.straight, rotation: TileRotation.deg0, row: 0, col: 3),
      ],
      [
        const PuzzleTile(id: 5, type: TileType.straight, rotation: TileRotation.deg0, row: 1, col: 0),
        const PuzzleTile(id: 6, type: TileType.curve, rotation: TileRotation.deg0, row: 1, col: 1),
        const PuzzleTile(id: 7, type: TileType.straight, rotation: TileRotation.deg0, row: 1, col: 2),
        const PuzzleTile(id: 8, type: TileType.straight, rotation: TileRotation.deg0, row: 1, col: 3),
      ],
      [
        const PuzzleTile(id: 9, type: TileType.straight, rotation: TileRotation.deg0, row: 2, col: 0),
        const PuzzleTile(id: 10, type: TileType.straight, rotation: TileRotation.deg90, row: 2, col: 1),
        const PuzzleTile(id: 11, type: TileType.straight, rotation: TileRotation.deg90, row: 2, col: 2),
        const PuzzleTile(id: 12, type: TileType.curve, rotation: TileRotation.deg270, row: 2, col: 3),
      ],
      [
        const PuzzleTile(id: 13, type: TileType.curve, rotation: TileRotation.deg0, row: 3, col: 0),
        const PuzzleTile(id: 14, type: TileType.straight, rotation: TileRotation.deg90, row: 3, col: 1),
        const PuzzleTile(id: 15, type: TileType.empty, rotation: TileRotation.deg0, row: 3, col: 2),
        const PuzzleTile(id: 16, type: TileType.goal, rotation: TileRotation.deg0, row: 3, col: 3, isFixed: true),
      ],
    ];
  }
  */

  /// 完成状態から逆算してシャッフル
  static List<List<PuzzleTile>> _shuffleFromSolved(List<List<PuzzleTile>> solvedGrid) {
    try {
      // 深いコピーを作成
      final shuffledGrid = solvedGrid.map((row) => 
        row.map((tile) => tile.copyWith()).toList()
      ).toList();

      // 正当な移動のみでシャッフル（必ず解ける保証）
      final shuffleMoves = 50 + (_random.nextInt(50)); // 50-100回の移動に戻す
      
      for (int i = 0; i < shuffleMoves; i++) {
        _performRandomValidMove(shuffledGrid);
      }

      // 位置情報を更新
      _updateTilePositions(shuffledGrid);
      
      // クリア状態でないことを確認（必要に応じて追加シャッフル）
      int attempts = 0;
      while (_isCompleted(shuffledGrid) && attempts < 20) {
        // まだクリア状態なら追加でシャッフル
        for (int i = 0; i < 10; i++) {
          _performRandomValidMove(shuffledGrid);
        }
        _updateTilePositions(shuffledGrid);
        attempts++;
      }
      
      return shuffledGrid;
    } catch (e) {
      print('_shuffleFromSolved でエラー: $e');
      // エラーが発生した場合は元のグリッドを返す
      return solvedGrid;
    }
  }

  /// 正当な移動を1回実行
  static void _performRandomValidMove(List<List<PuzzleTile>> grid) {
    try {
      // 空のタイルの位置を見つける
      int emptyRow = -1;
      int emptyCol = -1;
      
      for (int row = 0; row < 4; row++) {
        for (int col = 0; col < 4; col++) {
          if (grid[row][col].type == TileType.empty) {
            emptyRow = row;
            emptyCol = col;
            break;
          }
        }
        if (emptyRow != -1) break;
      }

      if (emptyRow == -1) {
        print('警告: 空きタイルが見つかりません');
        return; // 空きタイルが見つからない
      }
      
      // 隣接するタイルを見つける
      final adjacentTiles = <(int, int)>[];
      
      // 上下左右をチェック
      final directions = [(-1, 0), (1, 0), (0, -1), (0, 1)];
      for (final (dRow, dCol) in directions) {
        final newRow = emptyRow + dRow;
        final newCol = emptyCol + dCol;
        
        if (newRow >= 0 && newRow < 4 && newCol >= 0 && newCol < 4) {
          final tile = grid[newRow][newCol];
          // 固定タイル以外は移動可能
          if (!tile.isFixed) {
            adjacentTiles.add((newRow, newCol));
          }
        }
      }

      if (adjacentTiles.isNotEmpty) {
        final (moveRow, moveCol) = adjacentTiles[_random.nextInt(adjacentTiles.length)];
        
        // タイルを交換
        final temp = grid[emptyRow][emptyCol];
        grid[emptyRow][emptyCol] = grid[moveRow][moveCol];
        grid[moveRow][moveCol] = temp;
      }
    } catch (e) {
      print('_performRandomValidMove でエラー: $e');
      rethrow;
    }
  }

  /// タイルの位置情報を更新
  static void _updateTilePositions(List<List<PuzzleTile>> grid) {
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 4; col++) {
        grid[row][col] = grid[row][col].copyWith(row: row, col: col);
      }
    }
  }

  /// グリッドがクリア状態かどうかをチェック
  static bool _isCompleted(List<List<PuzzleTile>> grid) {
    // スタートからゴールまでの経路があるかをチェック
    final visited = List.generate(4, (_) => List.filled(4, false));
    return _dfs(grid, 0, 0, visited); // スタート位置(0,0)から探索
  }

  /// 深さ優先探索でゴールを探す
  static bool _dfs(List<List<PuzzleTile>> grid, int row, int col, List<List<bool>> visited) {
    try {
      // 範囲外チェック
      if (row < 0 || row >= 4 || col < 0 || col >= 4) return false;
      
      // 既に訪問済みチェック
      if (visited[row][col]) return false;
      
      visited[row][col] = true;
      
      // ゴールに到達
      if (row == 3 && col == 3) return true;
      
      final currentTile = grid[row][col];
      final connections = _getTileConnections(currentTile);
      
      // 隣接するタイルをチェック
      for (final direction in connections) {
        int nextRow = row;
        int nextCol = col;
        
        switch (direction) {
          case 0: // up
            nextRow--;
            break;
          case 1: // right
            nextCol++;
            break;
          case 2: // down
            nextRow++;
            break;
          case 3: // left
            nextCol--;
            break;
        }
        
        // 隣接タイルが範囲内で、かつ現在のタイルと接続可能かチェック
        if (nextRow >= 0 && nextRow < 4 && nextCol >= 0 && nextCol < 4) {
          final nextTile = grid[nextRow][nextCol];
          if (_canConnect(direction, nextTile, nextRow - row, nextCol - col)) {
            if (_dfs(grid, nextRow, nextCol, visited)) return true;
          }
        }
      }
      
      return false;
    } catch (e) {
      print('_dfs でエラー: row=$row, col=$col, エラー=$e');
      return false;
    }
  }

  /// タイルの接続方向を取得
  static List<int> _getTileConnections(PuzzleTile tile) {
    try {
      switch (tile.type) {
        case TileType.straight:
          return _rotateDirections([0, 2], tile.rotation); // up, down
        case TileType.curve:
          return _rotateDirections([0, 1], tile.rotation); // up, right
        case TileType.tShape:
          return _rotateDirections([0, 3, 1], tile.rotation); // up, left, right
        case TileType.cross:
          return [0, 1, 2, 3]; // up, right, down, left
        case TileType.start:
        case TileType.goal:
          return [0, 1, 2, 3]; // up, right, down, left
        case TileType.empty:
        default:
          return [];
      }
    } catch (e) {
      print('_getTileConnections でエラー: タイル=${tile.type}, 回転=${tile.rotation}, エラー=$e');
      return [];
    }
  }

  /// 方向を回転させる（安全版）
  static List<int> _rotateDirections(List<int> directions, TileRotation rotation) {
    try {
      // 安全な回転ステップ取得
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
          rotationSteps = 0;
      }
      
      final result = directions.map((dir) {
        return (dir + rotationSteps) % 4;
      }).toList();
      
      return result;
    } catch (e) {
      print('_rotateDirections でエラー: directions=$directions, rotation=$rotation, エラー=$e');
      return directions; // エラー時は元の方向を返す
    }
  }

  /// 2つのタイルが接続可能かチェック
  /// 2つのタイルが接続可能かチェック
  static bool _canConnect(int fromDirection, PuzzleTile toTile, int deltaRow, int deltaCol) {
    try {
      final toConnections = _getTileConnections(toTile);
      
      // 逆方向の接続があるかチェック
      int oppositeDirection;
      if (deltaRow == -1) oppositeDirection = 2;      // 上に移動 -> 下から接続
      else if (deltaRow == 1) oppositeDirection = 0;  // 下に移動 -> 上から接続
      else if (deltaCol == -1) oppositeDirection = 1; // 左に移動 -> 右から接続
      else oppositeDirection = 3;                      // 右に移動 -> 左から接続
      
      return toConnections.contains(oppositeDirection);
    } catch (e) {
      print('_canConnect でエラー: fromDirection=$fromDirection, toTile=${toTile.type}, deltaRow=$deltaRow, deltaCol=$deltaCol, エラー=$e');
      return false;
    }
  }

}
