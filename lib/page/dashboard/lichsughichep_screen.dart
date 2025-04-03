import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LichSuGhiChep extends StatefulWidget {
  const LichSuGhiChep({Key? key}) : super(key: key);

  @override
  _LichSuGhiChepState createState() => _LichSuGhiChepState();
}

class _LichSuGhiChepState extends State<LichSuGhiChep> {
  late DateTime _focusedDay;

  // This map stores transactions by date to check if there are any transactions left for that day
  Map<String, List<Map<String, dynamic>>> transactions = {
    '03/03/2025 (Thứ 2)': [
      {  
        'title': 'Tiền lương',
        'amount': '+5,000,000 đ',
        'isIncome': true,
        'iconUrl': 'assets/images/cate29.png',
        'index': 0
      },
    ],
    '05/03/2025 (Thứ 7)': [
      {
        'title': 'Tiền điện',
        'amount': '-630,000 đ',
        'isIncome': false,
        'iconUrl': 'assets/images/cate25.png',
        'index': 1
      },
      {
        'title': 'Tiền nước',
        'amount': '-318,000 đ',
        'isIncome': false,
        'iconUrl': 'assets/images/cate26.png',
        'index': 2
      },
    ],
    '08/03/2025 (Thứ 7)': [
      {
        'title': 'Mỹ phẩm',
        'amount': '-500,000 đ',
        'isIncome': false,
        'iconUrl': 'assets/images/mypham.png',
        'index': 3
      },
    ],
    '09/03/2025 (Chủ nhật)': [
      {
        'title': 'Mỹ phẩm',
        'amount': '-500,000 đ',
        'isIncome': false,
        'iconUrl': 'assets/images/mypham.png',
        'index': 4
      },
      {
        'title': 'Ăn uống',
        'amount': '-240,000 đ',
        'isIncome': false,
        'iconUrl': 'assets/images/food.png',
        'index': 5
      },
    ],
    '11/03/2025 (Thứ 3)': [
      {
        'title': 'Tiền wifi',
        'amount': '-220,000 đ',
        'isIncome': false,
        'iconUrl': 'assets/images/cate23.png',
        'index': 6
      },
    ],
  };

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

    // Remove the transaction from the list
    setState(() {
      transactions[date]
          ?.removeWhere((transaction) => transaction['index'] == index);

      // If there are no more transactions for that date, remove the date header too
      if (transactions[date]?.isEmpty ?? true) {
        transactions.remove(date);
      }
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
            // Transactions list
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 19),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // Iterate through the date groups and display them
                    ...transactions.entries.map((entry) {
                      String date = entry.key;
                      List<Map<String, dynamic>> transactionList = entry.value;

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
    required int index,
    required String date,
  }) {
    return Dismissible(
      key: Key(index.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        // Handle the delete action when swiped
        _deleteTransaction(date, index);
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
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
