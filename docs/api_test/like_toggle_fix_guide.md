# 좋아요 토글 기능 수정 가이드

## 🚨 문제 상황
좋아요 버튼을 눌러도 취소되지 않고 계속 좋아요 상태로 유지되는 문제

## 🔧 해결 방법

### 1. Mockoon 설정 수정
`docs/api_test/complete_test_environment.json` 파일에서 좋아요 API의 default 설정을 변경했습니다:

**변경 전:**
```json
{
  "uuid": "like-added", 
  "default": false  // ❌ 문제 원인
},
{
  "uuid": "like-removed",
  "default": true   // ❌ 문제 원인  
}
```

**변경 후:**
```json
{
  "uuid": "like-added",
  "default": true   // ✅ 수정됨
},
{
  "uuid": "like-removed", 
  "default": false  // ✅ 수정됨
}
```

### 2. Mockoon 서버 재시작 필요

```bash
# 1. 기존 서버 종료
pkill -f mockoon

# 2. 새로운 설정으로 재시작  
mockoon-cli start --data docs/api_test/complete_test_environment.json --port 3001
```

### 3. 테스트 방법

```bash
# 첫 번째 호출 (좋아요 추가)
curl -X PUT http://localhost:3001/api/answers/a001/like \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer test-token"

# 예상 결과: isLiked: true, likeCount: 26

# 두 번째 호출 (좋아요 취소)
curl -X PUT http://localhost:3001/api/answers/a001/like \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer test-token"

# 예상 결과: isLiked: false, likeCount: 25
```

## 🎯 SEQUENTIAL 모드 작동 원리

Mockoon의 SEQUENTIAL 모드에서는:
1. **첫 번째 응답**이 `default: true`여야 시작점이 됨
2. 호출할 때마다 다음 응답으로 순환
3. 마지막 응답 후 다시 첫 번째로 돌아감

**올바른 순서:**
1. 첫 호출 → "좋아요 추가" (`default: true`)
2. 둘째 호출 → "좋아요 취소" (`default: false`) 
3. 셋째 호출 → 다시 "좋아요 추가"

## ✅ 확인사항

- [ ] `complete_test_environment.json` 파일 수정 완료
- [ ] Mockoon 서버 재시작 완료
- [ ] cURL 테스트에서 토글 동작 확인
- [ ] Flutter 앱에서 하트 아이콘 토글 확인

이제 좋아요 기능이 정상적으로 작동할 것입니다! 🎉 