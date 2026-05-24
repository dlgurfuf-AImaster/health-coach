enum SquatState {
  stand,       // 0: 서 있는 상태
  goingDown,   // 1: 내려가는 중
  bottom,      // 2: 최저점 구간 진입 및 판정
  goingUp      // 3: 다시 일어서는 중
}

class SquatAnalyzer {
  SquatState squatState = SquatState.stand;

  double maxThighAngle = 0.0;
  double captureWaistAngle = 0.0;
  DateTime? bottomEnterTime;

  // DB로 보낼 최종 통계 변수
  int totalCount = 0;
  int successCount = 0;
  int badWaistAngleCount = 0;
  int shallowSquatCount = 0;

  // 판정 기준 상수
  static const double SQUAT_DEPTH_LIMIT = 70.0;
  static const double STAND_UP_LIMIT = 20.0;
  static const double WAIST_WARNING_LIMIT = 45.0;
  static const double COLLAPSE_LIMIT = 120.0;

  // 핵심 판정 메서드
  String analyze(double wAngle, double tAngle) {
    // 주저앉음 필터
    if (tAngle > COLLAPSE_LIMIT) {
      reset();
      return "🚨 경고: 주저앉음 감지! 다시 서서 시작하세요.";
    }

    // 시간 초과 필터 (5초 시간 초과시)
    if (squatState == SquatState.bottom && bottomEnterTime != null) {
      if (DateTime
          .now()
          .difference(bottomEnterTime!)
          .inSeconds > 5) {
        reset();
        return "🚨 경고: 최저점 시간 초과! 실패 처리됩니다.";
      }
    }

    // 상태 머신
    switch (squatState) {
      case SquatState.stand:
        if (tAngle > 25.0) {
          squatState = SquatState.goingDown;
          maxThighAngle = tAngle;
          captureWaistAngle = wAngle;
          return "내려가는 중...";
        }
        break;

      case SquatState.goingDown:
        if (tAngle > maxThighAngle) {
          maxThighAngle = tAngle;
          captureWaistAngle = wAngle; // 최저점 허리 각도 캡쳐
        }

        // 목표 깊이 도달 시
        if (tAngle >= SQUAT_DEPTH_LIMIT) {
          squatState = SquatState.bottom;
          bottomEnterTime = DateTime.now();
          return _evaluatePosture(); // 즉시 1차 자세 변경
        }
        break;

      case SquatState.bottom:
        // 사용자가 다시 일어서기 시작하여 각도 감소 시
        if (tAngle < 60.0) squatState = SquatState.goingUp;
        break;

      case SquatState.goingUp:
        // 원점으로 안전하게 복귀했을 때 1회 최종 인정
        if (tAngle <= STAND_UP_LIMIT) {
          _completeRepetition();
          String finalMsg = "성공! 총 ${totalCount}회 중 ${successCount}회 성공";
          reset();
          return finalMsg;
        }
        break;
    }
    return ""; // 상태 변화가 없을 때는 빈 문자열 반환
  }

  // 자세 판정 내부 로직
  String _evaluatePosture() {
    if (captureWaistAngle > WAIST_WARNING_LIMIT && maxThighAngle < 80.0) {
      return "⚠️ 불량: 허리가 너무 숙여졌습니다! 상체를 세우세요.";
    } else if (maxThighAngle < 75.0) {
      return "⚠️ 불량: 깊이가 너무 얕습니다! 더 앉으세요.";
    } else {
      return "✅ 정자세! 그대로 올라오세요.";
    }
  }

  // 카운트 및 경향성 통계 누적
  void _completeRepetition() {
    totalCount++;
    String pattern = _evaluatePosture();
    if (pattern.contains("정자세")) successCount++;
    if (pattern.contains("허리")) badWaistAngleCount++;
    if (pattern.contains("얕습니다")) shallowSquatCount++;
  }
  
  // 다음 횟수 또는 에러 시 리셋
  void reset() {
    squatState = SquatState.stand;
    maxThighAngle = 0.0;
    captureWaistAngle = 0.0;
    bottomEnterTime = null;
  }
}
