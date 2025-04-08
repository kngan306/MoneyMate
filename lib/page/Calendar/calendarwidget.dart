import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/custom_app_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_moneymate_01/page/chitieu_thunhap/chitieu/themkhoanchi_screen.dart';
import 'package:flutter_moneymate_01/page/chitieu_thunhap/thunhap/themkhoanthu_screen.dart';

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({Key? key}) : super(key: key);

  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  String? userDocId;

  // Dữ liệu thu nhập/chi tiêu
  Map<DateTime, List<Map<String, dynamic>>> transactions = {};
  Map<DateTime, List<String>> expenses = {};
  double monthlyIncome = 0.0;
  double monthlyExpense = 0.0;
  double monthlyTotal = 0.0;

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = null;
    _loadUserData();
  }

  // Tải thông tin người dùng và dữ liệu giao dịch
  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      if (userDoc.docs.isNotEmpty) {
        userDocId = userDoc.docs.first.id;
        await _loadTransactions();
        // Kiểm tra mounted trước khi gọi setState
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  // Tải danh sách giao dịch từ Firestore
  Future<void> _loadTransactions() async {
    if (userDocId == null) return;

    String monthStr = _focusedDay.month.toString().padLeft(2, '0');
    String yearStr = _focusedDay.year.toString();
    String startDate = '$yearStr-$monthStr-01';
    String nextMonthStr =
        ((_focusedDay.month + 1) % 12).toString().padLeft(2, '0');
    String nextYearStr =
        (_focusedDay.month == 12 ? _focusedDay.year + 1 : _focusedDay.year)
            .toString();
    if (_focusedDay.month == 12) nextMonthStr = '01';
    String endDate = '$nextYearStr-$nextMonthStr-01';

    // Truy vấn thu nhập
    QuerySnapshot incomeSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userDocId)
        .collection('thu_nhap')
        .where('ngay', isGreaterThanOrEqualTo: startDate)
        .where('ngay', isLessThan: endDate)
        .get();

    // Truy vấn chi tiêu
    QuerySnapshot expenseSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userDocId)
        .collection('chi_tieu')
        .where('ngay', isGreaterThanOrEqualTo: startDate)
        .where('ngay', isLessThan: endDate)
        .get();

    // Truy vấn danh mục thu nhập
    QuerySnapshot incomeCategorySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userDocId)
        .collection('danh_muc_thu')
        .get();
    Map<String, Map<String, dynamic>> incomeCategories = {};
    for (var doc in incomeCategorySnapshot.docs) {
      incomeCategories[doc.id] = {
        'name': doc['ten_muc_thu'] as String,
        'image': doc['image'] as String,
      };
    }

    // Truy vấn danh mục chi tiêu
    QuerySnapshot expenseCategorySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userDocId)
        .collection('danh_muc_chi')
        .get();
    Map<String, Map<String, dynamic>> expenseCategories = {};
    for (var doc in expenseCategorySnapshot.docs) {
      expenseCategories[doc.id] = {
        'name': doc['ten_muc_chi'] as String,
        'image': doc['image'] as String,
      };
    }

    // Kết hợp thu nhập và chi tiêu
    Map<DateTime, List<Map<String, dynamic>>> tempTransactions = {};
    Map<DateTime, List<String>> tempExpenses = {};
    monthlyIncome = 0.0;
    monthlyExpense = 0.0;
    int transactionIndex = 0;

    // Xử lý thu nhập
    for (var doc in incomeSnapshot.docs) {
      String dateStr = doc['ngay'] as String;
      DateTime date = DateTime.parse(dateStr);
      DateTime normalizedDate = DateTime(date.year, date.month, date.day);
      String categoryId = doc['muc_thu_nhap'] as String;
      double amount = (doc['so_tien'] as num).toDouble();

      if (!tempTransactions.containsKey(normalizedDate)) {
        tempTransactions[normalizedDate] = [];
        tempExpenses[normalizedDate] = [];
      }

      tempTransactions[normalizedDate]!.add({
        'id': doc.id,
        'date': date,
        'day': DateFormat('EEEE', 'vi_VN').format(date),
        'icon': incomeCategories[categoryId]?['image'] ?? '',
        'name': incomeCategories[categoryId]?['name'] ?? 'Không xác định',
        'amount': amount,
        'isIncome': true,
        'note': doc['ghi_chu'] as String,
        'walletId': doc['loai_vi'] as String,
        'categoryId': categoryId,
        'index': transactionIndex++,
      });

      tempExpenses[normalizedDate]!.add('+$amount');
      monthlyIncome += amount;
    }

    // Xử lý chi tiêu
    for (var doc in expenseSnapshot.docs) {
      String dateStr = doc['ngay'] as String;
      DateTime date = DateTime.parse(dateStr);
      DateTime normalizedDate = DateTime(date.year, date.month, date.day);
      String categoryId = doc['muc_chi_tieu'] as String;
      double amount = (doc['so_tien'] as num).toDouble();

      if (!tempTransactions.containsKey(normalizedDate)) {
        tempTransactions[normalizedDate] = [];
        tempExpenses[normalizedDate] = [];
      }

      tempTransactions[normalizedDate]!.add({
        'id': doc.id,
        'date': date,
        'day': DateFormat('EEEE', 'vi_VN').format(date),
        'icon': expenseCategories[categoryId]?['image'] ?? '',
        'name': expenseCategories[categoryId]?['name'] ?? 'Không xác định',
        'amount': -amount,
        'isIncome': false,
        'note': doc['ghi_chu'] as String,
        'walletId': doc['loai_vi'] as String,
        'categoryId': categoryId,
        'index': transactionIndex++,
      });

      tempExpenses[normalizedDate]!.add('-$amount');
      monthlyExpense += amount;
    }

    monthlyTotal = monthlyIncome - monthlyExpense;

    // Kiểm tra mounted trước khi gọi setState
    if (mounted) {
      setState(() {
        transactions = tempTransactions;
        expenses = tempExpenses;
      });
    }
  }

  // Điều hướng đến màn hình chỉnh sửa
  void _editTransaction(Map<String, dynamic> transaction) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => transaction['isIncome']
            ? ThemKhoanThu(
                transaction: {
                  'id': transaction['id'],
                  'date': DateFormat('yyyy-MM-dd').format(transaction['date']),
                  'amount': transaction['amount'].abs(),
                  'note': transaction['note'],
                  'walletId': transaction['walletId'],
                  'categoryId': transaction['categoryId'],
                },
              )
            : ThemKhoanChi(
                transaction: {
                  'id': transaction['id'],
                  'date': DateFormat('yyyy-MM-dd').format(transaction['date']),
                  'amount': transaction['amount'].abs(),
                  'note': transaction['note'],
                  'walletId': transaction['walletId'],
                  'categoryId': transaction['categoryId'],
                },
              ),
      ),
    );

    // Nếu result là true, làm mới danh sách
    if (result == true) {
      await _loadTransactions();
      // Kiểm tra mounted trước khi gọi setState
      if (mounted) {
        setState(() {});
      }
    }
  }

  // Xóa giao dịch trên Firestore và làm mới danh sách
  void _deleteTransaction(DateTime normalizedDate, int index) async {
    if (userDocId == null) return;

    // Tìm giao dịch cần xóa
    final transaction =
        transactions[normalizedDate]!.firstWhere((t) => t['index'] == index);
    String transactionId = transaction['id'];
    bool isIncome = transaction['isIncome'];

    // Xóa giao dịch trên Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userDocId)
        .collection(isIncome ? 'thu_nhap' : 'chi_tieu')
        .doc(transactionId)
        .delete();

    // Làm mới danh sách giao dịch
    await _loadTransactions();
    // Kiểm tra mounted trước khi gọi setState
    if (mounted) {
      setState(() {});
    }
  }

  void _changeMonth(int step) async {
    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + step, 1);
    _selectedDay = null;
    setState(() {});
    await _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          "Lịch",
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Thanh chọn tháng
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0.h),
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

              // Lịch
              TableCalendar(
                locale: 'vi_VN',
                focusedDay: _focusedDay,
                firstDay: DateTime(2000),
                lastDay: DateTime(2050),
                headerVisible: false,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) async {
                  _focusedDay = focusedDay;
                  _selectedDay = null;
                  setState(() {});
                  await _loadTransactions();
                },
                daysOfWeekHeight: 30.h,
                rowHeight: 60.h,
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(),
                  todayTextStyle: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, date, focusedDay) {
                    DateTime normalizedDate =
                        DateTime(date.year, date.month, date.day);
                    List<String>? dayExpenses = expenses[normalizedDate];

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: isSameDay(date, DateTime.now())
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        if (dayExpenses != null && dayExpenses.isNotEmpty)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (dayExpenses.any((t) => t.startsWith('+')))
                                Container(
                                  margin: EdgeInsets.only(top: 3.h, right: 2.w),
                                  width: 6.w,
                                  height: 6.h,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              if (dayExpenses.any((t) => t.startsWith('-')))
                                Container(
                                  margin:
                                      const EdgeInsets.only(top: 3, left: 2),
                                  width: 6.w,
                                  height: 6.h,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                      ],
                    );
                  },
                ),
              ),

              // Thanh tổng thu nhập, chi tiêu
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSummaryColumn(
                        "Thu nhập",
                        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ')
                            .format(monthlyIncome),
                        Colors.green),
                    _buildSummaryColumn(
                        "Chi Tiêu",
                        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ')
                            .format(monthlyExpense),
                        Colors.red),
                    _buildSummaryColumn(
                        "Tổng",
                        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ')
                            .format(monthlyTotal),
                        Colors.black),
                  ],
                ),
              ),

              // Danh sách giao dịch
              Padding(
                padding: EdgeInsets.only(top: 14.0.h, bottom: 28.0.h),
                child: _buildTransactionList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryColumn(String label, String amount, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 16.sp, color: Colors.black)),
        Text(
          amount,
          style: TextStyle(
            color: color,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList() {
    // Nếu chưa chọn ngày, hiển thị tất cả giao dịch trong tháng
    List<Map<String, dynamic>> displayTransactions = [];
    if (_selectedDay == null) {
      transactions.forEach((date, transactionList) {
        displayTransactions.addAll(transactionList);
      });
    } else {
      DateTime normalizedSelectedDay =
          DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
      displayTransactions = transactions[normalizedSelectedDay] ?? [];
    }

    // Sắp xếp giao dịch theo ngày
    displayTransactions.sort((a, b) => a['date'].compareTo(b['date']));

    if (displayTransactions.isEmpty) {
      return Center(
        child: Text(
          'Không có giao dịch trong ngày này',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 15.sp,
            color: Colors.black54,
          ),
        ),
      );
    }

    // Nhóm giao dịch theo ngày
    Map<String, List<Map<String, dynamic>>> groupedTransactions = {};
    for (var transaction in displayTransactions) {
      String formattedDate =
          DateFormat('dd/MM/yyyy (EEEE)', 'vi_VN').format(transaction['date']);
      if (!groupedTransactions.containsKey(formattedDate)) {
        groupedTransactions[formattedDate] = [];
      }
      groupedTransactions[formattedDate]!.add(transaction);
    }

    return Column(
      children: groupedTransactions.entries.map((entry) {
        String date = entry.key;
        List<Map<String, dynamic>> transactionList = entry.value;
        DateTime normalizedDate = DateTime.parse(
            DateFormat('dd/MM/yyyy', 'vi_VN').parse(date).toString());

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: double.infinity,
              color: const Color(0xFF697565),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              child: Text(
                date,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white,
                ),
              ),
            ),
            ...transactionList.map((transaction) {
              return Dismissible(
                key: Key(transaction['index'].toString()),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  _deleteTransaction(normalizedDate, transaction['index']);
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 20.0.w),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: GestureDetector(
                  onTap: () => _editTransaction(transaction),
                  child: Container(
                    color: Colors.white,
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              transaction['icon'],
                              width: 35.w,
                              height: 35.w,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              transaction['name'],
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 15.sp,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          NumberFormat.currency(locale: 'vi_VN', symbol: 'đ')
                              .format(transaction['amount']),
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 15.sp,
                            color: transaction['amount'] >= 0
                                ? const Color(0xFF4ABD57)
                                : const Color(0xFFFE0000),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        );
      }).toList(),
    );
  }
}
