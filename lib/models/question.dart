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
    required this.userName,
    this.tags,
    this.viewCount = 0,
    this.answerCount = 0,
    this.isAnswered = false,
    this.isOfficial = false,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      userId: json['user_id']?.toString(),
      userName: json['userName']?.toString() ?? 
               json['user']?['nickname']?.toString() ?? 
               '알 수 없음',
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      viewCount: json['view_count'] is int ? json['view_count'] : 0,
      answerCount: json['answer_count'] is int ? json['answer_count'] : 0,
      isAnswered: json['is_answered'] is bool ? json['is_answered'] : false,
      isOfficial: json['is_official'] is bool ? json['is_official'] : false,
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
      'userName': userName,
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