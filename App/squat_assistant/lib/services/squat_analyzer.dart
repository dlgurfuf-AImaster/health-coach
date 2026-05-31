class SquatAnalyzer {
  // 현재 유저의 운동 상태를 정의
  String _currentState = "STAND";

  int _successCount = 0;
  int get successCount => _successCount;

  // 💡 노이즈 방어벽 (데드존 임계값)
  // 가만히 있어도 15도까지 흔들리므로, 최소 25도는 넘게 내려가야 "앉기 시작했다"라고 인정합니다.
  final double _startSquatThreshold = 25.0;

  // 💡 스쿼트 인정 기준 각도
  // 허벅지가 최소 65도 이상은 내려가야 "제대로 앉았다"라고 인정합니다.
  final double _fullSquatThreshold = 65.0;

  /// 상태 및 카운트 초기화 (영점 잡을 때 호출)
  void reset() {
    _currentState = "STAND";
    _successCount = 0;
  }

  /// 🎯 [핵심] 오직 '정확한 스쿼트 1개 성공'에만 집중하는 필터링 로직
  String analyze(double waistAngle, double thighAngle) {
    // 1. 센서 노이즈로 인해 각도가 마이너스로 튀거나 역전되는 현상 방지
    double cleanThigh = thighAngle.clamp(0.0, 180.0);
    double cleanWaist = waistAngle.clamp(0.0, 180.0);

    String message = "";

    switch (_currentState) {
      case "STAND":
      // 서 있는 상태에서 허벅지가 노이즈(15도)를 뚫고 확실하게 내려가기 시작하면
        if (cleanThigh > _startSquatThreshold) {
          _currentState = "GOING_DOWN";
          message = "내려가는 중... 더 깊게 앉으세요!";
        } else {
          message = "바르게 서서 스쿼트를 시작하세요.";
        }
        break;

      case "GOING_DOWN":
      // 확실하게 목표 깊이(65도 이상)까지 도달했는지 체크
        if (cleanThigh >= _fullSquatThreshold) {
          _currentState = " FULL_SQUAT";
          message = "좋습니다! 그대로 천천히 일어나세요.";
        }
        // 만약 깊이 못 앉고 어중간하게 다시 인어서 서 버리면 노이즈나 무효 처리
        else if (cleanThigh < _startSquatThreshold) {
          _currentState = "STAND";
          message = "조금 더 깊게 앉아야 합니다. 다시 시도하세요.";
        }
        break;

      case "FULL_SQUAT":
      // 완전히 앉은 상태에서 유저가 몸을 일으켜 다시 서 있는 기준(25도 이하)으로 복귀하면
        if (cleanThigh <= _startSquatThreshold) {
          // ⚠️ 여기서 허리가 너무 앞으로 꼬꾸라졌는지 최후의 커트라인만 하나 둡니다.
          // 허벅지는 일어났는데 허리가 45도 이상 숙여져 있다면 이건 스쿼트가 아니라 굿모닝 엑서사이즈가 됩니다.
          if (cleanWaist > 40.0) {
            message = "일어날 때 허리가 너무 숙여졌습니다! 카운트 제외.";
            _currentState = "STAND"; // 카운트는 안 올리고 상태만 리셋
          } else {
            // 🎉 완벽한 스쿼트 1개 성공!
            _successCount++;
            message = "✨ 스쿼트 ${_successCount}회 성공! 아주 좋습니다.";
            _currentState = "STAND"; // 다음 스쿼트를 위해 상태 리셋
          }
        }
        break;
    }

    return message;
  }
}