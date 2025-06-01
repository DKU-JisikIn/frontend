import 'dart:async';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // 현재 로그인 상태
  bool _isLoggedIn = false;
  String? _currentUserEmail;
  String? _currentUserName;
  String? _currentUserNickname;
  String? _currentUserProfileImageUrl;

  // 상태 변경 스트림
  final StreamController<bool> _authStateController = StreamController<bool>.broadcast();
  Stream<bool> get authStateStream => _authStateController.stream;

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  String? get currentUserEmail => _currentUserEmail;
  String? get currentUserName => _currentUserName;
  String? get currentUserNickname => _currentUserNickname;
  String? get currentUserProfileImageUrl => _currentUserProfileImageUrl;

  // 로그인
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // TODO: 백엔드 API 호출
      // final response = await http.post('/api/auth/login', body: {...});
      
      // 임시 로그인 로직 (실제로는 백엔드에서 검증)
      await Future.delayed(const Duration(seconds: 1)); // API 호출 시뮬레이션
      
      if (email.isEmpty || password.isEmpty) {
        return {
          'success': false,
          'message': '이메일과 비밀번호를 입력해주세요.',
        };
      }
      
      // 테스트용 계정: 아이디 test / 비밀번호 password123
      if (email == 'test@dankook.ac.kr' && password == 'password123') {
        _isLoggedIn = true;
        _currentUserEmail = email;
        _currentUserName = 'Test User';
        _currentUserNickname = '테스트사용자'; // 테스트용 닉네임
        _currentUserProfileImageUrl = null; // 기본 프로필 아이콘 사용
        _authStateController.add(true);
        
        return {
          'success': true,
          'message': '로그인 성공',
          'user': {
            'email': _currentUserEmail,
            'name': _currentUserName,
            'nickname': _currentUserNickname,
            'profileImageUrl': _currentUserProfileImageUrl,
          }
        };
      } else {
        return {
          'success': false,
          'message': '이메일 또는 비밀번호가 올바르지 않습니다.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '로그인 중 오류가 발생했습니다: $e',
      };
    }
  }

  // 로그아웃
  Future<void> logout() async {
    try {
      // TODO: 백엔드 API 호출
      // await http.post('/api/auth/logout');
      
      _isLoggedIn = false;
      _currentUserEmail = null;
      _currentUserName = null;
      _currentUserNickname = null;
      _currentUserProfileImageUrl = null;
      _authStateController.add(false);
    } catch (e) {
      print('로그아웃 중 오류: $e');
    }
  }

  // 이메일 인증 코드 전송
  Future<Map<String, dynamic>> sendVerificationCode(String email) async {
    try {
      // TODO: 백엔드 API 호출
      // final response = await http.post('/api/auth/send-verification', body: {'email': email});
      
      await Future.delayed(const Duration(seconds: 1)); // API 호출 시뮬레이션
      
      return {
        'success': true,
        'message': '인증번호가 이메일로 전송되었습니다.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': '인증번호 전송 중 오류가 발생했습니다: $e',
      };
    }
  }

  // 이메일 인증 코드 확인
  Future<Map<String, dynamic>> verifyEmail(String email, String code) async {
    try {
      // TODO: 백엔드 API 호출
      // final response = await http.post('/api/auth/verify-email', body: {'email': email, 'code': code});
      
      await Future.delayed(const Duration(seconds: 1)); // API 호출 시뮬레이션
      
      // 임시 검증 로직 (실제로는 백엔드에서 검증)
      if (code == '1234') { // 테스트용 인증번호
        return {
          'success': true,
          'message': '이메일 인증이 완료되었습니다.',
        };
      } else {
        return {
          'success': false,
          'message': '인증번호가 올바르지 않습니다.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '이메일 인증 중 오류가 발생했습니다: $e',
      };
    }
  }

  // 회원가입
  Future<Map<String, dynamic>> register(
    String email, 
    String password, {
    String? nickname,
    dynamic profileImage,  // File? for actual implementation
    dynamic verificationDocument,  // File? for actual implementation
  }) async {
    try {
      // TODO: 백엔드 API 호출
      // final response = await http.post('/api/auth/register', body: {
      //   'email': email, 
      //   'password': password,
      //   'nickname': nickname,
      //   // profileImage와 verificationDocument는 multipart/form-data로 전송
      // });
      
      await Future.delayed(const Duration(seconds: 1)); // API 호출 시뮬레이션
      
      return {
        'success': true,
        'message': '회원가입이 완료되었습니다.',
        'user': {
          'email': email,
          'nickname': nickname ?? email.split('@')[0],
        }
      };
    } catch (e) {
      return {
        'success': false,
        'message': '회원가입 중 오류가 발생했습니다: $e',
      };
    }
  }

  // 비밀번호 유효성 검사
  bool isValidPassword(String password) {
    // 최소 8자, 영문, 숫자 포함
    return password.length >= 8 && 
           password.contains(RegExp(r'[a-zA-Z]')) && 
           password.contains(RegExp(r'[0-9]'));
  }

  // 이메일 유효성 검사
  bool isValidEmail(String email) {
    return email.contains('@dankook.ac.kr') && email.length > '@dankook.ac.kr'.length;
  }

  void dispose() {
    _authStateController.close();
  }
} 