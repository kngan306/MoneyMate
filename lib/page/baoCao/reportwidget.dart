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

    for (var doc in expenseSnapshot.docs) {
      String categoryId = doc['muc_chi_tieu'] as String;
      double amount = (doc['so_tien'] as num).toDouble();
      if (tempExpenseDetails.containsKey(categoryId)) {
        tempExpenseDetails[categoryId]!['total'] += amount;
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

    for (var doc in incomeSnapshot.docs) {
      String categoryId = doc['muc_thu_nhap'] as String;
      double amount = (doc['so_tien'] as num).toDouble();
      if (tempIncomeDetails.containsKey(categoryId)) {
        tempIncomeDetails[categoryId]!['total'] += amount;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Báo cáo",
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
                padding: const EdgeInsets.fromLTRB(16.0, 19.0, 16.0, 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, size: 30),
                      onPressed: () => _changeMonth(-1),
                    ),
                    Container(
                      width: 250,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Center(
                        child: Text(
                          DateFormat("MM/yyyy", 'vi_VN').format(_focusedDay),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, size: 30),
                      onPressed: () => _changeMonth(1),
                    ),
                  ],
                ),
              ),

              // Summary card
              Padding(
                padding: const EdgeInsets.only(top: 19, left: 16, right: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.fromLTRB(0, 7, 0, 13),
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
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFFE0000),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 35,
                            color: const Color(0xFFD9D9D9),
                          ),
                          Expanded(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                NumberFormat.currency(
                                        locale: 'vi_VN', symbol: 'đ')
                                    .format(monthlyIncome),
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4ABD57),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 7),
                        height: 1,
                        color: const Color(0xFFD9D9D9),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: SizedBox(
                          width: 159,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Tổng',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                NumberFormat.currency(
                                        locale: 'vi_VN', symbol: 'đ')
                                    .format(monthlyTotal),
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 17,
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
                padding: const EdgeInsets.only(top: 19, left: 16, right: 16),
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
                padding: const EdgeInsets.only(
                    top: 5, left: 16, right: 16, bottom: 50),
                child: isExpenseSelected
                    ? Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.only(top: 16, bottom: 5),
                            child: Column(
                              children: [
                                // Chart section
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                            'Biểu đồ',
                                            style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          DropdownButtonHideUnderline(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    blurRadius: 6,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 4),
                                              child: DropdownButton<String>(
                                                value: selectedChartChiTieu,
                                                items: ["Cột", "Tròn"]
                                                    .map((chart) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: chart,
                                                    child: Text(
                                                      chart,
                                                      style: const TextStyle(
                                                        fontSize: 14,
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
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 35),
                                      SizedBox(
                                        height: 300,
                                        child: getSelectedChartChiTieu(),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 0),
                                  height: 1,
                                  color: const Color(0xFFD9D9D9),
                                ),
                                // Expense details section
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 9),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 19, left: 0),
                                        child: Row(
                                          children: [
                                            const Text(
                                              'Chi tiết chi tiêu',
                                              style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: 15,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Image.asset(
                                              'assets/images/dropdown_icon.png',
                                              width: 16,
                                              height: 16,
                                              fit: BoxFit.contain,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10, left: 0),
                                        child: expenseDetails.isEmpty
                                            ? const Text(
                                                'Không có chi tiêu trong tháng này',
                                                style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black54,
                                                ),
                                              )
                                            : Column(
                                                children: expenseDetails.entries
                                                    .map((entry) {
                                                  return Column(
                                                    children: [
                                                      const SizedBox(height: 8),
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
                                                                width: 30,
                                                                height: 30,
                                                                fit: BoxFit
                                                                    .contain,
                                                              ),
                                                              const SizedBox(
                                                                  width: 6),
                                                              Text(
                                                                entry.value[
                                                                    'name'],
                                                                style:
                                                                    const TextStyle(
                                                                  fontFamily:
                                                                      'Montserrat',
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Text(
                                                            NumberFormat.currency(
                                                                    locale:
                                                                        'vi_VN',
                                                                    symbol: 'đ')
                                                                .format(-entry
                                                                        .value[
                                                                    'total']),
                                                            style:
                                                                const TextStyle(
                                                              fontFamily:
                                                                  'Montserrat',
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: Color(
                                                                  0xFFFE0000),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .only(top: 5),
                                                        height: 0.5,
                                                        color: const Color(
                                                            0xFFD9D9D9),
                                                      ),
                                                    ],
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
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.only(top: 16, bottom: 5),
                            child: Column(
                              children: [
                                // Chart section
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                            'Biểu đồ',
                                            style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          DropdownButtonHideUnderline(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    blurRadius: 6,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 4),
                                              child: DropdownButton<String>(
                                                value: selectedChartThuNhap,
                                                items: ["Cột", "Tròn"]
                                                    .map((chart) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: chart,
                                                    child: Text(
                                                      chart,
                                                      style: const TextStyle(
                                                        fontSize: 14,
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
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 35),
                                      SizedBox(
                                        height: 300,
                                        child: getSelectedChartThuNhap(),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 0),
                                  height: 1,
                                  color: const Color(0xFFD9D9D9),
                                ),
                                // Income details section
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 9),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 19, left: 0),
                                        child: Row(
                                          children: [
                                            const Text(
                                              'Chi tiết thu nhập',
                                              style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: 15,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Image.asset(
                                              'assets/images/dropdown_icon.png',
                                              width: 16,
                                              height: 16,
                                              fit: BoxFit.contain,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10, left: 0),
                                        child: incomeDetails.isEmpty
                                            ? const Text(
                                                'Không có thu nhập trong tháng này',
                                                style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black54,
                                                ),
                                              )
                                            : Column(
                                                children: incomeDetails.entries
                                                    .map((entry) {
                                                  return Column(
                                                    children: [
                                                      const SizedBox(height: 8),
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
                                                                width: 30,
                                                                height: 30,
                                                                fit: BoxFit
                                                                    .contain,
                                                              ),
                                                              const SizedBox(
                                                                  width: 6),
                                                              Text(
                                                                entry.value[
                                                                    'name'],
                                                                style:
                                                                    const TextStyle(
                                                                  fontFamily:
                                                                      'Montserrat',
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Text(
                                                            NumberFormat.currency(
                                                                    locale:
                                                                        'vi_VN',
                                                                    symbol: 'đ')
                                                                .format(entry
                                                                        .value[
                                                                    'total']),
                                                            style:
                                                                const TextStyle(
                                                              fontFamily:
                                                                  'Montserrat',
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: Color(
                                                                  0xFF4ABD57),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .only(top: 5),
                                                        height: 0.5,
                                                        color: const Color(
                                                            0xFFD9D9D9),
                                                      ),
                                                    ],
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
