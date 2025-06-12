# 좋아요 API 테스트 가이드

## API 엔드포인트
- **URL**: `PUT /api/answers/:id/like`
- **포트**: 3001
- **예시**: `PUT http://localhost:3001/api/answers/a001/like`

## Mockoon 설정 확인
1. `complete_test_environment.json` 환경이 로드되어 있는지 확인
2. 포트 3001에서 서버가 실행 중인지 확인
3. 좋아요 API가 SEQUENTIAL 모드로 설정되어 있는지 확인

## 응답 구조

### 첫 번째 호출 (좋아요 추가)
```json
{
  "id": "a001",
  "questionId": "q001",
  "content": "2024년 1학기 수강신청은 2월 5일부터 시작됩니다.\n자세한 일정은 학사공지를 확인해주세요.",
  "userId": "admin",
  "userName": "학사팀",
  "createdAt": "2024-01-16T10:00:00Z",
  "isAccepted": true,
  "isLiked": true,
  "likeCount": 26,
  "department": "학사처",
  "isVerified": true,
  "userLevel": 5,
  "action": "liked",
  "message": "좋아요를 추가했습니다."
}
```

### 두 번째 호출 (좋아요 취소)
```json
{
  "id": "a001",
  "questionId": "q001",
  "content": "2024년 1학기 수강신청은 2월 5일부터 시작됩니다.\n자세한 일정은 학사공지를 확인해주세요.",
  "userId": "admin",
  "userName": "학사팀",
  "createdAt": "2024-01-16T10:00:00Z",
  "isAccepted": true,
  "isLiked": false,
  "likeCount": 25,
  "department": "학사처",
  "isVerified": true,
  "userLevel": 5,
  "action": "unliked",
  "message": "좋아요를 취소했습니다."
}
```

## 터미널 테스트

### 좋아요 추가 테스트
```bash
curl -X PUT http://localhost:3001/api/answers/a001/like \
  -H "Content-Type: application/json" \
  -H "Accept: application/json"
```

### 좋아요 취소 테스트 (두 번째 호출)
```bash
curl -X PUT http://localhost:3001/api/answers/a001/like \
  -H "Content-Type: application/json" \
  -H "Accept: application/json"
```

## Flutter 앱에서 테스트

1. **질문 상세 페이지로 이동**
2. **답변의 좋아요 버튼 클릭**
3. **콘솔 로그 확인**:
   - `좋아요 API 호출: PUT http://localhost:3001/api/answers/a001/like`
   - `좋아요 API 응답 상태: 200`
   - `좋아요 API 응답 본문: {...}`
   - `좋아요 API 파싱된 데이터: {...}`

## 예상 동작

1. **첫 번째 클릭**: 
   - `isLiked: false` → `isLiked: true`
   - `likeCount: 25` → `likeCount: 26`
   - 하트 아이콘이 채워짐

2. **두 번째 클릭**:
   - `isLiked: true` → `isLiked: false`
   - `likeCount: 26` → `likeCount: 25`
   - 하트 아이콘이 비워짐

## 문제 해결

### 1. "type 'Null' is not a subtype of type 'String'" 오류
- **원인**: API 응답에서 필수 필드가 null
- **해결**: 디버깅 로그를 확인하여 실제 응답 구조 파악

### 2. 404 오류
- **원인**: Mockoon에서 올바른 환경이 로드되지 않음
- **해결**: `complete_test_environment.json` 환경 재로드

### 3. CORS 오류
- **원인**: CORS 설정 문제
- **해결**: Mockoon 환경에서 CORS가 활성화되어 있는지 확인

## 디버깅 팁

1. **콘솔 로그 확인**: Flutter 앱 실행 시 콘솔에서 API 호출 로그 확인
2. **Mockoon 로그**: Mockoon에서 요청이 들어오는지 확인
3. **네트워크 탭**: 브라우저 개발자 도구에서 실제 요청/응답 확인

## 테스트 시나리오

1. **기본 좋아요 토글**:
   - 좋아요 → 좋아요 취소 → 좋아요 반복

2. **여러 답변 좋아요**:
   - 다른 답변 ID로 테스트 (a002 등)

3. **연속 클릭 테스트**:
   - 빠르게 여러 번 클릭하여 상태 동기화 확인 