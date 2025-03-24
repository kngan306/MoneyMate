import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LichSuGhiChep extends StatefulWidget {
  const LichSuGhiChep({Key? key}) : super(key: key);

  @override
  _LichSuGhiChepState createState() => _LichSuGhiChepState();
}

class _LichSuGhiChepState extends State<LichSuGhiChep> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E201E),
        title: const Text(
          'Lịch sử ghi chép',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 20,
            color: Colors.white,
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
      body: Container(
        color: const Color(0xFFF5F5F5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            // Transactions list
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 19), // Thêm margin ở đây
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // First date group
                    _buildDateHeader('03/03/2025 (Thứ 2)'),
                    _buildTransactionItem(
                      iconUrl: 'assets/images/cate29.png',
                      title: 'Tiền lương',
                      amount: '+5,000,000 đ',
                      isIncome: true,
                    ),

                    // Second date group
                    _buildDateHeader('05/03/2025 (Thứ 7)'),
                    _buildTransactionItem(
                      iconUrl: 'assets/images/cate25.png',
                      title: 'Tiền điện',
                      amount: '-630,000 đ',
                      isIncome: false,
                    ),
                    _buildTransactionItem(
                      iconUrl: 'assets/images/cate26.png',
                      title: 'Tiền nước',
                      amount: '-318,000 đ',
                      isIncome: false,
                    ),

                    // Third date group
                    _buildDateHeader('08/03/2025 (Thứ 3)'),
                    _buildTransactionItem(
                      iconUrl: 'assets/images/mypham.png',
                      title: 'Mỹ phẩm',
                      amount: '-500,000 đ',
                      isIncome: false,
                    ),

                    // Four date group
                    _buildDateHeader('09/03/2025 (Chủ nhật)'),
                    _buildTransactionItem(
                      iconUrl: 'assets/images/mypham.png',
                      title: 'Mỹ phẩm',
                      amount: '-500,000 đ',
                      isIncome: false,
                    ),
                    _buildTransactionItem(
                      iconUrl: 'assets/images/food.png',
                      title: 'Ăn uống',
                      amount: '-240,000 đ',
                      isIncome: false,
                    ),

                    // Five date group
                    _buildDateHeader('11/03/2025 (Thứ 3)'),
                    _buildTransactionItem(
                      iconUrl: 'assets/images/cate23.png',
                      title: 'Tiền wifi',
                      amount: '-220,000 đ',
                      isIncome: false,
                    ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Text(
        date,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 14,
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
  }) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                iconUrl,
                width: 35,
                height: 35,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Text(
            amount,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 15,
              color:
                  isIncome ? const Color(0xFF4ABD57) : const Color(0xFFFE0000),
            ),
          ),
        ],
      ),
    );
  }
}
