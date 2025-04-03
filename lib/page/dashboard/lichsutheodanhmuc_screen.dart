import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LichSuTheoDanhMuc extends StatefulWidget {
  const LichSuTheoDanhMuc({Key? key}) : super(key: key);

  @override
  _LichSuTheoDanhMucState createState() => _LichSuTheoDanhMucState();
}

class _LichSuTheoDanhMucState extends State<LichSuTheoDanhMuc> {
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now(); // Initialize to the current date
  }

  void _changeMonth(int step) {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + step, 1);
    });
  }

  void _deleteTransaction(String date, int index) {
    // Handle the delete action, for now just print the index
    print("Deleted transaction at index $index on date $date");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E201E),
        title: const Text(
          'Lịch sử ghi chép',
          style: TextStyle(
            fontFamily: 'Montserrat',
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Thanh chọn tháng
            Padding(
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
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: Center(
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

            // Category section
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    child: Image.asset(
                      'assets/images/mypham.png', // Thay thế bằng đường dẫn đến hình ảnh của bạn
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Mỹ phẩm',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Transaction list
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
              child: Container(
                width: double.infinity,
                color: Colors.white,
                child: ListView(
                  shrinkWrap: true, // Đảm bảo ListView chiếm không gian cần thiết
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildTransactionItem(
                        date: 'Thứ 7, 08/03/2025',
                        amount: '-500,000 đ',
                        index: 0,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildTransactionItem(
                        date: 'Chủ nhật, 09/03/2025',
                        amount: '-500,000 đ',
                        index: 1,
                      ),
                    ),
                  ],
                ),
              ),
            )
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
      key: Key(index.toString()), // Mỗi mục giao dịch cần có một key duy nhất
      direction: DismissDirection.endToStart, // Chỉ cho phép kéo từ phải qua trái
      onDismissed: (direction) {
        // Gọi hàm _deleteTransaction khi mục bị xóa
        _deleteTransaction(date, index);
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        height: 60,
        margin: const EdgeInsets.only(top: 1),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date,
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.black,
                fontSize: 15,
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: const Color(0xFFFE0000),
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
