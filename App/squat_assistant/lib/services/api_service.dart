import 'package:dio/dio.dart';

class ApiService {
  // 싱글톤 패턴 적용 (앱 전체에서 하나의 dio 인스턴스만 공유하여 메모리 절약)
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  final Dio _dio = Dio();

  // ⚠️ 중요: 에뮬레이터에서 로컬 컴퓨터(Spring Boot)에 접속할 때의 IP 주소입니다.
  // 안드로이드 에뮬레이터는 10.0.2.2가 내 컴퓨터(localhost)를 뜻합니다.
  // 실제 스마트폰으로 테스트할 때는 컴퓨터의 실제 IP 주소(예: 192.168.0.X)로 바꿔야 합니다.
  // ip 주소 계속 바뀜에 유의
  final String _baseUrl = "http://192.168.219.139:9000/api"; // 8080 -> 9000으로 변경!

  ApiService._internal() {
    // 디오 설정 (타임아웃 등)
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 5); // 5초 넘으면 연결 실패
    _dio.options.receiveTimeout = const Duration(seconds: 3);
  }

  // ① 회원가입 요청 함수
  Future<bool> registerUser(String name, String username, String password) async {
    try {
      // Spring Boot의 @PostMapping("/auth/signup")과 매핑될 자리입니다.
      final response = await _dio.post(
        "/user/signup",
        data: {
          "name": name,
          "username": username,
          "password": password,
        },
      );

      // 서버가 200 또는 201 성공 코드를 반환했는지 확인
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      print("회원가입 통신 에러: $e");
      return false;
    }
  }

  // ② 로그인 요청 함수
  Future<bool> loginUser(String username, String password) async {
    try {
      // Spring Boot의 @PostMapping("/auth/login")과 매핑될 자리입니다.
      final response = await _dio.post(
        "/user/login",
        data: {
          "username": username,
          "password": password,
        },
      );

      if (response.statusCode == 200) {
        // TODO: 나중에 서버가 돌려준 JWT 토큰을 저장하는 로직이 들어올 곳입니다.
        return true;
      }
      return false;
    } catch (e) {
      print("로그인 통신 에러: $e");
      return false;
    }
  }
}