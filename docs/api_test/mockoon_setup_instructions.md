# Mockoon 환경 설정 가이드

## 문제 상황
`process_test.json` 파일이 자동으로 로드되어 채팅 API만 사용 가능한 상황

## 해결 방법

### 1. 올바른 환경 파일 사용
새로 생성된 `complete_test_environment.json` 파일을 사용하세요.

### 2. Mockoon에서 환경 변경하기

#### 방법 1: 새 환경 가져오기
1. Mockoon 실행
2. 상단 메뉴에서 **File** → **Import environment**
3. `docs/api_test/complete_test_environment.json` 선택
4. 환경이 추가되면 **Complete Test API** 환경 선택

#### 방법 2: 기존 환경 교체
1. Mockoon에서 현재 환경 삭제
2. 새 환경 파일 가져오기

### 3. 포함된 API 엔드포인트

새 환경에는 다음 API들이 포함되어 있습니다:

#### 채팅 API
- **POST** `/api/chat/process`
  - 수강신청 관련 질문: "수강신청" 키워드 포함 시
  - 기본 응답: 기타 질문들
  - 답변 없음: "알 수 없는" 키워드 포함 시

#### 답변 관련 API
- **GET** `/api/questions/:id/answers`
  - 질문의 답변 목록 조회
  - 예시: `GET /api/questions/q001/answers`

#### 좋아요 토글 API
- **PUT** `/api/answers/:id/like`
  - SEQUENTIAL 모드로 설정됨
  - 첫 번째 호출: 좋아요 추가 (isLiked: true, likeCount: 26)
  - 두 번째 호출: 좋아요 취소 (isLiked: false, likeCount: 25)
  - 예시: `PUT /api/answers/a001/like`

#### 질문 생성 API
- **POST** `/api/questions/from-chat`
  - 채팅에서 질문 생성

### 4. 테스트 방법

#### 좋아요 토글 테스트
```bash
# 첫 번째 호출 (좋아요 추가)
curl -X PUT http://localhost:3001/api/answers/a001/like

# 두 번째 호출 (좋아요 취소)
curl -X PUT http://localhost:3001/api/answers/a001/like
```

#### 답변 목록 조회
```bash
curl -X GET http://localhost:3001/api/questions/q001/answers
```

#### 채팅 테스트
```bash
curl -X POST http://localhost:3001/api/chat/process \
  -H "Content-Type: application/json" \
  -d '{"message": "수강신청 언제 시작하나요?"}'
```

### 5. 주의사항

- 포트 3001에서 실행되도록 설정됨
- CORS가 활성화되어 있어 Flutter 앱에서 접근 가능
- 좋아요 API는 SEQUENTIAL 모드로 설정되어 호출할 때마다 상태가 토글됨

### 6. 문제 해결

만약 여전히 `process_test.json`이 로드된다면:
1. Mockoon 완전 종료
2. Mockoon 재시작
3. 올바른 환경 파일 선택 확인
4. 서버 재시작

### 7. 환경 확인 방법

Mockoon에서 현재 활성화된 환경 이름이 **"Complete Test API"**인지 확인하세요. 