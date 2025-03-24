import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChart_ChiTieu extends StatelessWidget {
  const BarChart_ChiTieu({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350, // 📌 Chiều cao biểu đồ
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40, // ✅ Đặt khoảng cách đủ để không bị cắt chữ
                getTitlesWidget: (value, meta) {
                  return Text(
                    "${value ~/ 1000}K", // ✅ Giữ số đơn vị rõ ràng
                    style: const TextStyle(fontSize: 10), // ✅ Giảm font size
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(
              // 🚀 Ẩn trục phải
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  List<String> labels = [
                    "Ăn uống",
                    "Mỹ phẩm",
                    "Tiền điện",
                    "Tiền nước",
                    "Tiền wifi"
                  ];
                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(labels[value.toInt()],
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11)),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(x: 0, barRods: [
              BarChartRodData(
                  toY: 240000,
                  color: Colors.blue,
                  width: 18,
                  borderRadius: BorderRadius.circular(4)),
            ]),
            BarChartGroupData(x: 1, barRods: [
              BarChartRodData(
                  toY: 500000,
                  color: Colors.red,
                  width: 18,
                  borderRadius: BorderRadius.circular(4)),
            ]),
            BarChartGroupData(x: 2, barRods: [
              BarChartRodData(
                  toY: 630000,
                  color: Colors.orange,
                  width: 18,
                  borderRadius: BorderRadius.circular(4)),
            ]),
            BarChartGroupData(x: 3, barRods: [
              BarChartRodData(
                  toY: 318000,
                  color: Colors.cyan,
                  width: 18,
                  borderRadius: BorderRadius.circular(4)),
            ]),
            BarChartGroupData(x: 4, barRods: [
              BarChartRodData(
                  toY: 220000,
                  color: Colors.indigo,
                  width: 18,
                  borderRadius: BorderRadius.circular(4)),
            ]),
          ],
        ),
      ),
    );
  }
}
