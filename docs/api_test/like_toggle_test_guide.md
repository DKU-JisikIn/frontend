# 좋아요 토글 기능 테스트 가이드

## 📋 개요
좋아요 토글 기능을 완벽하게 테스트하기 위한 Mockoon 설정 파일과 사용법입니다.

## 🚀 빠른 시작

### 1. Mockoon 서버 실행
```bash
# CLI로 실행
mockoon-cli start --data docs/api_test/like_toggle_test_mockoon.json --port 3001

# 또는 Mockoon 앱에서 파일 임포트
```

### 2. 제공되는 API 엔드포인트

#### 📝 답변 목록 조회
```
GET /api/questions/q001/answers
```

**응답 데이터**: 3개의 테스트 답변
- `a001`: 학사팀 답변 (채택됨, 좋아요 25개)
- `a002`: 김학생 답변 (좋아요 12개)
- `a003`: 박학생 답변 (좋아요 8개)

#### ❤️ 좋아요 토글 API
각 답변마다 개별적으로 좋아요 토글 가능:

```
PUT /api/answers/a001/like  # 학사팀 답변
PUT /api/answers/a002/like  # 김학생 답변  
PUT /api/answers/a003/like  # 박학생 답변
```

## 🧪 테스트 시나리오

### 시나리오 1: a001 답변 좋아요 토글
```bash
# 첫 번째 호출 - 좋아요 추가
curl -X PUT http://localhost:3001/api/answers/a001/like \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer test-token"

# 예상 결과:
# {
#   "id": "a001",
#   "isLiked": true,
#   "likeCount": 26,
#   "action": "liked",
#   "message": "좋아요를 추가했습니다."
# }

# 두 번째 호출 - 좋아요 취소
curl -X PUT http://localhost:3001/api/answers/a001/like \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer test-token"

# 예상 결과:
# {
#   "id": "a001", 
#   "isLiked": false,
#   "likeCount": 25,
#   "action": "unliked",
#   "message": "좋아요를 취소했습니다."
# }
```

### 시나리오 2: a002 답변 좋아요 토글
```bash
# 첫 번째 호출 - 좋아요 추가 (12 → 13)
curl -X PUT http://localhost:3001/api/answers/a002/like \
  -H "Content-Type: application/json"

# 두 번째 호출 - 좋아요 취소 (13 → 12)
curl -X PUT http://localhost:3001/api/answers/a002/like \
  -H "Content-Type: application/json"
```

### 시나리오 3: a003 답변 좋아요 토글
```bash
# 첫 번째 호출 - 좋아요 추가 (8 → 9)
curl -X PUT http://localhost:3001/api/answers/a003/like \
  -H "Content-Type: application/json"

# 두 번째 호출 - 좋아요 취소 (9 → 8)
curl -X PUT http://localhost:3001/api/answers/a003/like \
  -H "Content-Type: application/json"
```

## 📊 테스트 데이터 상세

### 답변 a001 (학사팀)
- **초기 상태**: `isLiked: false, likeCount: 25`
- **좋아요 후**: `isLiked: true, likeCount: 26`
- **취소 후**: `isLiked: false, likeCount: 25`
- **특징**: 채택된 답변, 높은 사용자 레벨(5)

### 답변 a002 (김학생)
- **초기 상태**: `isLiked: true, likeCount: 12`
- **좋아요 후**: `isLiked: true, likeCount: 13`
- **취소 후**: `isLiked: false, likeCount: 12`
- **특징**: 일반 학생 답변, 사용자 레벨(2)

### 답변 a003 (박학생)
- **초기 상태**: `isLiked: false, likeCount: 8`
- **좋아요 후**: `isLiked: true, likeCount: 9`
- **취소 후**: `isLiked: false, likeCount: 8`
- **특징**: 중급 사용자, 사용자 레벨(3)

## 🔧 핵심 설정 포인트

### SEQUENTIAL 모드 설정
```json
{
  "responseMode": "SEQUENTIAL",
  "responses": [
    {
      "uuid": "like-added",
      "default": true,     // ✅ 첫 번째 응답은 true
      "body": "{ 좋아요 추가 응답 }"
    },
    {
      "uuid": "like-removed", 
      "default": false,    // ✅ 두 번째 응답은 false
      "body": "{ 좋아요 취소 응답 }"
    }
  ]
}
```

### 응답 데이터 구조
모든 좋아요 응답에 포함되는 필드:
- `id`: 답변 ID
- `questionId`: 질문 ID  
- `content`: 답변 내용
- `userId`, `userName`: 작성자 정보
- `createdAt`: 작성 시간
- `isAccepted`: 채택 여부
- `isLiked`: 좋아요 상태 ⭐
- `likeCount`: 좋아요 수 ⭐
- `action`: "liked" 또는 "unliked" ⭐
- `message`: 사용자 피드백 메시지 ⭐

## 🧪 Flutter 앱 테스트

### 1. 답변 목록 로드
```dart
// q001 질문의 답변 목록 조회
await _apiService.getAnswersByQuestionId('q001');
```

### 2. 좋아요 버튼 클릭 테스트
```dart
// 각 답변의 하트 아이콘 클릭
await _apiService.toggleAnswerLike('a001');
await _apiService.toggleAnswerLike('a002'); 
await _apiService.toggleAnswerLike('a003');
```

### 3. 확인사항
- [ ] 하트 아이콘 상태 변경 (채워짐 ↔ 비워짐)
- [ ] 좋아요 수 실시간 업데이트
- [ ] 애니메이션 효과 작동
- [ ] 연속 클릭 시 토글 동작
- [ ] 네트워크 오류 처리

## 🐛 트러블슈팅

### 토글이 작동하지 않는 경우
1. **서버 재시작**: 설정 변경 후 Mockoon 재시작 필요
2. **응답 순서 확인**: 첫 번째 응답이 `default: true`인지 확인
3. **SEQUENTIAL 모드**: `responseMode: "SEQUENTIAL"` 설정 확인

### 네트워크 오류
```bash
# 서버 상태 확인
curl http://localhost:3001/api/questions/q001/answers

# CORS 헤더 확인 
curl -v http://localhost:3001/api/answers/a001/like
```

## 📈 확장 가능한 설정

이 설정을 기반으로 추가할 수 있는 기능:
- 더 많은 답변 데이터
- 다른 질문의 답변들
- 답변 채택 API
- 답변 작성 API
- 사용자별 좋아요 이력

## 🎯 성공 기준

✅ **테스트 완료 체크리스트**
- [ ] 각 답변의 좋아요 토글 정상 작동
- [ ] 좋아요 수 정확한 증감
- [ ] UI 상태 즉시 반영
- [ ] 연속 클릭 시 올바른 토글
- [ ] 네트워크 오류 시 적절한 처리
- [ ] 애니메이션 효과 정상 작동

이제 완벽한 좋아요 토글 기능을 테스트할 수 있습니다! 🎉 