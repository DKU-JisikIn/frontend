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
  // final bool isAIGenerated; // AI가 생성한 답변인지
  final bool isLiked; // 현재 사용자가 좋아요를 눌렀는지
  
  // 사용자 인증 정보
  final String? department; // 소속 학과/부서
  // final String? studentId; // 학번 (일부만 표시용)
  final bool isVerified; // 소속 인증 여부
  final int userLevel; // 사용자 레벨 (1-5)

  // 추가 필드
  // 1. 좋아요 개수

  Answer({
    required this.id,
    required this.questionId,
    required this.content,
    required this.userId,
    required this.userName,
    required this.createdAt,
    this.likeCount = 0,
    this.isAccepted = false,
    // this.isAIGenerated = false,
    this.isLiked = false,
    this.department,
    // this.studentId,
    this.isVerified = false,
    this.userLevel = 1,
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
    // bool? isAIGenerated,
    bool? isLiked,
    String? department,
    // String? studentId,
    bool? isVerified,
    int? userLevel,
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
      // isAIGenerated: isAIGenerated ?? this.isAIGenerated,
      isLiked: isLiked ?? this.isLiked,
      department: department ?? this.department,
      // studentId: studentId ?? this.studentId,
      isVerified: isVerified ?? this.isVerified,
      userLevel: userLevel ?? this.userLevel,
    );
  }
} 