import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DonutChart_ThuNhap extends StatelessWidget {
  const DonutChart_ThuNhap({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> categories = [
      {"title": "Tiền lương", "color": Colors.orange, "value": 1000000},
      {"title": "Phụ cấp", "color": Colors.amber, "value": 500000},
    ];

    // 📌 Tính tổng giá trị để lấy phần trăm
    double total = categories.fold(0, (sum, item) => sum + item["value"]);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 📌 Biểu đồ Donut Chart
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 50, // 📌 Tạo hiệu ứng Donut Chart
              sections: categories.map((data) {
                double percentage = (data["value"] / total) * 100;
                return PieChartSectionData(
                  value: data["value"].toDouble(),
                  color: data["color"],
                  radius: 50,
                  title: "${percentage.toStringAsFixed(1)}%", // ✅ Hiển thị %
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // 🔹 Giúp dễ đọc trên nền màu
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16), // 📌 Khoảng cách giữa chart và legend

        // 📌 Hiển thị chú thích bên dưới
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 8,
          children: categories.map((data) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: data["color"],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  data["title"],
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
