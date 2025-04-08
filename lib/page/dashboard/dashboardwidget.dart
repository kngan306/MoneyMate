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

  // Dữ liệu động cho danh mục thu chi
  Map<String, Map<String, dynamic>> incomeCategories =
      {}; // {categoryId: {name, image, total}}
  Map<String, Map<String, dynamic>> expenseCategories =
      {}; // {categoryId: {name, image, total}}

  final List<String> months = [
    'Tháng 1',
    'Tháng 2',
    'Tháng 3',
    'Tháng 4',
    'Tháng 5',
    'Tháng 6',
    'Tháng 7',
    'Tháng 8',
    'Tháng 9',
    'Tháng 10',
    'Tháng 11',
    'Tháng 12'
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
        await _loadIncomeCategories(
            userDocId!, selectedMonth!); // Tải danh mục thu
        await _loadExpenseCategories(
            userDocId!, selectedMonth!); // Tải danh mục chi
        if (mounted) {
          // Kiểm tra mounted trước khi gọi setState
          setState(() {});
        }
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
  Future<void> _calculateMonthlyData(
      String userDocId, String selectedMonth) async {
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

  // Hàm tải danh mục thu nhập
  Future<void> _loadIncomeCategories(
      String userDocId, String selectedMonth) async {
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

    QuerySnapshot categorySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userDocId)
        .collection('danh_muc_thu')
        .get();

    Map<String, Map<String, dynamic>> tempIncomeCategories = {};
    for (var doc in categorySnapshot.docs) {
      tempIncomeCategories[doc.id] = {
        'name': doc['ten_muc_thu'] as String,
        'image': doc['image'] as String,
        'total': 0.0,
      };
    }

    QuerySnapshot incomeSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userDocId)
        .collection('thu_nhap')
        .where('ngay', isGreaterThanOrEqualTo: startDate)
        .where('ngay', isLessThan: endDate)
        .get();

    for (var doc in incomeSnapshot.docs) {
      String categoryId = doc['muc_thu_nhap'] as String;
      double amount = (doc['so_tien'] as num).toDouble();
      if (tempIncomeCategories.containsKey(categoryId)) {
        tempIncomeCategories[categoryId]!['total'] += amount;
      }
    }

    incomeCategories = Map.fromEntries(tempIncomeCategories.entries
        .where((entry) => entry.value['total'] > 0));
  }

  // Hàm tải danh mục chi tiêu
  Future<void> _loadExpenseCategories(
      String userDocId, String selectedMonth) async {
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

    QuerySnapshot categorySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userDocId)
        .collection('danh_muc_chi')
        .get();

    Map<String, Map<String, dynamic>> tempExpenseCategories = {};
    for (var doc in categorySnapshot.docs) {
      tempExpenseCategories[doc.id] = {
        'name': doc['ten_muc_chi'] as String,
        'image': doc['image'] as String,
        'total': 0.0,
      };
    }

    QuerySnapshot expenseSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userDocId)
        .collection('chi_tieu')
        .where('ngay', isGreaterThanOrEqualTo: startDate)
        .where('ngay', isLessThan: endDate)
        .get();

    for (var doc in expenseSnapshot.docs) {
      String categoryId = doc['muc_chi_tieu'] as String;
      double amount = (doc['so_tien'] as num).toDouble();
      if (tempExpenseCategories.containsKey(categoryId)) {
        tempExpenseCategories[categoryId]!['total'] += amount;
      }
    }

    expenseCategories = Map.fromEntries(tempExpenseCategories.entries
        .where((entry) => entry.value['total'] > 0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          "Trang chủ",
          style: TextStyle(
            fontSize: 20.sp,
            color: Colors.white,
          ),
        ),
        showToggleButtons: false,
        showMenuButton: true,
        onMenuPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Phần hiển thị tổng số dư
              Container(
                padding: EdgeInsets.only(bottom: 10.h),
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: Color(0xFF697565), width: 1.w)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Tổng số dư",
                        style: TextStyle(
                            fontSize: 17.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _isBalanceVisible
                                ? NumberFormat.currency(
                                        locale: 'vi_VN', symbol: 'đ')
                                    .format(totalBalance)
                                : "******",
                            style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 17.sp,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF697565)),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                              _isBalanceVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              size: 22.sp),
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
                        fontSize: 17.sp,
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
                          fontSize: 13.sp,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      items: months
                          .map((String item) => DropdownMenuItem<String>(
                                value: item,
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    fontSize: 13.sp,
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
                      onChanged: (String? value) async {
                        setState(() {
                          selectedMonth = value;
                        });
                        await _loadData();
                      },
                      buttonStyleData: ButtonStyleData(
                        padding: EdgeInsets.symmetric(horizontal: 15.w),
                        height: 40.h,
                        width: 150.w,
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
                                  fontSize: 15.sp,
                                  fontFamily: 'Montserrat',
                                )),
                            SizedBox(height: 5.h),
                            Text(
                                NumberFormat.currency(
                                        locale: 'vi_VN', symbol: 'đ')
                                    .format(monthlyIncome),
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 15.sp,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600,
                                )),
                          ],
                        ),
                        Column(
                          children: [
                            Text("Chi Tiêu",
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontFamily: 'Montserrat',
                                )),
                            SizedBox(height: 5.h),
                            Text(
                                NumberFormat.currency(
                                        locale: 'vi_VN', symbol: 'đ')
                                    .format(monthlyExpense),
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 15.sp,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600,
                                )),
                          ],
                        ),
                        Column(
                          children: [
                            Text("Tổng",
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontFamily: 'Montserrat',
                                )),
                            SizedBox(height: 5.h),
                            Text(
                                NumberFormat.currency(
                                        locale: 'vi_VN', symbol: 'đ')
                                    .format(monthlyTotal),
                                style: TextStyle(
                                  fontSize: 15.sp,
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
                              fontSize: 13.sp,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          SizedBox(width: 5.w),
                          const Icon(Icons.chevron_right, color: Colors.black),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              Padding(
                padding: EdgeInsets.only(bottom: 30.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Danh mục thu chi
                    Text(
                      "Danh mục thu chi",
                      style: TextStyle(
                          fontSize: 17.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10.h),
                    incomeCategories.isEmpty && expenseCategories.isEmpty
                        ? Text(
                            'Không có dữ liệu thu chi trong tháng này',
                            style: TextStyle(
                                fontSize: 15.sp,
                                fontFamily: 'Montserrat',
                                color: Colors.black54),
                          )
                        : ListView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              // Danh mục thu nhập
                              ...incomeCategories.entries.map((entry) {
                                return ExpenseItem(
                                  iconPath: entry.value['image'],
                                  title: entry.value['name'],
                                  amount: NumberFormat.currency(
                                          locale: 'vi_VN', symbol: 'đ')
                                      .format(entry.value['total']),
                                  isIncome: true,
                                  onTap: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LichSuTheoDanhMuc(
                                          categoryId: entry.key,
                                          isIncome: true,
                                          selectedMonth: selectedMonth!,
                                        ),
                                      ),
                                    );
                                    // Nếu result là true, làm mới dữ liệu Dashboard
                                    if (result == true) {
                                      await _loadData();
                                    }
                                  },
                                );
                              }).toList(),
                              // Danh mục chi tiêu
                              ...expenseCategories.entries.map((entry) {
                                return ExpenseItem(
                                  iconPath: entry.value['image'],
                                  title: entry.value['name'],
                                  amount: NumberFormat.currency(
                                          locale: 'vi_VN', symbol: 'đ')
                                      .format(-entry.value['total']),
                                  isIncome: false,
                                  onTap: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LichSuTheoDanhMuc(
                                          categoryId: entry.key,
                                          isIncome: false,
                                          selectedMonth: selectedMonth!,
                                        ),
                                      ),
                                    );
                                    // Nếu result là true, làm mới dữ liệu Dashboard
                                    if (result == true) {
                                      await _loadData();
                                    }
                                  },
                                );
                              }).toList(),
                            ],
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExpenseItem extends StatelessWidget {
  final String? iconPath;
  final String title;
  final String amount;
  final bool isIncome; // Thêm biến để xác định là thu nhập hay chi tiêu
  final VoidCallback onTap;

  const ExpenseItem({
    Key? key,
    this.iconPath,
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          children: [
            if (iconPath != null)
              Image.asset(
                iconPath!,
                width: 30.w,
                height: 30.h,
                fit: BoxFit.contain,
              ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 15.sp, fontFamily: 'Montserrat'),
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                fontSize: 15.sp,
                fontFamily: 'Montserrat',
                color: isIncome
                    ? const Color(0xFF4ABD57)
                    : const Color(0xFFFE0000),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
