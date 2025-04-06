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
  String selectedChartChiTieu = "Cột"; // Giá trị mặc định
  String selectedChartThuNhap = "Tròn"; // Giá trị mặc định

  late DateTime _focusedDay;
  bool isExpenseSelected = true; // Track if "Chi tiêu" is selected

  String? userDocId; // Biến để lưu ID của document người dùng
  double monthlyIncome = 0.0; // Tổng thu nhập của tháng được chọn
  double monthlyExpense = 0.0; // Tổng chi tiêu của tháng được chọn
  double monthlyTotal = 0.0; // Tổng (thu nhập - chi tiêu) của tháng được chọn

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now(); // Khởi tạo với ngày hiện tại
    _loadData(); // Tải dữ liệu khi khởi tạo
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
        await _calculateMonthlyData(userDocId!, _focusedDay);
        setState(() {});
      } else {
        print('Không tìm thấy thông tin người dùng trong Firestore.');
      }
    }
  }

  // Hàm tính dữ liệu thu nhập và chi tiêu theo tháng
  Future<void> _calculateMonthlyData(
      String userDocId, DateTime focusedDay) async {
    String monthStr =
        focusedDay.month.toString().padLeft(2, '0'); // Định dạng tháng (01-12)
    String yearStr = focusedDay.year.toString(); // Năm hiện tại

    // Xác định ngày bắt đầu và kết thúc của tháng
    String startDate = '$yearStr-$monthStr-01'; // Ngày đầu tháng
    String nextMonthStr =
        ((focusedDay.month + 1) % 12).toString().padLeft(2, '0');
    String nextYearStr =
        (focusedDay.month == 12 ? focusedDay.year + 1 : focusedDay.year)
            .toString();
    if (focusedDay.month == 12)
      nextMonthStr = '01'; // Tháng 12 thì sang tháng 1 năm sau
    String endDate =
        '$nextYearStr-$nextMonthStr-01'; // Ngày đầu tháng tiếp theo

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

    // Tính tổng của tháng
    monthlyTotal = monthlyIncome - monthlyExpense;
  }

  void _changeMonth(int step) {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + step, 1);
      _loadData(); // Tải lại dữ liệu khi thay đổi tháng
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Báo cáo",
        showMenuButton: true, // Hiển thị nút menu (Drawer)
        onMenuPressed: () {
          Scaffold.of(context).openDrawer(); // Mở drawer từ MainPage
        },
        showSearchIcon: true, // ✅ Hiển thị icon tìm kiếm
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
                // padding: const EdgeInsets.symmetric(vertical: 8.0),
                padding: const EdgeInsets.fromLTRB(16.0, 19.0, 16.0, 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.chevron_left, size: 30),
                      onPressed: () => _changeMonth(-1),
                    ),
                    Container(
                      width: 250,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Center(
                        // Căn giữa nội dung
                        child: Text(
                          DateFormat("MM/yyyy", 'vi_VN').format(_focusedDay),
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.chevron_right, size: 30),
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
                      // Income and expense summary
                      Row(
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  Text(
                                    NumberFormat.currency(
                                            locale: 'vi_VN', symbol: 'đ')
                                        .format(-monthlyExpense),
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFFE0000),
                                    ),
                                  ),
                                ],
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
                              child: Column(
                                children: [
                                  Text(
                                    NumberFormat.currency(
                                            locale: 'vi_VN', symbol: 'đ')
                                        .format(monthlyIncome),
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF4ABD57),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Divider
                      Container(
                        margin: const EdgeInsets.only(top: 7),
                        height: 1,
                        color: const Color(0xFFD9D9D9),
                      ),

                      // Net balance
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: SizedBox(
                          width: 159,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
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
                                style: TextStyle(
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
                  isExpenseSelected:
                      isExpenseSelected, // Pass the boolean value
                  onTabSelected: (isExpense) {
                    setState(() {
                      isExpenseSelected = isExpense; // Update the selected tab
                    });
                  },
                ),
              ),

              // Content based on selected tab
              Padding(
                  padding: const EdgeInsets.only(
                      top: 5, left: 16, right: 16, bottom: 50),
                  child: isExpenseSelected
                      // Content for "Chi tiêu"
                      ? Column(
                          children: [
                            // Chart and details section
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding:
                                  const EdgeInsets.only(top: 16, bottom: 5),
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
                                        // Chart title
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
                                            // Image.asset(
                                            //   'assets/images/dropdown_icon.png',
                                            //   width: 16,
                                            //   height: 16,
                                            //   fit: BoxFit.contain,
                                            // ),
                                            DropdownButtonHideUnderline(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10), // 📌 Bo góc mềm mại
                                                  color: Colors
                                                      .white, // 📌 Màu nền dropdown
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(
                                                              0.1), // 📌 Hiệu ứng bóng
                                                      blurRadius: 6,
                                                      offset: Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical:
                                                        4), // 📌 Thu gọn dropdown
                                                child: DropdownButton<String>(
                                                  value: selectedChartChiTieu,
                                                  items: [
                                                    "Cột",
                                                    "Tròn",
                                                  ].map((chart) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: chart,
                                                      child: Text(
                                                        chart,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors
                                                              .black87, // 📌 Màu chữ rõ nét
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
                                                  isDense:
                                                      true, // 📌 Giúp dropdown nhỏ gọn hơn
                                                  dropdownColor: Colors
                                                      .white, // 📌 Màu nền của danh sách dropdown
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10), // 📌 Bo góc của danh sách dropdown
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 35),
                                        SizedBox(
                                          height:
                                              300, // Điều chỉnh chiều cao tùy ý
                                          child: getSelectedChartChiTieu(),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Divider
                                  Container(
                                    margin: const EdgeInsets.only(top: 0),
                                    height: 1,
                                    color: const Color(0xFFD9D9D9),
                                  ),

                                  // Expense details section
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 9),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Details title
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

                                        // Expense items
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 10, left: 0),
                                          child: Column(
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
                                                        'assets/images/cate5.png',
                                                        width: 30,
                                                        height: 30,
                                                        fit: BoxFit.contain,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      const Text(
                                                        'Ăn uống',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Montserrat',
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const Text(
                                                    '-240,000 đ',
                                                    style: TextStyle(
                                                      fontFamily: 'Montserrat',
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Color(0xFFFE0000),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    top: 5),
                                                height: 0.5,
                                                color: const Color(0xFFD9D9D9),
                                              ),
                                              const SizedBox(height: 9),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Image.asset(
                                                        'assets/images/cate17.png',
                                                        width: 30,
                                                        height: 30,
                                                        fit: BoxFit.contain,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      const Text(
                                                        'Mỹ phẩm',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Montserrat',
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const Text(
                                                    '-500,000 đ',
                                                    style: TextStyle(
                                                      fontFamily: 'Montserrat',
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Color(0xFFFE0000),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    top: 5),
                                                height: 0.5,
                                                color: const Color(0xFFD9D9D9),
                                              ),
                                              const SizedBox(height: 9),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Image.asset(
                                                        'assets/images/cate25.png',
                                                        width: 30,
                                                        height: 30,
                                                        fit: BoxFit.contain,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      const Text(
                                                        'Tiền điện',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Montserrat',
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const Text(
                                                    '-630,000 đ',
                                                    style: TextStyle(
                                                      fontFamily: 'Montserrat',
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Color(0xFFFE0000),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    top: 5),
                                                height: 0.5,
                                                color: const Color(0xFFD9D9D9),
                                              ),
                                              const SizedBox(height: 9),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Image.asset(
                                                        'assets/images/cate26.png',
                                                        width: 30,
                                                        height: 30,
                                                        fit: BoxFit.contain,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      const Text(
                                                        'Tiền nước',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Montserrat',
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const Text(
                                                    '-318,000 đ',
                                                    style: TextStyle(
                                                      fontFamily: 'Montserrat',
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Color(0xFFFE0000),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    top: 5),
                                                height: 0.5,
                                                color: const Color(0xFFD9D9D9),
                                              ),
                                              const SizedBox(height: 9),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Image.asset(
                                                        'assets/images/cate23.png',
                                                        width: 30,
                                                        height: 30,
                                                        fit: BoxFit.contain,
                                                      ),
                                                      const SizedBox(width: 5),
                                                      const Text(
                                                        'Tiền wifi',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Montserrat',
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const Text(
                                                    '-220,000 đ',
                                                    style: TextStyle(
                                                      fontFamily: 'Montserrat',
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Color(0xFFFE0000),
                                                    ),
                                                  ),
                                                ],
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
                        )

                      // Content for "Thu nhập"
                      : Column(
                          children: [
                            // Chart and details section
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding:
                                  const EdgeInsets.only(top: 16, bottom: 5),
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
                                        // Chart title
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
                                            // Image.asset(
                                            //   'assets/images/dropdown_icon.png',
                                            //   width: 16,
                                            //   height: 16,
                                            //   fit: BoxFit.contain,
                                            // ),
                                            DropdownButtonHideUnderline(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10), // 📌 Bo góc mềm mại
                                                  color: Colors
                                                      .white, // 📌 Màu nền dropdown
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(
                                                              0.1), // 📌 Hiệu ứng bóng
                                                      blurRadius: 6,
                                                      offset: Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical:
                                                        4), // 📌 Thu gọn dropdown
                                                child: DropdownButton<String>(
                                                  value: selectedChartThuNhap,
                                                  items: [
                                                    "Cột",
                                                    "Tròn",
                                                  ].map((chart) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: chart,
                                                      child: Text(
                                                        chart,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors
                                                              .black87, // 📌 Màu chữ rõ nét
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
                                                  isDense:
                                                      true, // 📌 Giúp dropdown nhỏ gọn hơn
                                                  dropdownColor: Colors
                                                      .white, // 📌 Màu nền của danh sách dropdown
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10), // 📌 Bo góc của danh sách dropdown
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 35),
                                        SizedBox(
                                          height:
                                              300, // Điều chỉnh chiều cao tùy ý
                                          child: getSelectedChartThuNhap(),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Divider
                                  Container(
                                    margin: const EdgeInsets.only(top: 0),
                                    height: 1,
                                    color: const Color(0xFFD9D9D9),
                                  ),

                                  // Expense details section
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 9),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Details title
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

                                        // Expense items
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 10, left: 0),
                                          child: Column(
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
                                                        'assets/images/cate29.png',
                                                        width: 30,
                                                        height: 30,
                                                        fit: BoxFit.contain,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      const Text(
                                                        'Tiền lương',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Montserrat',
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const Text(
                                                    '+1,000,000 đ',
                                                    style: TextStyle(
                                                      fontFamily: 'Montserrat',
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Color(0xFF4ABD57),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    top: 5),
                                                height: 0.5,
                                                color: const Color(0xFFD9D9D9),
                                              ),
                                              const SizedBox(height: 9),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Image.asset(
                                                        'assets/images/cate33.png',
                                                        width: 30,
                                                        height: 30,
                                                        fit: BoxFit.contain,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      const Text(
                                                        'Phụ cấp',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Montserrat',
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const Text(
                                                    '+500,000 đ',
                                                    style: TextStyle(
                                                      fontFamily: 'Montserrat',
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Color(0xFF4ABD57),
                                                    ),
                                                  ),
                                                ],
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
                        )),
            ],
          ),
        ),
      ),
    );
  }

  /// 🖼 Hiển thị biểu đồ dựa trên lựa chọn
  Widget getSelectedChartChiTieu() {
    switch (selectedChartChiTieu) {
      case "Cột":
        return const BarChart_ChiTieu();
      case "Tròn":
        return const DonutChart_ChiTieu();
      default:
        return const SizedBox();
    }
  }

  Widget getSelectedChartThuNhap() {
    switch (selectedChartThuNhap) {
      case "Cột":
        return const BarChart_ThuNhap();
      case "Tròn":
        return const DonutChart_ThuNhap();
      default:
        return const SizedBox();
    }
  }
}
