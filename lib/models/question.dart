import 'package:json_annotation/json_annotation.dart';

part 'question.g.dart';

@JsonSerializable()
class Question {
  final String id;

  final String title;
  final String content;

  final String? userId;
  final String userName;

  final DateTime createdAt;
  final int viewCount;
  final int answerCount;

  final bool isAnswered;
  final bool isOfficial; // 공식 자료인지 여부
  final String category; // 학사, 장학금, 교내프로그램 등
  final List<String>? tags;

  // 추가 필드
  // 1. 답변 수

  Question({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.createdAt,
    this.userId,
    this.tags,
    this.viewCount = 0,
    this.answerCount = 0,
    this.isAnswered = false,
    this.isOfficial = false,
    required this.userName,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      category: json['category'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      userId: json['user_id'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      viewCount: json['view_count'] as int? ?? 0,
      answerCount: json['answer_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
      'tags': tags,
      'view_count': viewCount,
      'answer_count': answerCount,
    };
  }

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