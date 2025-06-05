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
      isLiked: json['isLiked'] as bool? ?? false,
      department: json['department'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      userLevel: (json['userLevel'] as num?)?.toInt() ?? 1,
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
      'isLiked': instance.isLiked,
      'department': instance.department,
      'isVerified': instance.isVerified,
      'userLevel': instance.userLevel,
    };
