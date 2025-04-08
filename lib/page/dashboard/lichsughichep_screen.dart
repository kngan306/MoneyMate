import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../widgets/custom_app_bar.dart';
import 'package:flutter_moneymate_01/page/chitieu_thunhap/chitieu/themkhoanchi_screen.dart';
import 'package:flutter_moneymate_01/page/chitieu_thunhap/thunhap/themkhoanthu_screen.dart';

class LichSuGhiChep extends StatefulWidget {
  const LichSuGhiChep({Key? key}) : super(key: key);

  @override
  _LichSuGhiChepState createState() => _LichSuGhiChepState();
}

class _LichSuGhiChepState extends State<LichSuGhiChep> {
  late DateTime _focusedDay;
  String? userDocId;
  Map<String, List<Map<String, dynamic>>> transactions = {};
  int transactionIndex = 0; // Để gán index cho từng giao dịch

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
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
        setState(() {});
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
    Map<String, List<Map<String, dynamic>>> tempTransactions = {};
    transactionIndex = 0;

    // Xử lý thu nhập
    for (var doc in incomeSnapshot.docs) {
      String rawDate = doc['ngay'] as String;
      DateTime parsedDate = DateTime.parse(rawDate);
      String formattedDate =
          DateFormat('dd/MM/yyyy (EEEE)', 'vi_VN').format(parsedDate);
      String categoryId = doc['muc_thu_nhap'] as String;
      double amount = (doc['so_tien'] as num).toDouble();

      if (!tempTransactions.containsKey(formattedDate)) {
        tempTransactions[formattedDate] = [];
      }

      tempTransactions[formattedDate]!.add({
        'id': doc.id, // ID của document để cập nhật sau này
        'rawDate': rawDate, // Ngày gốc để sử dụng khi chỉnh sửa
        'title': incomeCategories[categoryId]?['name'] ?? 'Không xác định',
        'amount':
            NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(amount),
        'rawAmount': amount, // Số tiền gốc để sử dụng khi chỉnh sửa
        'isIncome': true,
        'iconUrl': incomeCategories[categoryId]?['image'] ?? '',
        'index': transactionIndex++,
        'note': doc['ghi_chu'] as String,
        'walletId': doc['loai_vi'] as String,
        'categoryId': categoryId,
      });
    }

    // Xử lý chi tiêu
    for (var doc in expenseSnapshot.docs) {
      String rawDate = doc['ngay'] as String;
      DateTime parsedDate = DateTime.parse(rawDate);
      String formattedDate =
          DateFormat('dd/MM/yyyy (EEEE)', 'vi_VN').format(parsedDate);
      String categoryId = doc['muc_chi_tieu'] as String;
      double amount = (doc['so_tien'] as num).toDouble();

      if (!tempTransactions.containsKey(formattedDate)) {
        tempTransactions[formattedDate] = [];
      }

      tempTransactions[formattedDate]!.add({
        'id': doc.id, // ID của document để cập nhật sau này
        'rawDate': rawDate, // Ngày gốc để sử dụng khi chỉnh sửa
        'title': expenseCategories[categoryId]?['name'] ?? 'Không xác định',
        'amount':
            NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(-amount),
        'rawAmount': amount, // Số tiền gốc để sử dụng khi chỉnh sửa
        'isIncome': false,
        'iconUrl': expenseCategories[categoryId]?['image'] ?? '',
        'index': transactionIndex++,
        'note': doc['ghi_chu'] as String,
        'walletId': doc['loai_vi'] as String,
        'categoryId': categoryId,
      });
    }

    // Sắp xếp giao dịch theo ngày
    var sortedKeys = tempTransactions.keys.toList()
      ..sort((a, b) {
        DateTime dateA = DateFormat('dd/MM/yyyy (EEEE)', 'vi_VN').parse(a);
        DateTime dateB = DateFormat('dd/MM/yyyy (EEEE)', 'vi_VN').parse(b);
        return dateA.compareTo(dateB);
      });

    Map<String, List<Map<String, dynamic>>> sortedTransactions = {};
    for (var key in sortedKeys) {
      sortedTransactions[key] = tempTransactions[key]!;
    }

    setState(() {
      transactions = sortedTransactions;
    });
  }

  void _changeMonth(int step) async {
    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + step, 1);
    setState(() {});
    await _loadTransactions();
  }

// Xóa giao dịch trên Firestore và làm mới danh sách
  void _deleteTransaction(String date, int index) async {
    if (userDocId == null) return;

    // Tìm giao dịch cần xóa
    final transaction =
        transactions[date]!.firstWhere((t) => t['index'] == index);
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
    setState(() {});
    // Không gọi Navigator.pop(context, true) để tránh quay lại DashboardWidget
  }

  // Điều hướng đến màn hình chỉnh sửa
  void _editTransaction(Map<String, dynamic> transaction) async {
    final isIncome = transaction['isIncome'] == true;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF1E201E),
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              isIncome ? 'Chỉnh sửa khoản thu' : 'Chỉnh sửa khoản chi',
              style: TextStyle(
                fontSize: 20.sp,
                color: Colors.white,
              ),
            ),
          ),
          body: isIncome
              ? ThemKhoanThu(
                  transaction: {
                    'id': transaction['id'],
                    'date': transaction['rawDate'],
                    'amount': transaction['rawAmount'],
                    'note': transaction['note'],
                    'walletId': transaction['walletId'],
                    'categoryId': transaction['categoryId'],
                  },
                )
              : ThemKhoanChi(
                  transaction: {
                    'id': transaction['id'],
                    'date': transaction['rawDate'],
                    'amount': transaction['rawAmount'],
                    'note': transaction['note'],
                    'walletId': transaction['walletId'],
                    'categoryId': transaction['categoryId'],
                  },
                ),
        ),
      ),
    );

    if (result == true) {
      await _loadTransactions();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          "Lịch sử ghi chép",
          style: TextStyle(
            fontSize: 20.sp,
            color: Colors.white,
          ),
        ),
        showBackButton: true,
      ),
      body: Container(
        color: const Color(0xFFF5F5F5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
            // Transactions list
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 19.h),
                child: transactions.isEmpty
                    ? Center(
                        child: Text(
                          'Không có giao dịch trong tháng này',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 15.sp,
                            color: Colors.black54,
                          ),
                        ),
                      )
                    : ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          ...transactions.entries.map((entry) {
                            String date = entry.key;
                            List<Map<String, dynamic>> transactionList =
                                entry.value;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildDateHeader(date),
                                ...transactionList.map((transaction) {
                                  return _buildTransactionItem(
                                    iconUrl: transaction['iconUrl'],
                                    title: transaction['title'],
                                    amount: transaction['amount'],
                                    isIncome: transaction['isIncome'],
                                    index: transaction['index'],
                                    date: date,
                                  );
                                }).toList(),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateHeader(String date) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF697565),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Text(
        date,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 14.sp,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTransactionItem({
    required String iconUrl,
    required String title,
    required String amount,
    required bool isIncome,
    required int index,
    required String date,
  }) {
    final transaction =
        transactions[date]!.firstWhere((t) => t['index'] == index);

    return Dismissible(
      key: Key(index.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _deleteTransaction(date, index);
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20.0.w),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: () => _editTransaction(transaction), // Gọi hàm chỉnh sửa
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(
                    iconUrl,
                    width: 35.w,
                    height: 35.h,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 15.sp,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              Text(
                amount,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 15.sp,
                  color: isIncome
                      ? const Color(0xFF4ABD57)
                      : const Color(0xFFFE0000),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
