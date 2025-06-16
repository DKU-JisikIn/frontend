### 인증

#### 로그인 - POST /auth/login

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
    "token": {
      "accessToken": "JWT access token", // user가 API 요청시 사용 (short-lived)
      "refreshToken": "JWT refresh token", // access token 재발급시 사용 (long-lived)
    }
    "user": {
      "id": 1,
      "email": "example@dankook.ac.kr",
      "nickname": "example",
      "profileImageUrl": "", // 프로필 사진
      "department": "컴퓨터공학과",
      "isVerified": true, // 소속 인증
      "userLevel": 1,
      "userEXP": 0
    }
  }
}
```

#### 로그아웃 - POST /auth/logout
```json
{
  "refreshToken": "JWT refresh token"
}
```
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

#### 이메일 인증 코드 전송 - POST /auth/send-verification
```json
{
  "email": "example@dankook.ac.kr"
}
```
```json
{
  "route": "/auth/send-verification",
  "method": "POST",
  "status": 200,
  "response": {
    "requestId": 1 // 추가
    "email" : "example@dankook.ac.kr",
    "code" : "1234" // 실제 배포 때는 "****" 으로 hide
  }
}
```

#### 이메일 인증 - POST /auth/verify-email
```json
{
  "requestId": 1 // 위에서 추가된 정보
  "email" : "example@dankook.ac.kr",
  "code" : "1234"
}
```
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

#### 회원가입 - POST /auth/register

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
      "id" : 1, // id 추가 | userId
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
#### 질문 목록 조회(전체 질문 페이지) - GET /questions
```json
No json body - just the Bearer header w/ access token.
```
```json
{
  "route": "/questions",
  "method": "GET",
  "status": 200,
  "response": {
    "questions": [
      {
        "id": 1,
        "userId" : 1, // 새로 추가
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

#### 특정 질문 조회(상세 페이지 | 질문 카드) - GET /questions/:id
```json
No json body - just the Bearer header w/ access token.
```
```json
{
  "route": "/questions/:id", 
  "method": "GET",
  "status": 200,
  "response": {
    "id": 1,
    "userId" : 1, // 새로 추가
    "title": "2024년 1학기 수강신청 일정이 언제인가요?",
    "content": "수강신청 일정을 알고 싶습니다.",
    "createdAt": "2024-01-15T09:00:00Z",
    "category": "학사",
    "viewCount": 150,
    "answerCount": 1
  }
}
```

#### 채팅에서 새 질문 작성 (해당 질문 자체가 없을 때) - POST /questions
```json
{
  "title": "새로운 질문 제목", // 없으면 AI가 자동 생성
  "content": "새로운 질문 내용",
  "category": "질문 카테고리" // 없으면 AI가 자동 생성
}
```
```json
{
  "route": "/questions",
  "method": "POST",
  "status": 201,
  "response": {
    "id": 1,
    "userId" : 1, // 새로 추가
    "title": "새로운 질문 제목", // content 요약으로 생성
    "content": "새로운 질문 내용", // 질문 채팅
    "createdAt": "2024-01-20T10:00:00Z",
    "category": "학사", // 질문 내용으로 자동 판단
    "viewCount": 0,
    "answerCount": 0
  }
}
```

#### 인기 질문 - GET /questions/popular (인기 질문 10개)
```json
No json body - just the Bearer header w/ access token.
```
```json
{
  "route": "/questions/popular",
  "method": "GET",
  "status": 200,
  "response": {
    "questions": [
      {
        "id": 1,
        "userId" : 1,
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

#### 답변받지 못한 질문 (answerCount = 0) - GET /questions/unanswered
```json
No json body - just the Bearer header w/ access token.
```
```json
{
  "route": "/questions/unanswered",
  "method": "GET", 
  "status": 200,
  "response": {
    "questions": [
      {
        "id": 1,
        "userId" : 1,
        "title": "캠퍼스 내 자전거 주차장 위치가 궁금해요",
        "content": "자전거를 세울 수 있는 곳이 어디인지 알고 싶습니다.",
        "createdAt": "2024-01-21T13:45:00Z",
        "viewCount": 23,
        "answerCount": 0,
      },
      {
        "id": 2,
        "userId" : 3,
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

### 답변
#### 특정 질문의 답변 목록 (질문 상세 페이지 답변 목록) - GET /questions/:id/answers
```json
No json body - just the Bearer header w/ access token.
```
```json
{
  "route": "/questions/:id/answers",
  "method": "GET",
  "status": 200,
  "response": {
    "answers": [
      {
        "id": 1,
        "questionId": 1,
        "userId" : 1,
        "content": "2024년 1학기 수강신청은 2월 5일부터 시작됩니다.\n자세한 일정은 학사공지를 확인해주세요.",
        "nickname": "학사팀",
        "createdAt": "2024-01-16T10:00:00Z",
        "isAccepted": true,
        "department": "학사처",
        "isVerified": true
      }
    ]
  }
}
```

#### 새 답변 작성 - POST /questions/:id/answers
```json
{
  "content": "답변 내용"
}
```
```json
{
  "route": "/questions/:id/answers",
  "method": "POST",
  "status": 201,
  "response": {
    "id": 1,
    "questionId": 1,
    "userId" : 1,
    "content": "새로운 답변 내용",
    "nickname": "학생",
    "createdAt": "2024-01-20T15:00:00Z",
    "department": "학사처",
    "isAccepted": false,
  }
}
```

#### 답변 채택 - PUT /questions:id/answers/:id/accept
```json
No json body - just the Bearer header w/ access token.
```
```json
{
  "route": "/answers/:id/accept",
  "method": "PUT",
  "status": 200,
  "response": {
    "id": 1,
    "questionId": 1,
    "content": "답변 내용",
    "nickname": "학생",
    "createdAt": "2024-01-16T10:00:00Z",
    "isAccepted": true,
    "department": "학사처",
    "userLevel": 3
  }
}
```

### 통계

#### 오늘의 질문 수 - GET /statistics/today/questions
```json
No json body - just the Bearer header w/ access token.
```
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

#### 오늘의 답변 수 - GET /statistics/today/answers
```json
No json body - just the Bearer header w/ access token.
```
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

#### 전체 답변 수 - GET /statistics/total/answers
```json
No json body - just the Bearer header w/ access token.
```
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

// 우수 답변자 보류

### 채팅 // 아직 구현 X

#### 채팅 메시지 처리 (답변) - GET /chat/process

**시나리오 1: 수강신청 관련 답변 (답변 존재 질문)**
```json
{
  "route": "/chat/process",
  "method": "GET",
  "status": 200,
  "response": {
    "response": {
      "answers": [
        {
            "answer" : "답변1"
        },
        {
            "answer" : "답변2"
        }
      ]
    },
    "relatedQuestions": [
      {
        "id": 1,
        "title": "수강신청 시스템 사용법",
        "content" : "내용1"
      },
      {
        "id": 2,
        "title": "수강신청 변경 및 취소 방법",
        "content" : "내용2"
      }
    ],
    "actions": {
      "canCreateQuestion": false,
      "hasDirectAnswer": true
    },
  }
}
```

**시나리오 2: 새로운 질문 (기존 답변 없음)**
```json
{
  "route": "/chat/process",
  "method": "POST", 
  "status": 200,
  "response": {
    "response": {
      "answer": "죄송합니다. 해당 질문에 대한 정확한 정보를 찾지 못했습니다. 질문을 등록하시면 다른 학생들이나 관리자가 답변해드릴 수 있습니다.",
    },
    "actions": {
      "canCreateQuestion": true,
      "hasDirectAnswer": false
    }
  }
}
```

**시나리오 3: 일반적인 인사 또는 모호한 질문**
```json
{
  "route": "/chat/process", 
  "method": "POST",
  "status": 200,
  "response": {
    "response": {
      "answer": "안녕하세요! 단국대학교 학생 질문 도우미입니다. 학사, 장학금, 교내프로그램, 취업 등 다양한 주제에 대해 질문해주세요.",
    },
    "actions": {
      "canCreateQuestion": false,
      "hasDirectAnswer": true
    }
  }
}
```

**요청**
```json
{
  "message": "수강신청은 언제 시작하나요?",
  "context": {
    "userId": 1,
    "sessionId": 1,
    "previousMessages": [
      {
        "role": "user",
        "content": "안녕하세요"
      },
      {
        "role": "assistant",
        "content": "안녕하세요! 무엇을 도와드릴까요?"
      }
    ]
  }
}
```

### 내 정보

#### 프로필 수정 - PATCH /users/edit-profile
```json
{
    "nickname" : "new_nickname",
    "profileImageUrl" : ""
}
```
```json
{
    // 서비스 측에서 확인 후 PATCH
    "route": "/auth/verify-department",
    "method": "PATCH",
    "status": 200,
    "response": {
      "nickname" : "new_nickname",
      "profileImageUrl" : ""
    }
}
```

**비밀번호 변경 제외**

#### 소속 인증하기 - PATCH /auth/verify-department
```json
{
    "email": "",
    "department": ""
}
```
```json
{
    // 서비스 측에서 확인 후 PATCH
    "route": "/auth/verify-department",
    "method": "PATCH",
    "status": 200,
    "response": {
      "department": "",
      "isVerified": true
    }
}
```

#### 회원탈퇴 - DELETE /auth/delete-account
```json
No json body - just the Bearer header w/ access token.
```
```json
{
    "route": "/auth/delete-account",
    "method": "DELETE",
    "status": 200,
    "response": {
      "id": 1,
      "email": ""
    }
}