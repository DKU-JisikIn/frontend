import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // ApiService 인스턴스
  final ApiService _apiService = ApiService();

  // Base URL (API 서비스와 동일)
  static const String baseUrl = 'https://taba-backend2.purpleforest-e1d94921.koreacentral.azurecontainerapps.io';

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

  // 이메일 인증 요청 ID 저장
  int? _verificationRequestId;

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

  // 로그아웃 - ApiService 사용
  Future<void> logout() async {
    try {
      if (_refreshToken != null) {
        await _apiService.logout(_refreshToken!);
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
      final response = await _apiService.sendVerificationCode(email);
      _verificationRequestId = response['requestId'];  // requestId 저장
      return {
        'success': true,
        'message': '인증번호가 발송되었습니다.',
        'requestId': response['requestId'],
        'email': response['email'],
        'code': response['code'],
      };
    } catch (e) {
      print('인증 코드 전송 오류: $e');
      return {
        'success': false,
        'message': '인증번호 발송에 실패했습니다.',
      };
    }
  }

  // 이메일 인증
  Future<Map<String, dynamic>> verifyEmail(String email, String code) async {
    try {
      if (_verificationRequestId == null) {
        return {
          'success': false,
          'message': '먼저 인증번호를 요청해주세요.',
        };
      }
      
      final response = await _apiService.verifyEmail(_verificationRequestId!, email, code);
      return {
        'success': true,
        'message': '이메일 인증이 완료되었습니다.',
        'requestId': response['requestId'],
        'email': response['email'],
        'code': response['code'],
      };
    } catch (e) {
      print('이메일 인증 오류: $e');
      return {
        'success': false,
        'message': '인증에 실패했습니다. 인증번호를 확인해주세요.',
      };
    }
  }

  // 회원가입
  Future<Map<String, dynamic>> register(String email, String password, String nickname) async {
    try {
      final response = await _apiService.register(email, password, nickname);
      return {
        'success': true,
        'message': '회원가입이 완료되었습니다.',
        'user': response['user'],
      };
    } catch (e) {
      print('회원가입 오류: $e');
      return {
        'success': false,
        'message': '회원가입에 실패했습니다.',
      };
    }
  }

  // 프로필 수정
  Future<Map<String, dynamic>> updateProfile(String nickname, String profileImageUrl) async {
    try {
      final response = await _apiService.updateProfile(nickname, profileImageUrl, token: _accessToken);
      
      // 로컬 상태 업데이트
      _currentUserNickname = response['nickname'];
      _currentUserProfileImageUrl = response['profileImageUrl'];
      
      return {
        'success': true,
        'message': '프로필이 성공적으로 업데이트되었습니다.',
        'nickname': response['nickname'],
        'profileImageUrl': response['profileImageUrl'],
      };
    } catch (e) {
      print('프로필 수정 오류: $e');
      return {
        'success': false,
        'message': '프로필 수정에 실패했습니다.',
      };
    }
  }

  // 소속 인증
  Future<Map<String, dynamic>> verifyDepartment(String email, String department) async {
    try {
      final response = await _apiService.verifyDepartment(email, department, token: _accessToken);
      
      // 로컬 상태 업데이트
      _currentUserDepartment = response['department'];
      _isVerified = response['isVerified'];
      
      return {
        'success': true,
        'message': '소속 인증이 완료되었습니다.',
        'department': response['department'],
        'isVerified': response['isVerified'],
      };
    } catch (e) {
      print('소속 인증 오류: $e');
      return {
        'success': false,
        'message': '소속 인증에 실패했습니다.',
      };
    }
  }

  // 회원탈퇴
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final response = await _apiService.deleteAccount(token: _accessToken);
      
      // 로컬 상태 초기화
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
      
      return {
        'success': true,
        'message': '회원탈퇴가 완료되었습니다.',
        'id': response['id'],
        'email': response['email'],
      };
    } catch (e) {
      print('회원탈퇴 오류: $e');
      return {
        'success': false,
        'message': '회원탈퇴에 실패했습니다.',
      };
    }
  }

  void dispose() {
    _authStateController.close();
  }
} 