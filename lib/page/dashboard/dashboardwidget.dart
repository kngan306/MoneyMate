import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../widgets/custom_app_bar.dart';
import 'package:flutter_moneymate_01/page/dashboard/lichsughichep_screen.dart';
import 'package:flutter_moneymate_01/page/dashboard/lichsutheodanhmuc_screen.dart';
import '../mainpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({super.key});

  @override
  _DashboardWidgetState createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  bool _isBalanceVisible = false;
  String? selectedMonth;
  int currentYear = DateTime.now().year;
  double totalBalance = 0.0;
  double monthlyIncome = 0.0;
  double monthlyExpense = 0.0;
  double monthlyTotal = 0.0;
  String? userDocId; // Biến để lưu ID của document người dùng

  final List<String> months = [
    'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
    'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'
  ];

  @override
  void initState() {
    super.initState();
    int currentMonth = DateTime.now().month;
    selectedMonth = months[currentMonth - 1];
    _loadData();
  }

  // Hàm tải dữ liệu từ Firestore
  Future<void> _loadData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Lấy document người dùng từ Firestore dựa trên email
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      if (userDoc.docs.isNotEmpty) {
        userDocId = userDoc.docs.first.id; // Lấy ID của document người dùng
        await _calculateTotalBalance(userDocId!);
        await _calculateMonthlyData(userDocId!, selectedMonth!);
        setState(() {});
      } else {
        print('Không tìm thấy thông tin người dùng trong Firestore.');
      }
    }
  }

  // Hàm tính tổng số dư từ tất cả bản ghi
  Future<void> _calculateTotalBalance(String userDocId) async {
    // Truy vấn tất cả thu nhập của người dùng
    QuerySnapshot incomeSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userDocId)
        .collection('thu_nhap')
        .get();
    double totalIncome = incomeSnapshot.docs.fold(0.0, (sum, doc) {
      return sum + (doc['so_tien'] as num).toDouble();
    });

    // Truy vấn tất cả chi tiêu của người dùng
    QuerySnapshot expenseSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userDocId)
        .collection('chi_tieu')
        .get();
    double totalExpense = expenseSnapshot.docs.fold(0.0, (sum, doc) {
      return sum + (doc['so_tien'] as num).toDouble();
    });

    totalBalance = totalIncome - totalExpense;
  }

  // Hàm tính dữ liệu thu nhập và chi tiêu theo tháng
  Future<void> _calculateMonthlyData(String userDocId, String selectedMonth) async {
    int monthIndex = months.indexOf(selectedMonth) + 1;
    String monthStr = monthIndex.toString().padLeft(2, '0');
    String yearStr = currentYear.toString();

    String startDate = '$yearStr-$monthStr-01';
    String nextMonthStr = (monthIndex + 1).toString().padLeft(2, '0');
    String nextYearStr = yearStr;
    if (monthIndex == 12) {
      nextMonthStr = '01';
      nextYearStr = (currentYear + 1).toString();
    }
    String endDate = '$nextYearStr-$nextMonthStr-01';

    // Truy vấn thu nhập trong tháng
    QuerySnapshot incomeSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userDocId)
        .collection('thu_nhap')
        .where('ngay', isGreaterThanOrEqualTo: startDate)
        .where('ngay', isLessThan: endDate)
        .get();
    monthlyIncome = incomeSnapshot.docs.fold(0.0, (sum, doc) {
      return sum + (doc['so_tien'] as num).toDouble();
    });

    // Truy vấn chi tiêu trong tháng
    QuerySnapshot expenseSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userDocId)
        .collection('chi_tieu')
        .where('ngay', isGreaterThanOrEqualTo: startDate)
        .where('ngay', isLessThan: endDate)
        .get();
    monthlyExpense = expenseSnapshot.docs.fold(0.0, (sum, doc) {
      return sum + (doc['so_tien'] as num).toDouble();
    });

    monthlyTotal = monthlyIncome - monthlyExpense;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Trang chủ",
        showToggleButtons: false,
        showMenuButton: true,
        onMenuPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Phần hiển thị tổng số dư
              Container(
                padding: EdgeInsets.only(bottom: 10.h),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFF697565), width: 1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Tổng số dư",
                        style: TextStyle(
                            fontSize: 17,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _isBalanceVisible
                                ? NumberFormat.currency(locale: 'vi_VN', symbol: 'đ')
                                    .format(totalBalance)
                                : "******",
                            style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF697565)),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                              _isBalanceVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              size: 22),
                          onPressed: () {
                            setState(() {
                              _isBalanceVisible = !_isBalanceVisible;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              // Phần tình hình thu chi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Tình hình thu chi",
                    style: TextStyle(
                        fontSize: 17,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold),
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      isExpanded: true,
                      hint: Text(
                        'Chọn tháng',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 13,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      items: months
                          .map((String item) => DropdownMenuItem<String>(
                                value: item,
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: selectedMonth == item
                                        ? Colors.blueAccent
                                        : Colors.black,
                                    fontWeight: selectedMonth == item
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ))
                          .toList(),
                      value: selectedMonth,
                      onChanged: (String? value) {
                        setState(() {
                          selectedMonth = value;
                          _loadData();
                        });
                      },
                      buttonStyleData: ButtonStyleData(
                        padding: EdgeInsets.symmetric(horizontal: 15.w),
                        height: 40.h,
                        width: 130.w,
                      ),
                      menuItemStyleData: MenuItemStyleData(
                        height: 40.h,
                      ),
                      dropdownStyleData: DropdownStyleData(
                        maxHeight: 200.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 5.r,
                              spreadRadius: 1.r,
                              offset: Offset(0, 3.h),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 150.w,
                      height: 150.h,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              value: monthlyIncome,
                              title: "",
                              color: Colors.green,
                              radius: 50.r,
                            ),
                            PieChartSectionData(
                              value: monthlyExpense,
                              title: "",
                              color: Colors.red,
                              radius: 50.r,
                            ),
                          ],
                          sectionsSpace: 2.w,
                          centerSpaceRadius: 30.r,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text("Thu nhập",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'Montserrat',
                                )),
                            SizedBox(height: 5.h),
                            Text(
                                NumberFormat.currency(locale: 'vi_VN', symbol: 'đ')
                                    .format(monthlyIncome),
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 15,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600,
                                )),
                          ],
                        ),
                        Column(
                          children: [
                            Text("Chi Tiêu",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'Montserrat',
                                )),
                            SizedBox(height: 5.h),
                            Text(
                                NumberFormat.currency(locale: 'vi_VN', symbol: 'đ')
                                    .format(monthlyExpense),
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 15,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600,
                                )),
                          ],
                        ),
                        Column(
                          children: [
                            Text("Tổng",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'Montserrat',
                                )),
                            SizedBox(height: 5.h),
                            Text(
                                NumberFormat.currency(locale: 'vi_VN', symbol: 'đ')
                                    .format(monthlyTotal),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600,
                                )),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Mainpage(selectedIndex: 8),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Lịch sử ghi chép",
                            style: TextStyle(
                              fontSize: 13,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Icon(Icons.chevron_right, color: Colors.black),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              Text("Danh mục thu chi",
                  style: TextStyle(
                      fontSize: 17,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 10.h),
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ExpenseItem(
                    iconPath: "assets/images/food.png",
                    title: "Ăn uống",
                    amount: "-1,000,000 đ",
                    onTap: () {},
                  ),
                  ExpenseItem(
                    iconPath: "assets/images/quanao.png",
                    title: "Quần áo",
                    amount: "-500,000 đ",
                    onTap: () {},
                  ),
                  ExpenseItem(
                    iconPath: "assets/images/mypham.png",
                    title: "Mỹ phẩm",
                    amount: "-400,000 đ",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Mainpage(selectedIndex: 9),
                        ),
                      );
                    },
                  ),
                  ExpenseItem(
                    iconPath: "assets/images/yte.png",
                    title: "Y tế",
                    amount: "-100,000 đ",
                    onTap: () {},
                  ),
                  ExpenseItem(
                    iconPath: "assets/images/xemay.png",
                    title: "Đi lại",
                    amount: "-500,000 đ",
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExpenseItem extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String amount;
  final String? iconPath;
  final VoidCallback onTap;

  const ExpenseItem({
    Key? key,
    this.icon,
    required this.title,
    required this.amount,
    this.iconPath,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          children: [
            if (iconPath != null)
              Image.asset(iconPath!, width: 30.w, height: 30.h)
            else if (icon != null)
              Icon(icon, size: 30.sp, color: Colors.redAccent),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 15, fontFamily: 'Montserrat'),
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                  fontSize: 15, fontFamily: 'Montserrat', color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}