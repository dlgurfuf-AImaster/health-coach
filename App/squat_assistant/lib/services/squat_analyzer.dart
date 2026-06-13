class SquatAnalyzer {
  String _currentState = "STAND";
  String get currentState => _currentState;

  int _successCount = 0;
  int _waistErrorCount = 0;
  int _depthErrorCount = 0;
  int _goodMorningCount = 0;

  int get successCount => _successCount;
  int get waistErrorCount => _waistErrorCount;
  int get depthErrorCount => _depthErrorCount;
  int get goodMorningCount => _goodMorningCount;

  // ⚙️ 튜닝 파라미터
  final double _startSquatThreshold = 30.0;
  final double _fullSquatThreshold = 85.0; // 시연 추천 값 (85도는 너무 깊음)
  final double _getUpThreshold = 35.0;
  final double _waistLeanMax = 40.0;

  // 💡 이번 1회 반복(Rep) 동안의 기록을 담아둘 블랙박스 변수들
  double _maxThighAngleInCurrentRep = 0.0;
  bool _waistErrorTriggered = false; // 내려갈 때 허리 숙임 유무

  void reset() {
    _currentState = "STAND";
    _successCount = 0;
    _waistErrorCount = 0;
    _depthErrorCount = 0;
    _goodMorningCount = 0;
    _maxThighAngleInCurrentRep = 0.0;
    _waistErrorTriggered = false;
  }

  String analyze(double waistAngle, double thighAngle) {
    double cleanThigh = thighAngle.clamp(0.0, 180.0);
    double cleanWaist = waistAngle.clamp(0.0, 180.0);
    String message = "";

    switch (_currentState) {
    // ---------------------------------------------------------------------
    // [1단계: STAND] 서서 시작 대기
    // ---------------------------------------------------------------------
      case "STAND":
      // 새 동작 시작하므로 블랙박스 리셋
        _maxThighAngleInCurrentRep = 0.0;
        _waistErrorTriggered = false;

        if (cleanThigh > _startSquatThreshold) {
          _currentState = "SQUATTING"; // 하강/상승 통합 상태로 진입
          message = "운동 시작! 더 깊게 앉으세요.";
        } else {
          message = "바르게 서서 스쿼트를 시작하세요.";
        }
        break;

    // ---------------------------------------------------------------------
    // [2단계: SQUATTING] 앉았다가 일어나는 모든 움직임 통틀어 감시
    // ---------------------------------------------------------------------
      case "SQUATTING":
      // 1. 최고 깊이 실시간 기록
        if (cleanThigh > _maxThighAngleInCurrentRep) {
          _maxThighAngleInCurrentRep = cleanThigh;
        }

        // 2. 내려가거나 머무는 도중 허리를 숙였다면 블랙박스에 마킹 (상태 리셋 안 함!)
        if (cleanWaist > _waistLeanMax) {
          _waistErrorTriggered = true;
        }

        // 3. 🚨 [핵심] 유저가 완전히 일어났을 때 (동작 종료 시점), 단 한 번 단판 승부!
        if (cleanThigh <= _getUpThreshold) {

          // [우선순위 1번 판정] 내려갈 때 상체를 꼬꾸라트렸는가?
          if (_waistErrorTriggered) {
            _waistErrorCount++;
            message = "❌ 무효: 허리가 너무 숙여졌습니다! (상체 세우기)";
          }
          // [우선순위 2번 판정] 정석 깊이(65도)까지 충분히 못 앉았는가?
          else if (_maxThighAngleInCurrentRep < _fullSquatThreshold) {
            _depthErrorCount++;
            message = "❌ 무효: 너무 얕게 앉았습니다! 더 깊게 앉으세요.";
          }
          // [우선순위 3번 판정] 다 일어났는데 허리를 늦게 폈는가? (굿모닝)
          else if (cleanWaist > _waistLeanMax) {
            _goodMorningCount++;
            message = "❌ 무효: 일어날 때 상체가 뒤늦게 펴졌습니다!";
          }
          // [🎉 모든 관문 통과] 정석 스쿼트 성공!
          else {
            _successCount++;
            message = "✨ 스쿼트 ${_successCount}회 성공! 아주 좋습니다.";
          }

          // 판정이 끝났으므로 다음 횟수를 위해 무조건 STAND로 리셋
          _currentState = "STAND";
        } else {
          // 아직 완전히 일어나지 않았다면 진행 상황에 맞게 격려 메시지 유지
          if (_maxThighAngleInCurrentRep >= _fullSquatThreshold) {
            message = "좋습니다! 끝까지 무릎을 펴고 일어나세요.";
          } else {
            message = "조금만 더 깊게 앉아보세요!";
          }
        }
        break;
    }
    return message;
  }
}