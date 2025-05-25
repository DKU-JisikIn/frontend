import 'package:json_annotation/json_annotation.dart';

part 'answer.g.dart';

@JsonSerializable()
class Answer {
  final String id;
  final String questionId;
  final String content;
  final String userId;
  final String userName;
  final DateTime createdAt;
  final int likeCount;
  final bool isAccepted; // 채택된 답변인지
  final bool isAIGenerated; // AI가 생성한 답변인지

  Answer({
    required this.id,
    required this.questionId,
    required this.content,
    required this.userId,
    required this.userName,
    required this.createdAt,
    this.likeCount = 0,
    this.isAccepted = false,
    this.isAIGenerated = false,
  });

  factory Answer.fromJson(Map<String, dynamic> json) => _$AnswerFromJson(json);
  Map<String, dynamic> toJson() => _$AnswerToJson(this);

  Answer copyWith({
    String? id,
    String? questionId,
    String? content,
    String? userId,
    String? userName,
    DateTime? createdAt,
    int? likeCount,
    bool? isAccepted,
    bool? isAIGenerated,
  }) {
    return Answer(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      content: content ?? this.content,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      createdAt: createdAt ?? this.createdAt,
      likeCount: likeCount ?? this.likeCount,
      isAccepted: isAccepted ?? this.isAccepted,
      isAIGenerated: isAIGenerated ?? this.isAIGenerated,
    );
  }
} 