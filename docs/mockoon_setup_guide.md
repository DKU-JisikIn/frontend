# Mockoon 설정 가이드

## 1. Mockoon 설치

### 1.1 Desktop 앱 설치
- [Mockoon 공식 사이트](https://mockoon.com/download/)에서 다운로드
- Windows/macOS/Linux 지원

### 1.2 CLI 설치 (선택사항)
```bash
npm install -g @mockoon/cli
```

## 2. 기본 설정

### 2.1 새 환경 생성
1. Mockoon 앱 실행
2. "New environment" 클릭
3. 환경 이름: `단비 API`
4. 포트: `3001`
5. Base URL: `http://localhost:3001`

### 2.2 기본 설정
- **Environment name**: 단비 API
- **Port**: 3001
- **Prefix**: `/api`
- **CORS**: 활성화 (모든 origin 허용)

## 3. API 엔드포인트 설정

### 3.1 인증 관련 API

#### 로그인 - POST /api/auth/login
```json
{
  "route": "/auth/login",
  "method": "POST",
  "status": 200,
  "response": {
    "success": true,
    "message": "로그인 성공",
    "token": "jwt_token_example_123456",
    "user": {
      "id": "user_001",
      "email": "student@dankook.ac.kr",
      "name": "김단국",
      "nickname": "단국이",
      "profileImageUrl": "",
      "department": "컴퓨터공학과",
      "studentId": "2020****",
      "isVerified": true,
      "userLevel": 3
    }
  }
}
```

#### 로그아웃 - POST /api/auth/logout
```json
{
  "route": "/auth/logout",
  "method": "POST",
  "status": 200,
  "response": {
    "success": true,
    "message": "로그아웃 완료"
  }
}
```

#### 이메일 인증 코드 전송 - POST /api/auth/send-verification
```json
{
  "route": "/auth/send-verification",
  "method": "POST",
  "status": 200,
  "response": {
    "success": true,
    "message": "인증번호가 이메일로 전송되었습니다."
  }
}
```

#### 이메일 인증 - POST /api/auth/verify-email
```json
{
  "route": "/auth/verify-email",
  "method": "POST",
  "status": 200,
  "response": {
    "success": true,
    "message": "이메일 인증이 완료되었습니다."
  }
}
```

#### 회원가입 - POST /api/auth/register
```json
{
  "route": "/auth/register",
  "method": "POST",
  "status": 201,
  "response": {
    "success": true,
    "message": "회원가입이 완료되었습니다.",
    "user": {
      "id": "user_new_001",
      "email": "newuser@dankook.ac.kr",
      "name": "새사용자",
      "nickname": "신입생"
    }
  }
}
```

### 3.2 질문 관련 API

#### 질문 목록 조회 - GET /api/questions
```json
{
  "route": "/questions",
  "method": "GET",
  "status": 200,
  "response": {
    "questions": [
      {
        "id": "q001",
        "title": "2024년 1학기 수강신청 일정이 언제인가요?",
        "content": "수강신청 일정을 알고 싶습니다.",
        "userId": "admin",
        "userName": "학사팀",
        "createdAt": "2024-01-15T09:00:00Z",
        "category": "학사",
        "isOfficial": true,
        "viewCount": 150,
        "answerCount": 1,
        "tags": ["수강신청", "일정", "학사"]
      }
    ]
  }
}
```

#### 특정 질문 조회 - GET /api/questions/{id}
```json
{
  "route": "/questions/:id",
  "method": "GET",
  "status": 200,
  "response": {
    "id": "q001",
    "title": "2024년 1학기 수강신청 일정이 언제인가요?",
    "content": "수강신청 일정을 알고 싶습니다.",
    "userId": "admin",
    "userName": "학사팀",
    "createdAt": "2024-01-15T09:00:00Z",
    "updatedAt": "2024-01-15T09:00:00Z",
    "category": "학사",
    "isOfficial": true,
    "viewCount": 150,
    "answerCount": 1,
    "tags": ["수강신청", "일정", "학사"]
  }
}
```

#### 새 질문 작성 - POST /api/questions
```json
{
  "route": "/questions",
  "method": "POST",
  "status": 201,
  "response": {
    "id": "q_new_001",
    "title": "새로운 질문 제목",
    "content": "새로운 질문 내용",
    "userId": "user_001",
    "userName": "학생",
    "createdAt": "2024-01-20T10:00:00Z",
    "category": "기타",
    "isOfficial": false,
    "viewCount": 0,
    "answerCount": 0,
    "tags": []
  }
}
```

#### 인기 질문 - GET /api/questions/popular
```json
{
  "route": "/questions/popular",
  "method": "GET",
  "status": 200,
  "response": {
    "questions": [
      {
        "id": "q002",
        "title": "도서관 이용시간이 어떻게 되나요?",
        "content": "중앙도서관 평일/주말 이용시간을 알고 싶습니다.",
        "userId": "admin",
        "userName": "도서관",
        "createdAt": "2024-01-19T14:00:00Z",
        "category": "기타",
        "isOfficial": true,
        "viewCount": 234,
        "answerCount": 1,
        "tags": ["도서관", "이용시간"]
      }
    ]
  }
}
```

### 3.3 답변 관련 API

#### 특정 질문의 답변 목록 - GET /api/questions/{id}/answers
```json
{
  "route": "/questions/:id/answers",
  "method": "GET",
  "status": 200,
  "response": {
    "answers": [
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
        "userLevel": 5
      }
    ]
  }
}
```

#### 새 답변 작성 - POST /api/answers
```json
{
  "route": "/answers",
  "method": "POST",
  "status": 201,
  "response": {
    "id": "a_new_001",
    "questionId": "q001",
    "content": "새로운 답변 내용",
    "userId": "user_001",
    "userName": "학생",
    "createdAt": "2024-01-20T15:00:00Z",
    "isAccepted": false,
    "isLiked": false,
    "likeCount": 0,
    "userLevel": 2
  }
}
```

#### 답변 채택 - PUT /api/answers/{id}/accept
```json
{
  "route": "/answers/:id/accept",
  "method": "PUT",
  "status": 200,
  "response": {
    "id": "a001",
    "questionId": "q001",
    "content": "답변 내용",
    "userId": "user_001",
    "userName": "학생",
    "createdAt": "2024-01-16T10:00:00Z",
    "isAccepted": true,
    "isLiked": false,
    "likeCount": 25,
    "userLevel": 3
  }
}
```

#### 답변 좋아요 - PUT /api/answers/{id}/like
```json
{
  "route": "/answers/:id/like",
  "method": "PUT",
  "status": 200,
  "response": {
    "id": "a001",
    "questionId": "q001",
    "content": "답변 내용",
    "userId": "user_001",
    "userName": "학생",
    "createdAt": "2024-01-16T10:00:00Z",
    "isAccepted": false,
    "isLiked": true,
    "likeCount": 26,
    "userLevel": 3
  }
}
```

### 3.4 통계 관련 API

#### 오늘의 질문 수 - GET /api/statistics/today/questions
```json
{
  "route": "/statistics/today/questions",
  "method": "GET",
  "status": 200,
  "response": {
    "count": 5
  }
}
```

#### 오늘의 답변 수 - GET /api/statistics/today/answers
```json
{
  "route": "/statistics/today/answers",
  "method": "GET",
  "status": 200,
  "response": {
    "count": 12
  }
}
```

#### 전체 답변 수 - GET /api/statistics/total/answers
```json
{
  "route": "/statistics/total/answers",
  "method": "GET",
  "status": 200,
  "response": {
    "count": 1547
  }
}
```

#### 우수 답변자 - GET /api/statistics/top-answerers
```json
{
  "route": "/statistics/top-answerers",
  "method": "GET",
  "status": 200,
  "response": {
    "topAnswerers": [
      {
        "id": "user_top1",
        "userName": "김단국",
        "profileImageUrl": "",
        "score": 128,
        "rank": 1,
        "answerCount": 42,
        "likeCount": 85
      },
      {
        "id": "user_top2",
        "userName": "박대학",
        "profileImageUrl": "",
        "score": 105,
        "rank": 2,
        "answerCount": 35,
        "likeCount": 70
      }
    ]
  }
}
```

### 3.5 채팅 관련 API

#### 채팅 메시지 처리 - POST /api/chat/process
```json
{
  "route": "/chat/process",
  "method": "POST",
  "status": 200,
  "response": {
    "response": "안녕하세요! 무엇을 도와드릴까요?",
    "metadata": {
      "type": "general_response",
      "timestamp": "2024-01-20T16:00:00Z"
    }
  }
}
```

#### 채팅에서 질문 생성 - POST /api/questions/from-chat
```json
{
  "route": "/questions/from-chat",
  "method": "POST",
  "status": 201,
  "response": {
    "id": "q_chat_001",
    "title": "채팅에서 생성된 질문",
    "content": "채팅 대화를 기반으로 생성된 질문 내용",
    "userId": "user_001",
    "userName": "학생",
    "createdAt": "2024-01-20T16:30:00Z",
    "category": "기타",
    "isOfficial": false,
    "viewCount": 0,
    "answerCount": 0,
    "tags": []
  }
}
```

## 4. 실행 및 테스트

### 4.1 Mockoon 서버 실행
1. Mockoon 앱에서 환경 선택
2. "Start" 버튼 클릭
3. `http://localhost:3001` 서버 실행 확인

### 4.2 Flutter 앱 테스트
1. Flutter 앱 실행
2. 로그인 화면에서 테스트 계정 사용:
   - **이메일**: test@dankook.ac.kr
   - **비밀번호**: password123
3. 각 기능별 API 호출 테스트

### 4.3 API 테스트 도구
#### Postman/Insomnia로 직접 테스트
```bash
# 로그인 테스트
POST http://localhost:3001/api/auth/login
Content-Type: application/json

{
  "email": "test@dankook.ac.kr",
  "password": "password123"
}
```

#### cURL로 테스트
```bash
# 질문 목록 조회
curl -X GET http://localhost:3001/api/questions \
  -H "Content-Type: application/json"

# 새 질문 작성
curl -X POST http://localhost:3001/api/questions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your_token_here" \
  -d '{
    "title": "테스트 질문",
    "content": "테스트 질문 내용",
    "category": "기타"
  }'
```

## 5. 주의사항

### 5.1 CORS 설정
- Mockoon에서 CORS 활성화 필수
- Headers에 다음 추가:
  ```
  Access-Control-Allow-Origin: *
  Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
  Access-Control-Allow-Headers: Content-Type, Authorization
  ```

### 5.2 데이터 형식
- 모든 날짜는 ISO 8601 형식 (`2024-01-01T00:00:00Z`)
- JSON 응답 형식 일관성 유지
- 에러 응답도 동일한 구조로 설정

### 5.3 테스트 계정
- **test@dankook.ac.kr**: 프론트엔드에서 로컬 처리
- **다른 계정**: Mockoon API 호출
- **인증번호**: `1234` (테스트용)

## 6. 트러블슈팅

### 6.1 연결 오류
- Mockoon 서버 실행 상태 확인
- 포트 3001 사용 가능 여부 확인
- 방화벽 설정 확인

### 6.2 CORS 오류
- Mockoon에서 CORS 설정 확인
- 프록시 설정 필요 시 flutter 개발 서버 설정

### 6.3 API 응답 오류
- JSON 형식 검증
- 필수 필드 누락 확인
- 상태 코드 일치 확인

## 7. 다음 단계

1. **기본 API 테스트** 완료 후
2. **실제 백엔드 개발** 시작
3. **데이터베이스 연동**
4. **JWT 토큰 인증** 구현
5. **파일 업로드** 기능 추가
6. **실시간 기능** (WebSocket) 추가

---

이 가이드를 따라 설정하면 Flutter 앱의 모든 API 기능을 Mockoon으로 테스트할 수 있습니다! 🚀 