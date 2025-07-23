import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/puzzle_stage.dart';
import '../models/story_data.dart';
import '../providers/game_provider.dart';
import '../utils/puzzle_generator.dart';
import '../widgets/puzzle_grid_widget.dart';
import '../widgets/dialogue_widget.dart';
import 'title_screen.dart';

/// メインのパズル画面
class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({super.key});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen>
    with TickerProviderStateMixin {
  late AnimationController _clearAnimationController;
  bool _showingPreDialogue = false;
  bool _showingPostDialogue = false;

  @override
  void initState() {
    super.initState();
    _clearAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // 初期ステージを設定
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupInitialStage();
    });
  }

  @override
  void dispose() {
    _clearAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<GameProvider>(
          builder: (context, gameProvider, child) {
            final stage = gameProvider.currentStage;
            return Text(
              stage?.name ?? 'パズルタウン',
              style: const TextStyle(fontWeight: FontWeight.bold),
            );
          },
        ),
        backgroundColor: Colors.orange.shade300,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _resetPuzzle(),
            tooltip: 'リセット',
          ),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => _goToTitle(context),
            tooltip: 'タイトルに戻る',
          ),
        ],
      ),
      body: Consumer2<GameProvider, AppProvider>(
        builder: (context, gameProvider, appProvider, child) {
          // ストーリーモードでプレ会話表示中
          if (appProvider.isStoryMode && _showingPreDialogue) {
            return _buildPreDialogue(appProvider.currentStageId);
          }

          // ストーリーモードでポスト会話表示中
          if (appProvider.isStoryMode && _showingPostDialogue) {
            return _buildPostDialogue(appProvider.currentStageId);
          }

          // メインのパズル画面
          return _buildPuzzleContent(gameProvider, appProvider);
        },
      ),
    );
  }

  /// パズルのメインコンテンツを構築
  Widget _buildPuzzleContent(GameProvider gameProvider, AppProvider appProvider) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.lightBlue.shade100,
            Colors.green.shade100,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ステージ情報
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ステージ ${appProvider.currentStageId}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown.shade700,
                    ),
                  ),
                  if (gameProvider.isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade400,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'クリア！',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // パズルグリッド
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const PuzzleGridWidget(),
                  ),
                ),
              ),
            ),

            // ボタンエリア
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _resetPuzzle(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('リセット'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade600,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  if (gameProvider.isCompleted)
                    ElevatedButton.icon(
                      onPressed: () => _proceedToNext(appProvider),
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('次へ'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// プレ会話を構築
  Widget _buildPreDialogue(int stageId) {
    final storyData = _getStoryData(stageId);
    if (storyData == null || storyData.preDialogue.isEmpty) {
      // 会話がない場合はすぐにパズルへ
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _showingPreDialogue = false;
        });
      });
      return const Center(child: CircularProgressIndicator());
    }

    return DialogueWidget(
      dialogueLines: storyData.preDialogue,
      backgroundDescription: storyData.backgroundDescription,
      onDialogueComplete: () {
        setState(() {
          _showingPreDialogue = false;
        });
      },
    );
  }

  /// ポスト会話を構築
  Widget _buildPostDialogue(int stageId) {
    final storyData = _getStoryData(stageId);
    if (storyData == null || storyData.postDialogue.isEmpty) {
      // 会話がない場合はすぐに次のステージへ
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _proceedToNextStage();
      });
      return const Center(child: CircularProgressIndicator());
    }

    return DialogueWidget(
      dialogueLines: storyData.postDialogue,
      backgroundDescription: '${storyData.title} - クリア後',
      onDialogueComplete: () {
        _proceedToNextStage();
      },
    );
  }

  /// 初期ステージをセットアップ
  void _setupInitialStage() {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    final stage = _createStage(appProvider.currentStageId);
    gameProvider.startStage(stage);

    // ストーリーモードならプレ会話を表示
    if (appProvider.isStoryMode) {
      setState(() {
        _showingPreDialogue = true;
      });
    }
  }

  /// パズルをリセット
  void _resetPuzzle() {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    final stage = _createStage(appProvider.currentStageId);
    gameProvider.startStage(stage);
  }

  /// 次のステージに進む
  void _proceedToNext(AppProvider appProvider) {
    if (appProvider.isStoryMode) {
      setState(() {
        _showingPostDialogue = true;
      });
    } else {
      _proceedToNextStage();
    }
  }

  /// 次のステージに進む（実際の処理）
  void _proceedToNextStage() {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    // 最終ステージかチェック
    if (appProvider.isLastStage) {
      // 最終ステージクリア後はタイトルに戻る
      _showGameCompletionDialog();
      return;
    }

    appProvider.advanceToNextStage();
    final nextStage = _createStage(appProvider.currentStageId);
    gameProvider.startStage(nextStage);

    setState(() {
      _showingPostDialogue = false;
      if (appProvider.isStoryMode) {
        _showingPreDialogue = true;
      }
    });
  }

  /// ゲーム完全クリアダイアログを表示
  void _showGameCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          '🎉 ゲームクリア！ 🎉',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'おめでとうございます！\n全てのステージをクリアしました！',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'あなたは立派な道案内人になりました。\n迷子パズルタウンの住民たちも喜んでいることでしょう！',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // ダイアログを閉じる
              _goToTitle(context); // タイトルに戻る
            },
            child: const Text('タイトルに戻る'),
          ),
        ],
      ),
    );
  }

  /// タイトルに戻る
  void _goToTitle(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const TitleScreen(),
      ),
    );
  }

  /// ステージを作成（必ずクリアできるステージ）
  PuzzleStage _createStage(int stageId) {
    // 全てのステージで同じ生成メソッドを使用
    return PuzzleGenerator.generateSolvableStage(stageId);
  }

  /// ストーリーデータを取得
  StoryData? _getStoryData(int stageId) {
    // デモ用のストーリーデータ
    switch (stageId) {
      case 1:
        return StoryData(
          stageId: 1,
          title: 'はじめての出会い',
          backgroundDescription: '見知らぬ街で迷子になってしまった。優しそうな住民が話しかけてきた。',
          preDialogue: [
            const DialogueLine(
              speaker: '住民',
              text: 'あら、迷子さんかしら？この街は道が複雑で、初めての人はよく迷ってしまうのよ。',
              emotion: '心配',
            ),
            const DialogueLine(
              speaker: 'プレイヤー',
              text: 'はい...出口がわからなくて困っています。',
              emotion: '困る',
            ),
            const DialogueLine(
              speaker: '住民',
              text: 'そうね、この街の道路はパズルのようになっているの。道をつなげて出口まで導いてくれる？',
              emotion: '嬉しい',
            ),
          ],
          postDialogue: [
            const DialogueLine(
              speaker: '住民',
              text: 'わあ！上手にできたわね！ありがとう。',
              emotion: '嬉しい',
            ),
            const DialogueLine(
              speaker: 'プレイヤー',
              text: 'でも、まだ街から出られそうにありません...',
              emotion: '困る',
            ),
            const DialogueLine(
              speaker: '住民',
              text: 'あら、この街には他にも迷子さんがいるのよ。みんなを助けてくれたら、きっと出口が見つかるはず！',
              emotion: '嬉しい',
            ),
          ],
        );
      case 2:
        return StoryData(
          stageId: 2,
          title: '商店街の迷子',
          backgroundDescription: '賑やかな商店街で、買い物袋を持った女性が困っている。',
          preDialogue: [
            const DialogueLine(
              speaker: '女性',
              text: 'あの...すみません。この商店街で道に迷ってしまって...',
              emotion: '困る',
            ),
            const DialogueLine(
              speaker: 'プレイヤー',
              text: 'どうされたんですか？',
              emotion: '普通',
            ),
            const DialogueLine(
              speaker: '女性',
              text: '買い物を終えて駐車場に戻りたいのですが、道がぐるぐる回っていて...',
              emotion: '困る',
            ),
            const DialogueLine(
              speaker: 'プレイヤー',
              text: 'なるほど、道をつなげて駐車場まで案内しますね！',
              emotion: '嬉しい',
            ),
            const DialogueLine(
              speaker: '女性',
              text: 'ありがとうございます！よろしくお願いします。',
              emotion: '嬉しい',
            ),
          ],
          postDialogue: [
            const DialogueLine(
              speaker: '女性',
              text: 'わあ！ありがとうございます！無事に駐車場にたどり着けました！',
              emotion: '嬉しい',
            ),
            const DialogueLine(
              speaker: 'プレイヤー',
              text: 'お役に立てて良かったです。',
              emotion: '嬉しい',
            ),
            const DialogueLine(
              speaker: '女性',
              text: 'あなたって本当に道案内が上手ね。実は、この街にはもっと困っている人たちがいるの。',
              emotion: '普通',
            ),
            const DialogueLine(
              speaker: '女性',
              text: '学校の近くで迷子の子供を見かけたわ。その子も助けてもらえるかしら？',
              emotion: '心配',
            ),
            const DialogueLine(
              speaker: 'プレイヤー',
              text: 'もちろんです！すぐに向かいます！',
              emotion: '嬉しい',
            ),
          ],
        );
      case 3:
        return StoryData(
          stageId: 3,
          title: '学校近くの迷子',
          backgroundDescription: '小学校の近くで、ランドセルを背負った子供が泣いている。',
          preDialogue: [
            const DialogueLine(
              speaker: '子供',
              text: 'うぇーん！おうちがわからないよー！',
              emotion: '泣く',
            ),
            const DialogueLine(
              speaker: 'プレイヤー',
              text: 'どうしたの？迷子になっちゃったの？',
              emotion: '心配',
            ),
            const DialogueLine(
              speaker: '子供',
              text: 'うん...学校から帰る時に、いつもと違う道を通ったら迷っちゃった...',
              emotion: '困る',
            ),
            const DialogueLine(
              speaker: 'プレイヤー',
              text: '大丈夫、一緒におうちまでの道を作ろうね。',
              emotion: '優しい',
            ),
            const DialogueLine(
              speaker: '子供',
              text: 'ほんとう？ありがとう、お兄ちゃん！',
              emotion: '嬉しい',
            ),
          ],
          postDialogue: [
            const DialogueLine(
              speaker: '子供',
              text: 'やったー！おうちに帰れる！ありがとう、お兄ちゃん！',
              emotion: '嬉しい',
            ),
            const DialogueLine(
              speaker: 'プレイヤー',
              text: '良かった！今度は気をつけて帰るんだよ。',
              emotion: '嬉しい',
            ),
            const DialogueLine(
              speaker: '子供',
              text: 'うん！そうそう、病院の近くでおじいちゃんが困ってたよ。',
              emotion: '普通',
            ),
            const DialogueLine(
              speaker: '子供',
              text: '「診察が終わったけど出口がわからない」って言ってた！',
              emotion: '普通',
            ),
            const DialogueLine(
              speaker: 'プレイヤー',
              text: 'そうなんだ。そのおじいちゃんも助けに行こう！',
              emotion: '嬉しい',
            ),
          ],
        );
      case 4:
        return StoryData(
          stageId: 4,
          title: '病院での困りごと',
          backgroundDescription: '総合病院の前で、杖をついた高齢者が困っている。',
          preDialogue: [
            const DialogueLine(
              speaker: '高齢者',
              text: 'はて...診察は終わったのじゃが、この病院は複雑でのう...',
              emotion: '困る',
            ),
            const DialogueLine(
              speaker: 'プレイヤー',
              text: 'おじいさん、どちらまで行かれますか？',
              emotion: '普通',
            ),
            const DialogueLine(
              speaker: '高齢者',
              text: 'ああ、ありがとうございます。バス停まで行きたいのじゃが、道がわからなくて...',
              emotion: '困る',
            ),
            const DialogueLine(
              speaker: 'プレイヤー',
              text: '大丈夫です。道をつなげてバス停まで案内しますね。',
              emotion: '優しい',
            ),
            const DialogueLine(
              speaker: '高齢者',
              text: 'それは助かります。若い人は頼もしいのう。',
              emotion: '嬉しい',
            ),
          ],
          postDialogue: [
            const DialogueLine(
              speaker: '高齢者',
              text: 'ありがとうございました！おかげでバス停にたどり着けました。',
              emotion: '嬉しい',
            ),
            const DialogueLine(
              speaker: 'プレイヤー',
              text: 'お疲れさまでした。お気をつけてお帰りください。',
              emotion: '嬉しい',
            ),
            const DialogueLine(
              speaker: '高齢者',
              text: 'ところで、あなたも最初は迷子だったのでしょう？',
              emotion: '普通',
            ),
            const DialogueLine(
              speaker: 'プレイヤー',
              text: 'はい...まだこの街から出る方法がわからなくて...',
              emotion: '困る',
            ),
            const DialogueLine(
              speaker: '高齢者',
              text: '街の中央広場に行ってみなさい。そこに答えがあるはずじゃ。',
              emotion: '嬉しい',
            ),
          ],
        );
      case 5:
        return StoryData(
          stageId: 5,
          title: '街の出口を求めて',
          backgroundDescription: '街の中央広場。ここで最後のパズルを解けば、きっと出口が見つかるはず。',
          preDialogue: [
            const DialogueLine(
              speaker: 'プレイヤー',
              text: 'ここが中央広場...。確かに何か特別な雰囲気がある。',
              emotion: '普通',
            ),
            const DialogueLine(
              speaker: '謎の声',
              text: 'よくここまで来られましたね。多くの人を助けてくれてありがとう。',
              emotion: '普通',
            ),
            const DialogueLine(
              speaker: 'プレイヤー',
              text: 'この声は...？',
              emotion: '驚く',
            ),
            const DialogueLine(
              speaker: '街の精霊',
              text: '私はこの街を守る精霊です。あなたの優しさに心を打たれました。',
              emotion: '嬉しい',
            ),
            const DialogueLine(
              speaker: '街の精霊',
              text: '最後のパズルを解けば、街の出口への道が開かれるでしょう。',
              emotion: '普通',
            ),
          ],
          postDialogue: [
            const DialogueLine(
              speaker: '街の精霊',
              text: '素晴らしい！あなたは真の道案内人になりました。',
              emotion: '嬉しい',
            ),
            const DialogueLine(
              speaker: 'プレイヤー',
              text: 'ありがとうございます。この街で多くのことを学びました。',
              emotion: '嬉しい',
            ),
            const DialogueLine(
              speaker: '街の精霊',
              text: '困っている人を助ける心、それこそが最も大切な道しるべです。',
              emotion: '優しい',
            ),
            const DialogueLine(
              speaker: '街の精霊',
              text: 'あなたならどこへ行っても、きっと多くの人を幸せにできるでしょう。',
              emotion: '嬉しい',
            ),
            const DialogueLine(
              speaker: 'プレイヤー',
              text: 'この経験を忘れずに、これからも人助けをしていきます！',
              emotion: '嬉しい',
            ),
          ],
        );
      default:
        return StoryData(
          stageId: stageId,
          title: 'ステージ $stageId',
          backgroundDescription: '街の別の場所で、また迷子の人を見つけた。',
          preDialogue: [
            const DialogueLine(
              speaker: '住民',
              text: 'また迷子さんが来てくれたのね！今度の道はもう少し複雑よ。',
            ),
          ],
          postDialogue: [
            const DialogueLine(
              speaker: '住民',
              text: '素晴らしい！君のおかげで安心できるわ。',
              emotion: '嬉しい',
            ),
          ],
        );
    }
  }
}
