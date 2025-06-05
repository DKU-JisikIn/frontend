// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Question _$QuestionFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'title',
      'content',
      'userId',
      'userName',
      'createdAt',
      'category'
    ],
    disallowNullValues: const [
      'id',
      'title',
      'content',
      'userId',
      'userName',
      'category'
    ],
  );
  return Question(
    id: json['id'] as String,
    title: json['title'] as String,
    content: json['content'] as String,
    userId: json['userId'] as String,
    userName: json['userName'] as String,
    createdAt: Question._dateTimeFromJson(json['createdAt']),
    viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
    answerCount: (json['answerCount'] as num?)?.toInt() ?? 0,
    isOfficial: json['isOfficial'] as bool? ?? false,
    category: json['category'] as String,
    tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
        [],
  );
}

Map<String, dynamic> _$QuestionToJson(Question instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'userId': instance.userId,
      'userName': instance.userName,
      'createdAt': instance.createdAt.toIso8601String(),
      'viewCount': instance.viewCount,
      'answerCount': instance.answerCount,
      'isOfficial': instance.isOfficial,
      'category': instance.category,
      'tags': instance.tags,
    };
