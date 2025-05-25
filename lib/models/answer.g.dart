// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'answer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Answer _$AnswerFromJson(Map<String, dynamic> json) => Answer(
  id: json['id'] as String,
  questionId: json['questionId'] as String,
  content: json['content'] as String,
  userId: json['userId'] as String,
  userName: json['userName'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
  isAccepted: json['isAccepted'] as bool? ?? false,
  isAIGenerated: json['isAIGenerated'] as bool? ?? false,
);

Map<String, dynamic> _$AnswerToJson(Answer instance) => <String, dynamic>{
  'id': instance.id,
  'questionId': instance.questionId,
  'content': instance.content,
  'userId': instance.userId,
  'userName': instance.userName,
  'createdAt': instance.createdAt.toIso8601String(),
  'likeCount': instance.likeCount,
  'isAccepted': instance.isAccepted,
  'isAIGenerated': instance.isAIGenerated,
};
