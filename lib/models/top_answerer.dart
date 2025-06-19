class TopAnswerer {
  final String id;
  final String userName;
  final String profileImageUrl;
  final int score;
  final int rank;
  final int answerCount;
  final int likeCount;

  TopAnswerer({
    required this.id,
    required this.userName,
    required this.profileImageUrl,
    required this.score,
    required this.rank,
    required this.answerCount,
    required this.likeCount,
  });
} 