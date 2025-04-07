import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DonutChart_ChiTieu extends StatefulWidget {
  final String userDocId; // ID của document người dùng
  final DateTime focusedDay; // Tháng/năm được chọn từ ReportWidget

  const DonutChart_ChiTieu({
    super.key,
    required this.userDocId,
    required this.focusedDay,
  });

  @override
  _DonutChart_ChiTieuState createState() => _DonutChart_ChiTieuState();
}

class _DonutChart_ChiTieuState extends State<DonutChart_ChiTieu> {
  List<Map<String, dynamic>> categories = []; // Dữ liệu danh mục chi tiêu
  List<Color> colors = [
    Colors.blue,
    Colors.red,
    Colors.orange,
    Colors.cyan,
    Colors.indigo,
    Colors.green,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.amber,
  ]; // Danh sách màu tự động

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  // Hàm tải dữ liệu từ Firestore
  Future<void> _loadChartData() async {
    if (widget.userDocId.isEmpty) {
      print('Error: userDocId is empty');
      return;
    }

    String monthStr = widget.focusedDay.month.toString().padLeft(2, '0');
    String yearStr = widget.focusedDay.year.toString();
    String startDate = '$yearStr-$monthStr-01'; // Ngày đầu tháng
    String nextMonthStr = ((widget.focusedDay.month + 1) % 12).toString().padLeft(2, '0');
    String nextYearStr = (widget.focusedDay.month == 12 ? widget.focusedDay.year + 1 : widget.focusedDay.year).toString();
    if (widget.focusedDay.month == 12) nextMonthStr = '01';
    String endDate = '$nextYearStr-$nextMonthStr-01'; // Ngày đầu tháng tiếp theo

    // Truy vấn danh mục chi tiêu
    QuerySnapshot categorySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userDocId)
        .collection('danh_muc_chi')
        .get();

    Map<String, String> categoryMap = {}; // Map: ID danh mục -> Tên danh mục
    Map<String, double> expenseMap = {}; // Map: ID danh mục -> Tổng tiền

    // Lấy danh sách danh mục
    for (var doc in categorySnapshot.docs) {
      String categoryId = doc.id;
      String categoryName = doc['ten_muc_chi'] as String;
      categoryMap[categoryId] = categoryName;
      expenseMap[categoryId] = 0.0; // Khởi tạo tổng tiền = 0
    }

    // Truy vấn chi tiêu trong tháng
    QuerySnapshot expenseSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userDocId)
        .collection('chi_tieu')
        .where('ngay', isGreaterThanOrEqualTo: startDate)
        .where('ngay', isLessThan: endDate)
        .get();

    // Tính tổng tiền cho từng danh mục
    for (var doc in expenseSnapshot.docs) {
      String categoryId = doc['muc_chi_tieu'] as String;
      double amount = (doc['so_tien'] as num).toDouble();
      if (expenseMap.containsKey(categoryId)) {
        expenseMap[categoryId] = expenseMap[categoryId]! + amount;
      }
    }

    // Tạo danh sách categories từ dữ liệu
    categories = [];
    int colorIndex = 0;
    expenseMap.forEach((categoryId, totalAmount) {
      if (totalAmount > 0) { // Chỉ hiển thị danh mục có chi tiêu
        categories.add({
          "title": categoryMap[categoryId]!,
          "color": colors[colorIndex % colors.length], // Gán màu tự động
          "value": totalAmount,
        });
        colorIndex++;
      }
    });

    setState(() {}); // Cập nhật giao diện sau khi tải dữ liệu
  }

  @override
  void didUpdateWidget(covariant DonutChart_ChiTieu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusedDay != widget.focusedDay) {
      _loadChartData(); // Tải lại dữ liệu khi tháng thay đổi
    }
  }

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const Center(child: Text('Không có dữ liệu chi tiêu trong tháng này'));
    }

    // Tính tổng giá trị để lấy phần trăm
    double total = categories.fold(0, (sum, item) => sum + item["value"]);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Biểu đồ Donut Chart
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 50, // Tạo hiệu ứng Donut Chart
              sections: categories.map((data) {
                double percentage = (data["value"] / total) * 100;
                return PieChartSectionData(
                  value: data["value"].toDouble(),
                  color: data["color"],
                  radius: 50,
                  title: "${percentage.toStringAsFixed(1)}%",
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16), // Khoảng cách giữa chart và legend

        // Hiển thị chú thích bên dưới
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