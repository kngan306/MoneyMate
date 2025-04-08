import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/tab/baocao_tab.dart';
import '../../widgets/chart/chitieu/barchart_chitieu.dart';
import '../../widgets/chart/chitieu/donutchart_chitieu.dart';
import '../../widgets/chart/thunhap/barchart_thunhap.dart';
import '../../widgets/chart/thunhap/donutchart_thunhap.dart';
import 'timkiembaocao_screen.dart';
import '../mainpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_moneymate_01/page/dashboard/lichsutheodanhmuc_screen.dart';

class ReportWidget extends StatefulWidget {
  const ReportWidget({super.key});

  @override
  _ReportWidgetState createState() => _ReportWidgetState();
}

class _ReportWidgetState extends State<ReportWidget> {
  String selectedChartChiTieu = "Cột";
  String selectedChartThuNhap = "Tròn";

  late DateTime _focusedDay;
  bool isExpenseSelected = true;

  String? userDocId;
  double monthlyIncome = 0.0;
  double monthlyExpense = 0.0;
  double monthlyTotal = 0.0;

  // Dữ liệu động cho danh sách chi tiết
  Map<String, Map<String, dynamic>> expenseDetails =
      {}; // Chi tiết chi tiêu: {categoryId: {name, image, total}}
  Map<String, Map<String, dynamic>> incomeDetails =
      {}; // Chi tiết thu nhập: {categoryId: {name, image, total}}

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _loadData();
  }

  // Hàm tải dữ liệu từ Firestore
  Future<void> _loadData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print('User Email: ${user.email}');
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      print('Number of user documents found: ${userDoc.docs.length}');
      if (userDoc.docs.isNotEmpty) {
        userDocId = userDoc.docs.first.id;
        print('User Document ID: $userDocId');
        await _calculateMonthlyData(userDocId!, _focusedDay);
        await _loadExpenseDetails(
            userDocId!, _focusedDay); // Tải chi tiết chi tiêu
        await _loadIncomeDetails(
            userDocId!, _focusedDay); // Tải chi tiết thu nhập
        setState(() {});
      } else {
        print('Không tìm thấy thông tin người dùng trong Firestore.');
      }
    } else {
      print('Không có người dùng đăng nhập.');
    }
  }

  // Hàm tính dữ liệu tổng quát theo tháng
  Future<void> _calculateMonthlyData(
      String userDocId, DateTime focusedDay) async {
    String monthStr = focusedDay.month.toString().padLeft(2, '0');
    String yearStr = focusedDay.year.toString();
    String startDate = '$yearStr-$monthStr-01';
    String nextMonthStr =
        ((focusedDay.month + 1) % 12).toString().padLeft(2, '0');
    String nextYearStr =
        (focusedDay.month == 12 ? focusedDay.year + 1 : focusedDay.year)
            .toString();
    if (focusedDay.month == 12) nextMonthStr = '01';
    String endDate = '$nextYearStr-$nextMonthStr-01';

    QuerySnapshot incomeSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userDocId)
        .collection('thu_nhap')
        .where('ngay', isGreaterThanOrEqualTo: startDate)
        .where('ngay', isLessThan: endDate)
        .get();
    monthlyIncome = incomeSnapshot.docs
        .fold(0.0, (sum, doc) => sum + (doc['so_tien'] as num).toDouble());

    QuerySnapshot expenseSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userDocId)
        .collection('chi_tieu')
        .where('ngay', isGreaterThanOrEqualTo: startDate)
        .where('ngay', isLessThan: endDate)
        .get();
    monthlyExpense = expenseSnapshot.docs
        .fold(0.0, (sum, doc) => sum + (doc['so_tien'] as num).toDouble());

    monthlyTotal = monthlyIncome - monthlyExpense;
  }

// Hàm tải chi tiết chi tiêu
  Future<void> _loadExpenseDetails(
      String userDocId, DateTime focusedDay) async {
    String monthStr = focusedDay.month.toString().padLeft(2, '0');
    String yearStr = focusedDay.year.toString();
    String startDate = '$yearStr-$monthStr-01';
    String nextMonthStr =
        ((focusedDay.month + 1) % 12).toString().padLeft(2, '0');
    String nextYearStr =
        (focusedDay.month == 12 ? focusedDay.year + 1 : focusedDay.year)
            .toString();
    if (focusedDay.month == 12) nextMonthStr = '01';
    String endDate = '$nextYearStr-$nextMonthStr-01';

    // Truy vấn danh mục chi tiêu
    QuerySnapshot categorySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userDocId)
        .collection('danh_muc_chi')
        .get();

    Map<String, Map<String, dynamic>> tempExpenseDetails = {};
    for (var doc in categorySnapshot.docs) {
      tempExpenseDetails[doc.id] = {
        'name': doc['ten_muc_chi'] as String,
        'image': doc['image'] as String,
        'total': 0.0,
        'transactions': <Map<String, dynamic>>[], // Thêm danh sách giao dịch
      };
    }

    // Truy vấn chi tiêu và tính tổng tiền
    QuerySnapshot expenseSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userDocId)
        .collection('chi_tieu')
        .where('ngay', isGreaterThanOrEqualTo: startDate)
        .where('ngay', isLessThan: endDate)
        .get();

    int transactionIndex = 0; // Thêm index để sử dụng cho Dismissible
    for (var doc in expenseSnapshot.docs) {
      String categoryId = doc['muc_chi_tieu'] as String;
      double amount = (doc['so_tien'] as num).toDouble();
      String dateStr = doc['ngay'] as String;
      DateTime date = DateTime.parse(dateStr);

      if (tempExpenseDetails.containsKey(categoryId)) {
        tempExpenseDetails[categoryId]!['total'] += amount;
        tempExpenseDetails[categoryId]!['transactions'].add({
          'id': doc.id,
          'date': date,
          'rawDate': dateStr,
          'amount': -amount,
          'rawAmount': amount,
          'note': doc['ghi_chu'] as String,
          'walletId': doc['loai_vi'] as String,
          'categoryId': categoryId,
          'index': transactionIndex++, // Thêm index cho giao dịch
        });
      }
    }

    // Chỉ giữ lại các danh mục có tổng tiền > 0
    expenseDetails = Map.fromEntries(
        tempExpenseDetails.entries.where((entry) => entry.value['total'] > 0));
  }

// Hàm tải chi tiết thu nhập
  Future<void> _loadIncomeDetails(String userDocId, DateTime focusedDay) async {
    String monthStr = focusedDay.month.toString().padLeft(2, '0');
    String yearStr = focusedDay.year.toString();
    String startDate = '$yearStr-$monthStr-01';
    String nextMonthStr =
        ((focusedDay.month + 1) % 12).toString().padLeft(2, '0');
    String nextYearStr =
        (focusedDay.month == 12 ? focusedDay.year + 1 : focusedDay.year)
            .toString();
    if (focusedDay.month == 12) nextMonthStr = '01';
    String endDate = '$nextYearStr-$nextMonthStr-01';

    // Truy vấn danh mục thu nhập
    QuerySnapshot categorySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userDocId)
        .collection('danh_muc_thu')
        .get();

    Map<String, Map<String, dynamic>> tempIncomeDetails = {};
    for (var doc in categorySnapshot.docs) {
      tempIncomeDetails[doc.id] = {
        'name': doc['ten_muc_thu'] as String,
        'image': doc['image'] as String,
        'total': 0.0,
        'transactions': <Map<String, dynamic>>[], // Thêm danh sách giao dịch
      };
    }

    // Truy vấn thu nhập và tính tổng tiền
    QuerySnapshot incomeSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userDocId)
        .collection('thu_nhap')
        .where('ngay', isGreaterThanOrEqualTo: startDate)
        .where('ngay', isLessThan: endDate)
        .get();

    int transactionIndex = 0; // Thêm index để sử dụng cho Dismissible
    for (var doc in incomeSnapshot.docs) {
      String categoryId = doc['muc_thu_nhap'] as String;
      double amount = (doc['so_tien'] as num).toDouble();
      String dateStr = doc['ngay'] as String;
      DateTime date = DateTime.parse(dateStr);

      if (tempIncomeDetails.containsKey(categoryId)) {
        tempIncomeDetails[categoryId]!['total'] += amount;
        tempIncomeDetails[categoryId]!['transactions'].add({
          'id': doc.id,
          'date': date,
          'rawDate': dateStr,
          'amount': amount,
          'rawAmount': amount,
          'note': doc['ghi_chu'] as String,
          'walletId': doc['loai_vi'] as String,
          'categoryId': categoryId,
          'index': transactionIndex++, // Thêm index cho giao dịch
        });
      }
    }

    // Chỉ giữ lại các danh mục có tổng tiền > 0
    incomeDetails = Map.fromEntries(
        tempIncomeDetails.entries.where((entry) => entry.value['total'] > 0));
  }

  void _changeMonth(int step) {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + step, 1);
      _loadData(); // Tải lại toàn bộ dữ liệu khi thay đổi tháng
    });
  }

  // Điều hướng đến màn hình chi tiết danh mục
  void _viewCategoryDetails(String categoryId, bool isIncome) async {
    // Định dạng _focusedDay thành chuỗi "MM/yyyy"
    String formattedMonth = DateFormat("MM/yyyy", 'vi_VN').format(_focusedDay);

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LichSuTheoDanhMuc(
          categoryId: categoryId,
          isIncome: isIncome,
          selectedMonth: formattedMonth, // Truyền chuỗi đã định dạng
        ),
      ),
    );

    // Nếu result là true, tức là có giao dịch được cập nhật hoặc xóa, làm mới dữ liệu
    if (result == true) {
      await _loadData();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          "Báo cáo",
          style: TextStyle(
            fontSize: 20.sp,
            color: Colors.white,
          ),
        ),
        showMenuButton: true,
        onMenuPressed: () => Scaffold.of(context).openDrawer(),
        showSearchIcon: true,
        onSearchPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Mainpage(selectedIndex: 13)),
          );
        },
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Thanh chọn tháng
              Padding(
                padding: EdgeInsets.fromLTRB(16.0.w, 19.0.h, 16.0.w, 0.0.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.chevron_left, size: 30.sp),
                      onPressed: () => _changeMonth(-1),
                    ),
                    Container(
                      width: 250.w,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1.w),
                        borderRadius: BorderRadius.circular(8.r),
                        color: Colors.white,
                      ),
                      child: Center(
                        child: Text(
                          DateFormat("MM/yyyy", 'vi_VN').format(_focusedDay),
                          style: TextStyle(
                              fontSize: 18.sp, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.chevron_right, size: 30.sp),
                      onPressed: () => _changeMonth(1),
                    ),
                  ],
                ),
              ),

              // Summary card
              Padding(
                padding: EdgeInsets.only(top: 19.h, left: 16.w, right: 16.w),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  padding: EdgeInsets.fromLTRB(0.w, 10.h, 0.w, 13.h),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                NumberFormat.currency(
                                        locale: 'vi_VN', symbol: 'đ')
                                    .format(-monthlyExpense),
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFFE0000),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 1.w,
                            height: 35.h,
                            color: const Color(0xFFD9D9D9),
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                NumberFormat.currency(
                                        locale: 'vi_VN', symbol: 'đ')
                                    .format(monthlyIncome),
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4ABD57),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 5.h),
                        height: 1.h,
                        color: const Color(0xFFD9D9D9),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 14.h),
                        child: Expanded(
                          child: Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Tổng: ',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                NumberFormat.currency(
                                        locale: 'vi_VN', symbol: 'đ')
                                    .format(monthlyTotal),
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tab selector
              Padding(
                padding: EdgeInsets.only(top: 19.h, left: 16.w, right: 16.w),
                child: BaoCaoTab(
                  isExpenseSelected: isExpenseSelected,
                  onTabSelected: (isExpense) {
                    setState(() {
                      isExpenseSelected = isExpense;
                    });
                  },
                ),
              ),

              // Content based on selected tab
              Padding(
                padding: EdgeInsets.only(
                    top: 5.h, left: 16.w, right: 16.w, bottom: 50.h),
                child: isExpenseSelected
                    ? Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 8.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            padding: EdgeInsets.only(top: 16.h, bottom: 5.h),
                            child: Column(
                              children: [
                                // Chart section
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.w),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Biểu đồ',
                                            style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(width: 4.w),
                                          DropdownButtonHideUnderline(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10.r),
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    blurRadius: 6,
                                                    offset: Offset(0, 2.h),
                                                  ),
                                                ],
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12.w,
                                                  vertical: 4.h),
                                              child: DropdownButton<String>(
                                                value: selectedChartChiTieu,
                                                items: ["Cột", "Tròn"]
                                                    .map((chart) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: chart,
                                                    child: Text(
                                                      chart,
                                                      style: TextStyle(
                                                        fontSize: 14.sp,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                                onChanged: (value) {
                                                  if (value != null) {
                                                    setState(() {
                                                      selectedChartChiTieu =
                                                          value;
                                                    });
                                                  }
                                                },
                                                isDense: true,
                                                dropdownColor: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10.r),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 35.h),
                                      SizedBox(
                                        height: 300.h,
                                        child: getSelectedChartChiTieu(),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 0.h),
                                  height: 1.h,
                                  color: const Color(0xFFD9D9D9),
                                ),
                                // Expense details section
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 9.w),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: 19.h, left: 0.w),
                                        child: Row(
                                          children: [
                                            Text(
                                              'Chi tiết chi tiêu',
                                              style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.black,
                                              ),
                                            ),
                                            SizedBox(width: 4.w),
                                            Image.asset(
                                              'assets/images/dropdown_icon.png',
                                              width: 16.w,
                                              height: 16.h,
                                              fit: BoxFit.contain,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: 10.h, left: 0.w),
                                        child: expenseDetails.isEmpty
                                            ? Text(
                                                'Không có chi tiêu trong tháng này',
                                                style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black54,
                                                ),
                                              )
                                            : Column(
                                                children: expenseDetails.entries
                                                    .map((entry) {
                                                  return GestureDetector(
                                                    onTap: () =>
                                                        _viewCategoryDetails(
                                                            entry.key,
                                                            false), // Gọi hàm điều hướng
                                                    child: Column(
                                                      children: [
                                                        SizedBox(height: 8.h),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Image.asset(
                                                                  entry.value[
                                                                      'image'],
                                                                  width: 30.w,
                                                                  height: 30.h,
                                                                  fit: BoxFit
                                                                      .contain,
                                                                ),
                                                                SizedBox(
                                                                    width: 6.w),
                                                                Text(
                                                                  entry.value[
                                                                      'name'],
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Montserrat',
                                                                    fontSize:
                                                                        15.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  NumberFormat.currency(
                                                                          locale:
                                                                              'vi_VN',
                                                                          symbol:
                                                                              'đ')
                                                                      .format(-entry
                                                                              .value[
                                                                          'total']),
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Montserrat',
                                                                    fontSize:
                                                                        15.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    color: Color(
                                                                        0xFFFE0000),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    width: 4.w),
                                                                Icon(
                                                                  Icons
                                                                      .chevron_right,
                                                                  color: Colors
                                                                      .black,
                                                                  size: 20.sp,
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: 5.h),
                                                          height: 0.5.h,
                                                          color: const Color(
                                                              0xFFD9D9D9),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 8.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            padding: EdgeInsets.only(top: 16.h, bottom: 5.h),
                            child: Column(
                              children: [
                                // Chart section
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.w),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Biểu đồ',
                                            style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(width: 4.w),
                                          DropdownButtonHideUnderline(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10.r),
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    blurRadius: 6,
                                                    offset: Offset(0, 2.h),
                                                  ),
                                                ],
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12.h,
                                                  vertical: 4.w),
                                              child: DropdownButton<String>(
                                                value: selectedChartThuNhap,
                                                items: ["Cột", "Tròn"]
                                                    .map((chart) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: chart,
                                                    child: Text(
                                                      chart,
                                                      style: TextStyle(
                                                        fontSize: 14.sp,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                                onChanged: (value) {
                                                  if (value != null) {
                                                    setState(() {
                                                      selectedChartThuNhap =
                                                          value;
                                                    });
                                                  }
                                                },
                                                isDense: true,
                                                dropdownColor: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10.r),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 35.h),
                                      SizedBox(
                                        height: 300.h,
                                        child: getSelectedChartThuNhap(),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 0.h),
                                  height: 1.h,
                                  color: const Color(0xFFD9D9D9),
                                ),
                                // Income details section
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 9.w),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: 19.h, left: 0.w),
                                        child: Row(
                                          children: [
                                            Text(
                                              'Chi tiết thu nhập',
                                              style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.black,
                                              ),
                                            ),
                                            SizedBox(width: 4.w),
                                            Image.asset(
                                              'assets/images/dropdown_icon.png',
                                              width: 16.w,
                                              height: 16.h,
                                              fit: BoxFit.contain,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: 10.h, left: 0.w),
                                        child: incomeDetails.isEmpty
                                            ? Text(
                                                'Không có thu nhập trong tháng này',
                                                style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black54,
                                                ),
                                              )
                                            : Column(
                                                children: incomeDetails.entries
                                                    .map((entry) {
                                                  return GestureDetector(
                                                    onTap: () =>
                                                        _viewCategoryDetails(
                                                            entry.key,
                                                            true), // Gọi hàm điều hướng
                                                    child: Column(
                                                      children: [
                                                        SizedBox(height: 8.h),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Image.asset(
                                                                  entry.value[
                                                                      'image'],
                                                                  width: 30.w,
                                                                  height: 30.w,
                                                                  fit: BoxFit
                                                                      .contain,
                                                                ),
                                                                SizedBox(
                                                                    width: 6.w),
                                                                Text(
                                                                  entry.value[
                                                                      'name'],
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Montserrat',
                                                                    fontSize:
                                                                        15.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  NumberFormat.currency(
                                                                          locale:
                                                                              'vi_VN',
                                                                          symbol:
                                                                              'đ')
                                                                      .format(entry
                                                                              .value[
                                                                          'total']),
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Montserrat',
                                                                    fontSize:
                                                                        15.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    color: Color(
                                                                        0xFF4ABD57),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    width: 4.w),
                                                                Icon(
                                                                  Icons
                                                                      .chevron_right,
                                                                  color: Colors
                                                                      .black,
                                                                  size: 20.sp,
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: 5.h),
                                                          height: 0.5.h,
                                                          color: const Color(
                                                              0xFFD9D9D9),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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

  Widget getSelectedChartChiTieu() {
    if (userDocId == null) {
      return const Center(child: CircularProgressIndicator());
    }
    switch (selectedChartChiTieu) {
      case "Cột":
        return BarChart_ChiTieu(userDocId: userDocId!, focusedDay: _focusedDay);
      case "Tròn":
        return DonutChart_ChiTieu(
            userDocId: userDocId!, focusedDay: _focusedDay);
      default:
        return const SizedBox();
    }
  }

  Widget getSelectedChartThuNhap() {
    if (userDocId == null) {
      return const Center(child: CircularProgressIndicator());
    }
    switch (selectedChartThuNhap) {
      case "Cột":
        return BarChart_ThuNhap(userDocId: userDocId!, focusedDay: _focusedDay);
      case "Tròn":
        return DonutChart_ThuNhap(
            userDocId: userDocId!, focusedDay: _focusedDay);
      default:
        return const SizedBox();
    }
  }
}
