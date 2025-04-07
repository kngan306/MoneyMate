import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BarChart_ThuNhap extends StatefulWidget {
  final String userDocId; // ID của document người dùng
  final DateTime focusedDay; // Tháng/năm được chọn từ ReportWidget

  const BarChart_ThuNhap({
    super.key,
    required this.userDocId,
    required this.focusedDay,
  });

  @override
  _BarChart_ThuNhapState createState() => _BarChart_ThuNhapState();
}

class _BarChart_ThuNhapState extends State<BarChart_ThuNhap> {
  List<String> labels = []; // Danh sách tên danh mục thu nhập
  List<BarChartGroupData> barGroups = []; // Dữ liệu cột biểu đồ
  List<Color> colors = [
    Colors.orange,
    Colors.amber,
    Colors.green,
    Colors.teal,
    Colors.purple,
    Colors.blue,
    Colors.red,
    Colors.cyan,
    Colors.pink,
    Colors.indigo,
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

    // Truy vấn danh mục thu nhập
    QuerySnapshot categorySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userDocId)
        .collection('danh_muc_thu')
        .get();

    Map<String, String> categoryMap = {}; // Map: ID danh mục -> Tên danh mục
    Map<String, double> incomeMap = {}; // Map: ID danh mục -> Tổng tiền

    // Lấy danh sách danh mục
    for (var doc in categorySnapshot.docs) {
      String categoryId = doc.id;
      String categoryName = doc['ten_muc_thu'] as String; // Field tên danh mục thu nhập
      categoryMap[categoryId] = categoryName;
      incomeMap[categoryId] = 0.0; // Khởi tạo tổng tiền = 0
    }

    // Truy vấn thu nhập trong tháng
    QuerySnapshot incomeSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userDocId)
        .collection('thu_nhap')
        .where('ngay', isGreaterThanOrEqualTo: startDate)
        .where('ngay', isLessThan: endDate)
        .get();

    // Tính tổng tiền cho từng danh mục
    for (var doc in incomeSnapshot.docs) {
      String categoryId = doc['muc_thu_nhap'] as String; // Field tham chiếu danh mục
      double amount = (doc['so_tien'] as num).toDouble();
      if (incomeMap.containsKey(categoryId)) {
        incomeMap[categoryId] = incomeMap[categoryId]! + amount;
      }
    }

    // Tạo labels và barGroups từ dữ liệu
    labels = [];
    barGroups = [];
    int index = 0;
    incomeMap.forEach((categoryId, totalAmount) {
      if (totalAmount > 0) { // Chỉ hiển thị danh mục có thu nhập
        labels.add(categoryMap[categoryId]!);
        barGroups.add(
          BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: totalAmount,
                color: colors[index % colors.length], // Gán màu tự động
                width: 18,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        );
        index++;
      }
    });

    setState(() {}); // Cập nhật giao diện
  }

  @override
  void didUpdateWidget(covariant BarChart_ThuNhap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusedDay != widget.focusedDay) {
      _loadChartData(); // Tải lại dữ liệu khi tháng thay đổi
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      child: barGroups.isEmpty
          ? const Center(child: Text('Không có dữ liệu thu nhập trong tháng này'))
          : BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          "${(value ~/ 1000)}K",
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < labels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              labels[index],
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 11),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: barGroups,
              ),
            ),
    );
  }
}