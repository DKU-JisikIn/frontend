import 'package:json_annotation/json_annotation.dart';

part 'question.g.dart';

@JsonSerializable()
class Question {
  final String id;

  final String title;
  final String content;

  final String userId;
  final String userName;

  final DateTime createdAt;
  final int viewCount;
  final int answerCount;

  final bool isAnswered;
  final bool isOfficial; // 공식 자료인지 여부
  final String category; // 학사, 장학금, 교내프로그램 등
  final List<String> tags;

  // 추가 필드
  // 1. 답변 수

  Question({
    required this.id,
    required this.title,
    required this.content,
    required this.userId,
    required this.userName,
    required this.createdAt,
    this.viewCount = 0,
    this.answerCount = 0,
    this.isAnswered = false,
    this.isOfficial = false,
    required this.category,
    this.tags = const [],
  });

  factory Question.fromJson(Map<String, dynamic> json) => _$QuestionFromJson(json);
  Map<String, dynamic> toJson() => _$QuestionToJson(this);

  Question copyWith({
    String? id,
    String? title,
    String? content,
    String? userId,
    String? userName,
    DateTime? createdAt,
    int? viewCount,
    int? answerCount,
    bool? isAnswered,
    bool? isOfficial,
    String? category,
    List<String>? tags,
  }) {
    return Question(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      createdAt: createdAt ?? this.createdAt,
      viewCount: viewCount ?? this.viewCount,
      answerCount: answerCount ?? this.answerCount,
      isAnswered: isAnswered ?? this.isAnswered,
      isOfficial: isOfficial ?? this.isOfficial,
      category: category ?? this.category,
      tags: tags ?? this.tags,
    );
  }
} 