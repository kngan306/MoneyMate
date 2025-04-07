import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DonutChart_ThuNhap extends StatefulWidget {
  final String userDocId; // ID của document người dùng
  final DateTime focusedDay; // Tháng/năm được chọn từ ReportWidget

  const DonutChart_ThuNhap({
    super.key,
    required this.userDocId,
    required this.focusedDay,
  });

  @override
  _DonutChart_ThuNhapState createState() => _DonutChart_ThuNhapState();
}

class _DonutChart_ThuNhapState extends State<DonutChart_ThuNhap> {
  List<Map<String, dynamic>> categories = []; // Dữ liệu danh mục thu nhập
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

    // Tạo danh sách categories từ dữ liệu
    categories = [];
    int colorIndex = 0;
    incomeMap.forEach((categoryId, totalAmount) {
      if (totalAmount > 0) { // Chỉ hiển thị danh mục có thu nhập
        categories.add({
          "title": categoryMap[categoryId]!,
          "color": colors[colorIndex % colors.length], // Gán màu tự động
          "value": totalAmount,
        });
        colorIndex++;
      }
    });

    setState(() {}); // Cập nhật giao diện
  }

  @override
  void didUpdateWidget(covariant DonutChart_ThuNhap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusedDay != widget.focusedDay) {
      _loadChartData(); // Tải lại dữ liệu khi tháng thay đổi
    }
  }

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const Center(child: Text('Không có dữ liệu thu nhập trong tháng này'));
    }

    // Tính tổng giá trị để lấy phần trăm
    double total = categories.fold(0, (sum, item) => sum + item["value"]);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Biểu đồ Donut Chart
        SizedBox(
          height: 200.h,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2.w,
              centerSpaceRadius: 50.w,
              sections: categories.map((data) {
                double percentage = (data["value"] / total) * 100;
                return PieChartSectionData(
                  value: data["value"].toDouble(),
                  color: data["color"],
                  radius: 50.r,
                  title: "${percentage.toStringAsFixed(1)}%",
                  titleStyle: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        SizedBox(height: 16.h), // Khoảng cách giữa chart và legend

        // Hiển thị chú thích bên dưới
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10.w,
          runSpacing: 8.h,
          children: categories.map((data) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: data["color"],
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  data["title"],
                  style: TextStyle(fontSize: 12.sp),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}