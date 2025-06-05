import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Base URL (API 서비스와 동일)
  static const String baseUrl = 'http://localhost:3001/api';

  // 현재 로그인 상태
  bool _isLoggedIn = false;
  String? _currentUserEmail;
  String? _currentUserName;
  String? _currentUserNickname;
  String? _currentUserProfileImageUrl;
  String? _authToken;

  // 상태 변경 스트림
  final StreamController<bool> _authStateController = StreamController<bool>.broadcast();
  Stream<bool> get authStateStream => _authStateController.stream;

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  String? get currentUserEmail => _currentUserEmail;
  String? get currentUserName => _currentUserName;
  String? get currentUserNickname => _currentUserNickname;
  String? get currentUserProfileImageUrl => _currentUserProfileImageUrl;
  String? get authToken => _authToken;

  // HTTP 헤더 설정
  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Map<String, String> get authHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  // 로그인
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // 테스트 계정은 로컬에서 처리
      if (email == 'test@dankook.ac.kr' && password == 'password123') {
        _isLoggedIn = true;
        _currentUserEmail = email;
        _currentUserName = 'Test User';
        _currentUserNickname = '테스트사용자';
        _currentUserProfileImageUrl = null;
        _authToken = 'test_token_123'; // 테스트용 토큰
        _authStateController.add(true);
        
        return {
          'success': true,
          'message': '로그인 성공',
          'token': _authToken,
          'user': {
            'id': 'test',
            'email': _currentUserEmail,
            'name': _currentUserName,
            'nickname': _currentUserNickname,
            'profileImageUrl': _currentUserProfileImageUrl,
          }
        };
      }

      // 실제 API 호출
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: headers,
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          _isLoggedIn = true;
          _authToken = data['token'];
          _currentUserEmail = data['user']['email'];
          _currentUserName = data['user']['name'];
          _currentUserNickname = data['user']['nickname'];
          _currentUserProfileImageUrl = data['user']['profileImageUrl'];
          _authStateController.add(true);
          
          return {
            'success': true,
            'message': data['message'] ?? '로그인 성공',
            'token': _authToken,
            'user': data['user'],
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? '로그인에 실패했습니다.',
          };
        }
      } else {
        return {
          'success': false,
          'message': '서버 오류가 발생했습니다. (${response.statusCode})',
        };
      }
    } catch (e) {
      print('로그인 API 호출 오류: $e');
      return {
        'success': false,
        'message': 'API 연결에 문제가 있습니다. Mockoon 서버가 실행 중인지 확인해주세요.',
      };
    }
  }

  // 로그아웃
  Future<void> logout() async {
    try {
      // 테스트 계정이 아닌 경우에만 API 호출
      if (_authToken != null && _authToken != 'test_token_123') {
        await http.post(
          Uri.parse('$baseUrl/auth/logout'),
          headers: authHeaders,
        );
      }
      
      _isLoggedIn = false;
      _currentUserEmail = null;
      _currentUserName = null;
      _currentUserNickname = null;
      _currentUserProfileImageUrl = null;
      _authToken = null;
      _authStateController.add(false);
    } catch (e) {
      print('로그아웃 중 오류: $e');
      // 로컬 상태는 초기화
      _isLoggedIn = false;
      _currentUserEmail = null;
      _currentUserName = null;
      _currentUserNickname = null;
      _currentUserProfileImageUrl = null;
      _authToken = null;
      _authStateController.add(false);
    }
  }

  // 이메일 인증 코드 전송
  Future<Map<String, dynamic>> sendVerificationCode(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-verification'),
        headers: headers,
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['success'] ?? true,
          'message': data['message'] ?? '인증번호가 이메일로 전송되었습니다.',
        };
      } else {
        return {
          'success': false,
          'message': '인증번호 전송에 실패했습니다. (${response.statusCode})',
        };
      }
    } catch (e) {
      print('인증번호 전송 API 호출 오류: $e');
      return {
        'success': false,
        'message': 'API 연결에 문제가 있습니다. Mockoon 서버가 실행 중인지 확인해주세요.',
      };
    }
  }

  // 이메일 인증 코드 확인
  Future<Map<String, dynamic>> verifyEmail(String email, String code) async {
    try {
      // 테스트용 인증번호는 로컬에서 처리
      if (code == '1234') {
        return {
          'success': true,
          'message': '이메일 인증이 완료되었습니다.',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-email'),
        headers: headers,
        body: json.encode({
          'email': email,
          'code': code,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['success'] ?? true,
          'message': data['message'] ?? '이메일 인증이 완료되었습니다.',
        };
      } else {
        return {
          'success': false,
          'message': '인증번호가 올바르지 않습니다.',
        };
      }
    } catch (e) {
      print('이메일 인증 API 호출 오류: $e');
      return {
        'success': false,
        'message': 'API 연결에 문제가 있습니다. Mockoon 서버가 실행 중인지 확인해주세요.',
      };
    }
  }

  // 회원가입
  Future<Map<String, dynamic>> register(
    String email, 
    String password, {
    String? nickname,
    dynamic profileImage,
    dynamic verificationDocument,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: headers,
        body: json.encode({
          'email': email,
          'password': password,
          'nickname': nickname,
          // TODO: 파일 업로드는 multipart/form-data로 처리 필요
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': data['success'] ?? true,
          'message': data['message'] ?? '회원가입이 완료되었습니다.',
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'message': '회원가입에 실패했습니다. (${response.statusCode})',
        };
      }
    } catch (e) {
      print('회원가입 API 호출 오류: $e');
      return {
        'success': false,
        'message': 'API 연결에 문제가 있습니다. Mockoon 서버가 실행 중인지 확인해주세요.',
      };
    }
  }

  // 비밀번호 유효성 검사
  bool isValidPassword(String password) {
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