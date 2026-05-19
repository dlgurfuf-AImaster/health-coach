import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import '../models/squat_model.dart';

class SquatProvider with ChangeNotifier {
  // 1. 개별 변수 대신 SquatData 객체 하나로 관리
  SquatData _data = SquatData(waistAngle: 0.0, thighAngle: 0.0);

  // 외부에서 접근할 Getter
  SquatData get data => _data;

  // 기준 벡터 및 상태 머신 변수는 로직용이므로 그대로 유지
  List<double>? _baseWaistVec;
  List<double>? _baseThighVec;
  int _squatState = 0;
  int _currentCount = 0;

  static const double SQUAT_DEPTH_LIMIT = 70.0;
  static const double STAND_UP_LIMIT = 20.0;
  static const double WAIST_WARNING_LIMIT = 45.0;

  /// 영점 조절
  void calibrate(List<double> wVec, List<double> tVec) {
    _baseWaistVec = wVec;
    _baseThighVec = tVec;

    // 객체 새로 생성 (상태 업데이트)
    _updateState(status: "영점 조절 완료! 시작하세요.");
  }

  /// 데이터 업데이트 및 판별
  void updateRawData(List<double> currentW, List<double> currentT) {
    if (_baseWaistVec == null || _baseThighVec == null) return;

    double wAngle = _calculateRelativeAngle(_baseWaistVec!, currentW);
    double tAngle = _calculateRelativeAngle(_baseThighVec!, currentT);
    String newStatus = _data.status;

    // 상태 머신 로직
    if (_squatState == 0 && tAngle > SQUAT_DEPTH_LIMIT) {
      _squatState = 1;
      newStatus = "성공 범위! 이제 일어나세요.";
    }

    if (_squatState == 1 && tAngle < STAND_UP_LIMIT) {
      _currentCount++;
      _squatState = 0;
      newStatus = "성공! (${_currentCount}회)";
    }

    // 허리 경고 우선 순위 적용
    if (tAngle > 20.0 && wAngle > WAIST_WARNING_LIMIT) {
      newStatus = "경고: 허리를 펴세요!";
    }

    // 2. 통합된 업데이트 메서드 호출
    _updateState(
      waist: wAngle,
      thigh: tAngle,
      count: _currentCount,
      status: newStatus,
    );
  }

  /// [핵심] 새로운 SquatData 객체를 생성하여 UI에 알림
  void _updateState({double? waist, double? thigh, int? count, String? status}) {
    _data = SquatData(
      waistAngle: waist ?? _data.waistAngle,
      thighAngle: thigh ?? _data.thighAngle,
      count: count ?? _data.count,
      status: status ?? _data.status,
    );
    notifyListeners();
  }

  // 각도 계산 수학 로직 (기존과 동일)
  double _calculateRelativeAngle(List<double> base, List<double> current) {
    double dotProduct = base[0] * current[0] + base[1] * current[1] + base[2] * current[2];
    double magnitude = sqrt(base[0] * base[0] + base[1] * base[1] + base[2] * base[2]) *
        sqrt(current[0] * current[0] + current[1] * current[1] + current[2] * current[2]);
    return acos((dotProduct / magnitude).clamp(-1.0, 1.0)) * (180.0 / pi);
  }

  void startMocking() {
    // 1. 측정하신 데이터 기반 영점 조절 (서 있을 때: X=10, Y=0, Z=0)
    calibrate([10.0, 0.0, 0.0], [10.0, 0.0, 0.0]);

    int tick = 0;
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      tick++;

      // 2. 0.0(서 있음) ~ 1.0(완전히 앉음) 사이를 왕복하는 계수
      double factor = (sin(tick * 0.1).abs());

      // 3. 측정하신 데이터 기반 가상 허벅지(Thigh) 벡터 생성
      // 서 있을 때(10, 0, 0) -> 앉았을 때(0, 3, -10)
      List<double> virtualThighVec = [
        10.0 * (1 - factor) + (0.0 * factor),  // X축 변화
        0.0 * (1 - factor) + (3.0 * factor),   // Y축 변화
        0.0 * (1 - factor) + (-10.0 * factor), // Z축 변화
      ];

      // 4. 허리는 허벅지보다 덜 움직이도록 설정 (예: factor의 30%만 반영)
      double wFactor = factor * 0.3;
      List<double> virtualWaistVec = [
        10.0 * (1 - wFactor) + (0.0 * wFactor),
        0.0 * (1 - wFactor) + (1.0 * wFactor),
        0.0 * (1 - wFactor) + (-3.0 * wFactor),
      ];

      // 5. 로직 업데이트
      updateRawData(virtualWaistVec, virtualThighVec);
    });
  }
}