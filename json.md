### 인증

#### 로그인 - POST /api/auth/login

```json
{
  "email": "example@dankook.ac.kr",
  "password": "password123"
}
```

```json
{
  "route": "/auth/login",
  "method": "POST",
  "status": 200,
  "response": {
    "token": "jwt_token_example_123456",
    "user": {
      "id": 1,
      "email": "example@dankook.ac.kr",
      "nickname": "example",
      "profileImageUrl": "", // 프로필 사진
      "department": "컴퓨터공학과",
      "isVerified": true // 소속 인증
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
    "refreshToken": "abc123" // 토큰 삭제
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
    "email" : "example@dankook.ac.kr",
    "code" : "1234"
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
    "requestId" : 1, // 중복 방지
    "email" : "example@dankook.ac.kr",
    "code" : "1234"
  }
}
```

#### 회원가입 - POST /api/auth/register

```json
{
  "email": "example@dankook.ac.kr",
  "password": "password123",
  "nickname": "example"
}
```

```json
{
  "route": "/auth/register",
  "method": "POST",
  "status": 201,
  "response": {
    "user": {
      "email": "newuser@dankook.ac.kr",
      "nickname": "신입생닉네임",
      "profileImageUrl": "",
      "department": "",
      "isVerified": false,
      "userLevel": 1,
      "userEXP" : 0
    }
  }
}
```

**조건**
- `email`: 단국대학교 이메일 주소 (아이디@dankook.ac.kr)
- `password`: 비밀번호 (8자 이상, 영문+숫자 포함)
- `nickname`: 사용자 닉네임 (2-10자, 한글/영문/숫자)

### 질문 조회
#### 질문 목록 조회(전체 질문 페이지) - GET /api/questions
```json
{
  "route": "/questions",
  "method": "GET",
  "status": 200,
  "response": {
    "questions": [
      {
        "id": 1,
        "title": "2024년 1학기 수강신청 일정이 언제인가요?",
        "content": "수강신청 일정을 알고 싶습니다.",
        "createdAt": "2024-01-15T09:00:00Z",
        "category": "학사",
        "viewCount": 150,
        "answerCount": 1
      }
    ]
  }
}
```

#### 특정 질문 조회(상세 페이지) - GET /api/questions/:id
```json
{
  "route": "/questions/:id",
  "method": "GET",
  "status": 200,
  "response": {
    "id": 1,
    "title": "2024년 1학기 수강신청 일정이 언제인가요?",
    "content": "수강신청 일정을 알고 싶습니다.",
    "createdAt": "2024-01-15T09:00:00Z",
    "category": "학사",
    "viewCount": 150,
    "answerCount": 1
  }
}
```

#### 채팅에서 새 질문 작성 (해당 질문 자체가 없을 때) - POST /api/questions
```json
{
  "route": "/questions",
  "method": "POST",
  "status": 201,
  "response": {
    "id": 1,
    "title": "새로운 질문 제목", // content 요약으로 생성
    "content": "새로운 질문 내용", // 질문 채팅
    "createdAt": "2024-01-20T10:00:00Z",
    "category": "학사", // 질문 내용으로 자동 판단
    "viewCount": 0,
    "answerCount": 0
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
        "id": 1,
        "title": "도서관 이용시간이 어떻게 되나요?",
        "content": "중앙도서관 평일/주말 이용시간을 알고 싶습니다.",
        "createdAt": "2024-01-19T14:00:00Z",
        "category": "기타",
        "viewCount": 234,
        "answerCount": 1
      }
    ]
  }
}
```

//
// 공식 질문 , 자주 받은 질문 제외
//

#### 답변받지 못한 질문 (answerCount = 0) - GET /api/questions/unanswered

// 전체 질문에서 answerCount가 0인 것만 가져올 수 있는가?

```json
{
  "route": "/questions/unanswered",
  "method": "GET", 
  "status": 200,
  "response": {
    "questions": [
      {
        "id": 1,
        "title": "캠퍼스 내 자전거 주차장 위치가 궁금해요",
        "content": "자전거를 세울 수 있는 곳이 어디인지 알고 싶습니다.",
        "createdAt": "2024-01-21T13:45:00Z",
        "viewCount": 23,
        "answerCount": 0,
      },
      {
        "id": 2,
        "title": "졸업논문 제출 마감일이 언제인가요?",
        "content": "2024년도 전기 졸업예정자 논문 제출 마감일을 알고 싶습니다.",
        "createdAt": "2024-01-21T16:20:00Z",
        "category": "학사",
        "viewCount": 34,
        "answerCount": 0,
      }
    ]
  }
}
```
