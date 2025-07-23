# PuzzleGame

## AIを使用しノーコードでアプリを作る

### 開発環境
VisualStudioCode

Copilot + Claude Sonnet4

### プロンプト

Flutterで「迷子パズルタウン」というスライドパズルゲームを作成してください。

【ゲーム概要】
- 4x4グリッドのスライドパズルゲーム
- 道路タイルを回転・移動させて道をつなげる
- 5つのステージがあるストーリーモード
- タイトル画面、パズル画面、会話システム

【技術仕様】
- Flutter 3.0+、Provider状態管理
- CustomPainterでタイル描画（直線、カーブ、T字、十字の道路パターン）
- Direction enum（Up/Right/Down/Left）とTileRotation enum（deg0/90/180/270）
- スライド移動とタップ回転の両方に対応

【必要なファイル構成】
- lib/main.dart（メインアプリ）
- lib/models/（puzzle_tile.dart, puzzle_stage.dart, story_data.dart）
- lib/providers/game_provider.dart（ゲーム状態管理）
- lib/screens/（title_screen.dart, puzzle_screen.dart）
- lib/widgets/（puzzle_grid_widget.dart, tile_widget.dart, dialogue_widget.dart）
- lib/utils/puzzle_generator.dart（パズル生成）

【ストーリー内容】
1. ステージ1：街の住民との出会い（3会話×2）
2. ステージ2：商店街の女性を駐車場まで案内（5会話×2）
3. ステージ3：迷子の子供を家まで送る（5会話×2）
4. ステージ4：病院の高齢者をバス停まで案内（5会話×2）
5. ステージ5：街の精霊との最終ステージ（5会話×2）

【UI要求】
- オレンジ色のAppBar
- 水色から緑色のグラデーション背景
- リセットボタン、ホームボタン
- ステージクリア時の「次へ」ボタン
- ゲーム完了時の祝福ダイアログ

【重要な実装ポイント】
- Direction.values[index]は使用禁止（RangeError回避）
- 必ずクリア可能なパズルを生成する仕組み
- DialogueWidgetでの会話進行システム
- タイル接続判定とパス検索アルゴリズム

安定して動作し、エラーのない完全なゲームを作成してください。
