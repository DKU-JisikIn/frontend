import 'package:json_annotation/json_annotation.dart';

part 'chat_message.g.dart';

enum MessageType {
  user,
  assistant,
  system,
}

enum MessageStatus {
  sending,
  sent,
  error,
}

@JsonSerializable()
class ChatMessage {
  final String id;
  final String content;
  final MessageType type;
  final DateTime createdAt;
  final MessageStatus status;
  final Map<String, dynamic>? metadata; // 추가 데이터 (질문 ID, 답변 정보 등)

  ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.createdAt,
    this.status = MessageStatus.sent,
    this.metadata,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);
  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);

  // 사용자 메시지인지 확인하는 getter
  bool get isUser => type == MessageType.user;

  ChatMessage copyWith({
    String? id,
    String? content,
    MessageType? type,
    DateTime? createdAt,
    MessageStatus? status,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
    );
  }

  // 사용자 메시지 생성
  static ChatMessage user(String content, {Map<String, dynamic>? metadata}) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: MessageType.user,
      createdAt: DateTime.now(),
      metadata: metadata,
    );
  }

  // 어시스턴트 메시지 생성
  static ChatMessage assistant(String content, {Map<String, dynamic>? metadata}) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: MessageType.assistant,
      createdAt: DateTime.now(),
      metadata: metadata,
    );
  }

  // 시스템 메시지 생성
  static ChatMessage system(String content, {Map<String, dynamic>? metadata}) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: MessageType.system,
      createdAt: DateTime.now(),
      metadata: metadata,
    );
  }
} 