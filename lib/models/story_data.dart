/// 会話のセリフを表すモデル
class DialogueLine {
  final String speaker;    // 話し手の名前
  final String text;       // セリフ内容
  final String? emotion;   // 感情表現（optional）

  const DialogueLine({
    required this.speaker,
    required this.text,
    this.emotion,
  });

  factory DialogueLine.fromJson(Map<String, dynamic> json) {
    return DialogueLine(
      speaker: json['speaker'] as String,
      text: json['text'] as String,
      emotion: json['emotion'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'speaker': speaker,
      'text': text,
      if (emotion != null) 'emotion': emotion,
    };
  }
}

/// ステージのストーリーデータを表すモデル
class StoryData {
  final int stageId;                    // ステージID
  final String title;                   // ストーリータイトル
  final List<DialogueLine> preDialogue; // パズル前の会話
  final List<DialogueLine> postDialogue;// パズル後の会話
  final String backgroundDescription;    // 背景の説明

  const StoryData({
    required this.stageId,
    required this.title,
    required this.preDialogue,
    required this.postDialogue,
    required this.backgroundDescription,
  });

  factory StoryData.fromJson(Map<String, dynamic> json) {
    return StoryData(
      stageId: json['stageId'] as int,
      title: json['title'] as String,
      preDialogue: (json['preDialogue'] as List)
          .map((e) => DialogueLine.fromJson(e as Map<String, dynamic>))
          .toList(),
      postDialogue: (json['postDialogue'] as List)
          .map((e) => DialogueLine.fromJson(e as Map<String, dynamic>))
          .toList(),
      backgroundDescription: json['backgroundDescription'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stageId': stageId,
      'title': title,
      'preDialogue': preDialogue.map((e) => e.toJson()).toList(),
      'postDialogue': postDialogue.map((e) => e.toJson()).toList(),
      'backgroundDescription': backgroundDescription,
    };
  }
}
