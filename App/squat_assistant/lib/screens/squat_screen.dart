import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/squat_provider.dart'; // 경로 확인 필요

class SquatScreen extends StatelessWidget {
  const SquatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI 스쿼트 코치"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<SquatProvider>(
        builder: (context, provider, child) {
          // 최신 데이터 객체(Snapshot) 가져오기
          final squat = provider.data;

          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),

                // 1. 상태 메시지 카드
                _buildStatusCard(squat.status),

                const SizedBox(height: 40),

                // 2. 실시간 각도 표시 (커스텀 게이지 스타일)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAngleGauge("허리 각도", squat.waistAngle, Colors.orange),
                    _buildAngleGauge("허벅지 각도", squat.thighAngle, Colors.blue),
                  ],
                ),

                const SizedBox(height: 50),

                // 3. 카운트 표시
                Text(
                  "${squat.count}",
                  style: const TextStyle(
                    fontSize: 100,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                const Text(
                  "SQUATS",
                  style: TextStyle(fontSize: 20, letterSpacing: 2),
                ),

                const SizedBox(height: 50),

                // 4. 컨트롤 버튼들
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                provider.startBluetoothWorkout();
                              },
                              icon: const Icon(Icons.bluetooth_connected),
                              label: const Text("아두이노 연결"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => provider.startMocking(),
                              icon: const Icon(Icons.play_arrow),
                              label: const Text("가상 테스트"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[200],
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // 수동 영점 초기화 버튼
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // 영점 잡기 수동 초기화 실시
                                provider.startBluetoothWorkout();
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text("다시 연결"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orangeAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  // 상태 메시지 빌더
  Widget _buildStatusCard(String status) {
    bool isWarning = status.contains("경고");
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isWarning ? Colors.red[50] : Colors.blue[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isWarning ? Colors.red : Colors.blueAccent),
      ),
      child: Center(
        child: Text(
          status,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isWarning ? Colors.red : Colors.blueAccent,
          ),
        ),
      ),
    );
  }

  // 각도 게이지 빌더
  Widget _buildAngleGauge(String label, double value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 10),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: (value % 180) / 180, // 180도 기준 비율
                strokeWidth: 8,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Text(
              "${value.toInt()}°",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}
