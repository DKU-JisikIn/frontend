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
  String? _currentUserId;
  String? _currentUserEmail;
  String? _currentUserNickname;
  String? _currentUserProfileImageUrl;
  String? _currentUserDepartment;
  bool _isVerified = false;
  int _userLevel = 1;
  int _userEXP = 0;
  String? _accessToken;
  String? _refreshToken;

  // 상태 변경 스트림
  final StreamController<bool> _authStateController = StreamController<bool>.broadcast();
  Stream<bool> get authStateStream => _authStateController.stream;

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  String? get currentUserId => _currentUserId;
  String? get currentUserEmail => _currentUserEmail;
  String? get currentUserNickname => _currentUserNickname;
  String? get currentUserName => _currentUserNickname;
  String? get currentUserProfileImageUrl => _currentUserProfileImageUrl;
  String? get currentUserDepartment => _currentUserDepartment;
  bool get isVerified => _isVerified;
  int get userLevel => _userLevel;
  int get userEXP => _userEXP;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  // HTTP 헤더 설정
  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Map<String, String> get authHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

  // 로그인
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      if (email.trim().isEmpty) {
        return {
          'success': false,
          'message': '이메일을 입력해주세요.',
        };
      }

      if (password.trim().isEmpty) {
        return {
          'success': false,
          'message': '비밀번호를 입력해주세요.',
        };
      }

      if (!email.endsWith('@dankook.ac.kr')) {
        return {
          'success': false,
          'message': '단국대학교 이메일 주소를 사용해주세요.',
        };
      }

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
        final responseData = data['response'];
        
        if (responseData != null) {
          _isLoggedIn = true;
          _accessToken = responseData['token']['accessToken'];
          _refreshToken = responseData['token']['refreshToken'];
          
          final userData = responseData['user'];
          _currentUserId = userData['id'].toString();
          _currentUserEmail = userData['email'];
          _currentUserNickname = userData['nickname'];
          _currentUserProfileImageUrl = userData['profileImageUrl'];
          _currentUserDepartment = userData['department'];
          _isVerified = userData['isVerified'];
          _userLevel = userData['userLevel'];
          _userEXP = userData['userEXP'];
          
          _authStateController.add(true);
          
          return {
            'success': true,
            'message': '로그인 성공',
            'token': {
              'accessToken': _accessToken,
              'refreshToken': _refreshToken,
            },
            'user': userData,
          };
        }
      }
      
      return {
        'success': false,
        'message': '로그인에 실패했습니다.',
      };
    } catch (e) {
      print('로그인 API 호출 오류: $e');
      return {
        'success': false,
        'message': 'API 연결에 문제가 있습니다.',
      };
    }
  }

  // 로그아웃
  Future<void> logout() async {
    try {
      if (_refreshToken != null) {
        await http.post(
          Uri.parse('$baseUrl/auth/logout'),
          headers: headers,
          body: json.encode({
            'refreshToken': _refreshToken,
          }),
        );
      }
      
      _isLoggedIn = false;
      _currentUserId = null;
      _currentUserEmail = null;
      _currentUserNickname = null;
      _currentUserProfileImageUrl = null;
      _currentUserDepartment = null;
      _isVerified = false;
      _userLevel = 1;
      _userEXP = 0;
      _accessToken = null;
      _refreshToken = null;
      _authStateController.add(false);
    } catch (e) {
      print('로그아웃 중 오류: $e');
      // 로컬 상태는 초기화
      _isLoggedIn = false;
      _currentUserId = null;
      _currentUserEmail = null;
      _currentUserNickname = null;
      _currentUserProfileImageUrl = null;
      _currentUserDepartment = null;
      _isVerified = false;
      _userLevel = 1;
      _userEXP = 0;
      _accessToken = null;
      _refreshToken = null;
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
        final responseData = data['response'];
        
        return {
          'success': true,
          'requestId': responseData['requestId'],
          'email': responseData['email'],
          'code': responseData['code'],
        };
      }
      
      return {
        'success': false,
        'message': '인증번호 전송에 실패했습니다.',
      };
    } catch (e) {
      print('인증번호 전송 API 호출 오류: $e');
      return {
        'success': false,
        'message': 'API 연결에 문제가 있습니다.',
      };
    }
  }

  // 이메일 인증 코드 확인
  Future<Map<String, dynamic>> verifyEmail(String email, String code) async {
    try {
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
        final responseData = data['response'];
        
        return {
          'success': true,
          'email': responseData['email'],
          'code': responseData['code'],
        };
      }
      
      return {
        'success': false,
        'message': '인증번호가 올바르지 않습니다.',
      };
    } catch (e) {
      print('이메일 인증 API 호출 오류: $e');
      return {
        'success': false,
        'message': 'API 연결에 문제가 있습니다.',
      };
    }
  }

  // 회원가입
  Future<Map<String, dynamic>> register(
    String email, 
    String password,
    String nickname,
  ) async {
    try {
      if (email.trim().isEmpty) {
        return {
          'success': false,
          'message': '이메일을 입력해주세요.',
        };
      }

      if (password.trim().isEmpty) {
        return {
          'success': false,
          'message': '비밀번호를 입력해주세요.',
        };
      }

      if (nickname.trim().isEmpty) {
        return {
          'success': false,
          'message': '닉네임을 입력해주세요.',
        };
      }

      if (!email.endsWith('@dankook.ac.kr')) {
        return {
          'success': false,
          'message': '단국대학교 이메일 주소를 사용해주세요.',
        };
      }

      if (password.length < 8) {
        return {
          'success': false,
          'message': '비밀번호는 8자 이상이어야 합니다.',
        };
      }

      if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$').hasMatch(password)) {
        return {
          'success': false,
          'message': '비밀번호는 영문과 숫자를 포함해야 합니다.',
        };
      }

      if (nickname.length < 2 || nickname.length > 10) {
        return {
          'success': false,
          'message': '닉네임은 2-10자 사이여야 합니다.',
        };
      }

      if (!RegExp(r'^[가-힣a-zA-Z0-9]{2,10}$').hasMatch(nickname)) {
        return {
          'success': false,
          'message': '닉네임은 한글, 영문, 숫자만 사용 가능합니다.',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: headers,
        body: json.encode({
          'email': email,
          'password': password,
          'nickname': nickname,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final responseData = data['response'];
        final userData = responseData['user'];
        
        return {
          'success': true,
          'user': {
            'id': userData['id'],
            'email': userData['email'],
            'nickname': userData['nickname'],
            'profileImageUrl': userData['profileImageUrl'],
            'department': userData['department'],
            'isVerified': userData['isVerified'],
            'userLevel': userData['userLevel'],
            'userEXP': userData['userEXP'],
          },
        };
      }
      
      return {
        'success': false,
        'message': '회원가입에 실패했습니다.',
      };
    } catch (e) {
      print('회원가입 API 호출 오류: $e');
      return {
        'success': false,
        'message': 'API 연결에 문제가 있습니다.',
      };
    }
  }

  // 프로필 수정
  Future<Map<String, dynamic>> updateProfile({
    String? nickname,
    String? profileImageUrl,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/users/edit-profile'),
        headers: authHeaders,
        body: json.encode({
          if (nickname != null) 'nickname': nickname,
          if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final responseData = data['response'];
        
        _currentUserNickname = responseData['nickname'];
        _currentUserProfileImageUrl = responseData['profileImageUrl'];
        
        return {
          'success': true,
          'nickname': responseData['nickname'],
          'profileImageUrl': responseData['profileImageUrl'],
        };
      }
      
      return {
        'success': false,
        'message': '프로필 수정에 실패했습니다.',
      };
    } catch (e) {
      print('프로필 수정 API 호출 오류: $e');
      return {
        'success': false,
        'message': 'API 연결에 문제가 있습니다.',
      };
    }
  }

  // 소속 인증
  Future<Map<String, dynamic>> verifyDepartment(String email, String department) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/auth/verify-department'),
        headers: authHeaders,
        body: json.encode({
          'email': email,
          'department': department,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final responseData = data['response'];
        
        _currentUserDepartment = responseData['department'];
        _isVerified = responseData['isVerified'];
        
        return {
          'success': true,
          'department': responseData['department'],
          'isVerified': responseData['isVerified'],
        };
      }
      
      return {
        'success': false,
        'message': '소속 인증에 실패했습니다.',
      };
    } catch (e) {
      print('소속 인증 API 호출 오류: $e');
      return {
        'success': false,
        'message': 'API 연결에 문제가 있습니다.',
      };
    }
  }

  // 회원탈퇴
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/auth/delete-account'),
        headers: authHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final responseData = data['response'];
        
        await logout(); // 로컬 상태 초기화
        
        return {
          'success': true,
          'id': responseData['id'],
          'email': responseData['email'],
        };
      }
      
      return {
        'success': false,
        'message': '회원탈퇴에 실패했습니다.',
      };
    } catch (e) {
      print('회원탈퇴 API 호출 오류: $e');
      return {
        'success': false,
        'message': 'API 연결에 문제가 있습니다.',
      };
    }
  }

  void dispose() {
    _authStateController.close();
  }
} 