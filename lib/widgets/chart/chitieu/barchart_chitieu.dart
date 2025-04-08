import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BarChart_ChiTieu extends StatefulWidget {
  final String userDocId; // ID của document người dùng
  final DateTime focusedDay; // Tháng/năm được chọn từ ReportWidget

  const BarChart_ChiTieu({
    super.key,
    required this.userDocId,
    required this.focusedDay,
  });

  @override
  _BarChart_ChiTieuState createState() => _BarChart_ChiTieuState();
}

class _BarChart_ChiTieuState extends State<BarChart_ChiTieu> {
  List<String> labels = []; // Danh sách tên danh mục chi tiêu
  List<BarChartGroupData> barGroups = []; // Dữ liệu cột biểu đồ
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
    String nextMonthStr =
        ((widget.focusedDay.month + 1) % 12).toString().padLeft(2, '0');
    String nextYearStr = (widget.focusedDay.month == 12
            ? widget.focusedDay.year + 1
            : widget.focusedDay.year)
        .toString();
    if (widget.focusedDay.month == 12) nextMonthStr = '01';
    String endDate =
        '$nextYearStr-$nextMonthStr-01'; // Ngày đầu tháng tiếp theo

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

    // Tạo labels và barGroups từ dữ liệu
    labels = [];
    barGroups = [];
    int index = 0;
    expenseMap.forEach((categoryId, totalAmount) {
      if (totalAmount > 0) {
        // Chỉ hiển thị danh mục có chi tiêu
        labels.add(categoryMap[categoryId]!);
        barGroups.add(
          BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: totalAmount,
                color: colors[
                    index % colors.length], // Gán màu tự động không trùng
                width: 18.w,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ],
          ),
        );
        index++;
      }
    });

    setState(() {}); // Cập nhật giao diện sau khi tải dữ liệu
  }

  @override
  void didUpdateWidget(covariant BarChart_ChiTieu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusedDay != widget.focusedDay) {
      _loadChartData(); // Tải lại dữ liệu khi tháng thay đổi
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350.h,
      child: barGroups.isEmpty
          ? Center(child: Text('Không có dữ liệu chi tiêu trong tháng này'))
          : BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50.w,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          "${(value ~/ 1000)}K",
                          style: TextStyle(fontSize: 10.sp),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50.w,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < labels.length) {
                          String label = labels[index];
                          String shortenedLabel = label.length > 8
                              ? '${label.substring(0, 6)}...'
                              : label;

                          return Transform.rotate(
                            angle: -0.5, // Xoay khoảng -28 độ
                            child: Padding(
                              padding: EdgeInsets.only(top: 10.h),
                              child: Text(
                                shortenedLabel,
                                style: TextStyle(fontSize: 10.sp),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: barGroups,
              ),
            ),
    );
  }
}
