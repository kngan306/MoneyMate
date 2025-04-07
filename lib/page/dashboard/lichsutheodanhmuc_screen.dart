import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/custom_app_bar.dart';


class LichSuTheoDanhMuc extends StatefulWidget {
  final String categoryId; // ID của danh mục
  final bool isIncome; // Xác định là thu nhập hay chi tiêu
  final String selectedMonth; // Tháng được chọn từ Dashboard

  const LichSuTheoDanhMuc({
    Key? key,
    required this.categoryId,
    required this.isIncome,
    required this.selectedMonth,
  }) : super(key: key);

  @override
  _LichSuTheoDanhMucState createState() => _LichSuTheoDanhMucState();
}

class _LichSuTheoDanhMucState extends State<LichSuTheoDanhMuc> {
  late DateTime _focusedDay;
  String? userDocId;
  String categoryName = '';
  String categoryImage = '';
  List<Map<String, dynamic>> transactions = []; // Danh sách giao dịch

  @override
  void initState() {
    super.initState();
    int monthIndex = int.parse(widget.selectedMonth.split(' ')[1]);
    _focusedDay = DateTime(DateTime.now().year, monthIndex, 1);
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
        await _loadCategoryDetails();
        await _loadTransactions();
        setState(() {});
      }
    }
  }

  // Tải thông tin danh mục (tên và hình ảnh)
  Future<void> _loadCategoryDetails() async {
    if (userDocId != null) {
      DocumentSnapshot categoryDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userDocId)
          .collection(widget.isIncome ? 'danh_muc_thu' : 'danh_muc_chi')
          .doc(widget.categoryId)
          .get();

      if (categoryDoc.exists) {
        setState(() {
          categoryName =
              categoryDoc[widget.isIncome ? 'ten_muc_thu' : 'ten_muc_chi']
                  as String;
          categoryImage =
              categoryDoc['image'] as String? ?? ''; // Nếu null thì gán rỗng
        });
      }
    }
  }

  // Tải danh sách giao dịch
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

    QuerySnapshot transactionSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userDocId)
        .collection(widget.isIncome ? 'thu_nhap' : 'chi_tieu')
        .where(widget.isIncome ? 'muc_thu_nhap' : 'muc_chi_tieu',
            isEqualTo: widget.categoryId)
        .where('ngay', isGreaterThanOrEqualTo: startDate)
        .where('ngay', isLessThan: endDate)
        .get();

    setState(() {
      transactions = transactionSnapshot.docs.map((doc) {
        return {
          'date': doc['ngay'] as String,
          'amount': (doc['so_tien'] as num).toDouble(),
        };
      }).toList();
    });
  }

  void _changeMonth(int step) async {
    // Cập nhật _focusedDay
    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + step, 1);
    // Gọi setState để cập nhật giao diện cho _focusedDay (tháng hiển thị)
    setState(() {});
    // Chờ _loadTransactions hoàn thành để cập nhật transactions
    await _loadTransactions();
  }

  void _deleteTransaction(String date, int index) {
    print("Deleted transaction at index $index on date $date");
    setState(() {
      transactions.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: CustomAppBar(
        title: Text(
          "Lịch sử theo danh mục",
          style: TextStyle(
            fontSize: 20.sp,
            color: Colors.white,
          ),
        ),
        showBackButton: true,
      ),
      body: SafeArea(
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

            // Category section
            Padding(
              padding: EdgeInsets.fromLTRB(16.0.w, 16.0.h, 16.0.w, 0.0.h),
              child: Row(
                children: [
                  if (categoryImage.isNotEmpty) // Chỉ hiển thị nếu có hình ảnh
                    Container(
                      width: 40.w,
                      height: 40.h,
                      child: Image.asset(
                        categoryImage,
                        width: 40.w,
                        height: 40.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                  if (categoryImage.isNotEmpty)
                    SizedBox(width: 5.w), // Khoảng cách chỉ khi có hình
                  Text(
                    categoryName.isNotEmpty ? categoryName : 'Đang tải...',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.black,
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Transaction list
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0.0.w, 0.0.h, 0.0.w, 0.0.h),
                child: Container(
                  width: double.infinity,
                  color: Colors.white,
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
                      : ListView.builder(
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            final transaction = transactions[index];
                            String rawDate = transaction['date'];
                            DateTime date = DateTime.parse(rawDate);
                            String formattedDate =
                                DateFormat('EEEE, dd/MM/yyyy', 'vi_VN')
                                    .format(date);
                            double amount = transaction['amount'];
                            String formattedAmount = NumberFormat.currency(
                                    locale: 'vi_VN', symbol: 'đ')
                                .format(widget.isIncome ? amount : -amount);

                            return Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: 16.0.w),
                              child: _buildTransactionItem(
                                date: formattedDate,
                                amount: formattedAmount,
                                index: index,
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem({
    required String date,
    required String amount,
    required int index,
  }) {
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
      child: Container(
        height: 60.h,
        margin: EdgeInsets.only(top: 1.h),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date,
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.black,
                fontSize: 15.sp,
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: widget.isIncome
                    ? const Color(0xFF4ABD57)
                    : const Color(0xFFFE0000),
                fontSize: 15.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
