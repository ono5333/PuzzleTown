# 迷子パズルタウン (Lost Puzzle Town)

Flutterで作成したスライドパズルゲームです。道路タイルを回転・移動させて道をつなげ、迷子の人々を助けるストーリーモードが楽しめます。

## ゲーム概要

プレイヤーは見知らぬ街で迷子になり、様々な住民を助けながら街の出口を探します。各ステージでパズルを解いて道をつなげ、迷子の人々を目的地まで案内しましょう。

### 特徴

- **5つのステージ**: それぞれ異なるキャラクターとストーリー
- **豊富な会話**: 各ステージに詳細なプレ・ポスト会話
- **スライドパズル**: 4x4グリッドでタイルを移動・回転
- **美しいUI**: グラデーション背景とスムーズなアニメーション

### ストーリー

1. **ステージ1**: 街の住民との出会い
2. **ステージ2**: 商店街の女性を駐車場まで案内
3. **ステージ3**: 迷子の子供を家まで送る
4. **ステージ4**: 病院の高齢者をバス停まで案内
5. **ステージ5**: 街の精霊との最終ステージ

## 技術仕様

- **フレームワーク**: Flutter 3.0+
- **状態管理**: Provider
- **描画**: CustomPainter（道路パターンの描画）
- **アーキテクチャ**: MVVM（Model-View-ViewModel）

### 主要ファイル構成

```
lib/
├── main.dart                 # メインアプリケーション
├── models/                   # データモデル
│   ├── puzzle_tile.dart     # パズルタイルモデル
│   ├── puzzle_stage.dart    # ステージモデル
│   └── story_data.dart      # ストーリーデータモデル
├── providers/                # 状態管理
│   └── game_provider.dart   # ゲーム状態プロバイダー
├── screens/                  # 画面
│   ├── title_screen.dart    # タイトル画面
│   └── puzzle_screen.dart   # パズル画面
├── widgets/                  # ウィジェット
│   ├── puzzle_grid_widget.dart   # パズルグリッド
│   ├── tile_widget.dart          # タイルウィジェット
│   └── dialogue_widget.dart      # 会話ウィジェット
└── utils/                    # ユーティリティ
    └── puzzle_generator.dart # パズル生成ロジック
```

## セットアップ

1. Flutter SDKをインストール
2. リポジトリをクローン
```bash
git clone https://github.com/yourusername/PuzzleTown.git
cd PuzzleTown
```

3. 依存関係をインストール
```bash
flutter pub get
```

4. アプリを実行
```bash
flutter run
```

## 依存関係

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0
  cupertino_icons: ^1.0.2
```

## 操作方法

- **タイル移動**: 空きスペースに隣接するタイルをタップ
- **タイル回転**: タイルを長押し
- **会話進行**: 画面をタップして次の会話へ
- **リセット**: 右上のリセットボタンでパズルをリセット

## スクリーンショット

*（実際のゲーム画面のスクリーンショットを追加してください）*

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。

## 作者

[あなたの名前]

## 貢献

バグ報告や機能改善の提案は、GitHubのIssuesページでお願いします。
