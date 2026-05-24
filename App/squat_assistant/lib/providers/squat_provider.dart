import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import '../models/squat_model.dart';
import 'package:squat_assistant/services/squat_analyzer.dart';

class SquatProvider with ChangeNotifier {
  SquatData _data = SquatData(waistAngle: 0.0, thighAngle: 0.0);

  SquatData get data => _data;

  final SquatAnalyzer _analyzer = SquatAnalyzer();

  List<double>? _baseWaistVec;
  List<double>? _baseThighVec;

  /// 영점 조절
  void calibrate(List<double> wVec, List<double> tVec) {
    _baseWaistVec = wVec;
    _baseThighVec = tVec;
    _analyzer.reset(); // 영점 잡을 때, 기준 상태도 stand로 초기화

    _updateState(status: "영점 조절 완료! 시작하세요.");
  }

  /// 블루투스로부터 오는 데이터 수신처
  void updateRawData(List<double> currentW, List<double> currentT) {
    if (_baseWaistVec == null || _baseThighVec == null) return;

    double wAngle = _calculateRelativeAngle(_baseWaistVec!, currentW);
    double tAngle = _calculateRelativeAngle(_baseThighVec!, currentT);

    // 계산 analyzer에게 넘기고 결괏값 받기
    String analysisResult = _analyzer.analyze(wAngle, tAngle);

    String newStatus = analysisResult.isNotEmpty
        ? analysisResult
        : _data.status;

    // 최종 스케줄링 및 UI 동기화
    _updateState(
      waist: wAngle,
      thigh: tAngle,
      count: _analyzer.successCount,
      status: newStatus,
    );
  }

  /// [핵심] 가상 데이터를 만들거나 상태를 갱신하여 UI를 새로 그리는 매니저 메서드
  void _updateState({
    double? waist,
    double? thigh,
    int? count,
    String? status,
  }) {
    _data = SquatData(
      waistAngle: waist ?? _data.waistAngle,
      thighAngle: thigh ?? _data.thighAngle,
      count: count ?? _data.count,
      status: status ?? _data.status,
    );
    notifyListeners(); // 🔔 플러터 화면에게 새 그림 그리라고 신호 보냄
  }

  /// 상대 각도 계산 수학 로직
  double _calculateRelativeAngle(List<double> base, List<double> current) {
    double dotProduct =
        base[0] * current[0] + base[1] * current[1] + base[2] * current[2];
    double magnitude =
        sqrt(base[0] * base[0] + base[1] * base[1] + base[2] * base[2]) *
        sqrt(
          current[0] * current[0] +
              current[1] * current[1] +
              current[2] * current[2],
        );
    return acos((dotProduct / magnitude).clamp(-1.0, 1.0)) * (180.0 / pi);
  }

  // 테스트용
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
        10.0 * (1 - factor) + (0.0 * factor), // X축 변화
        0.0 * (1 - factor) + (3.0 * factor), // Y축 변화
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
