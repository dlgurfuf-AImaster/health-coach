class SquatData {
  final double waistAngle;
  final double thighAngle;
  final int count;
  final String status; // "준비", "하강 중", "성공 범위", "상승 중"

  SquatData({
    required this.waistAngle,
    required this.thighAngle,
    this.count = 0,
    this.status = "준비",
  });
}