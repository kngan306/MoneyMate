import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TimKiemBaoCaoThuChi extends StatelessWidget {
  const TimKiemBaoCaoThuChi({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E201E),
        title: Text(
          'Tìm kiếm (Toàn thời gian)',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 20.sp,
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
            // Search input field
            Padding(
              padding: EdgeInsets.fromLTRB(16.0.w, 30.0.h, 16.0.w, 0.0.h),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: const Color(0x80000000),
                    width: 1.w,
                  ),
                ),
                padding:
                    EdgeInsets.symmetric(horizontal: 22.w, vertical: 11.h),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/search_icon.png',
                      width: 28.w,
                      height: 28.h,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Text(
                        'tiền',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 15.sp,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Summary section
            Padding(
              padding: EdgeInsets.only(top: 30.h, left: 16.w, right: 16.w),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                padding:
                    EdgeInsets.symmetric(horizontal: 15.w, vertical: 17.h),
                child: Row(
                  children: [
                    // Expenses column
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Chi tiêu',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 15.sp,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            '1,168,000 đ',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Montserrat',
                              fontSize: 15.sp,
                              color: const Color(0xFFFE0000),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Divider
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 13.w),
                      child: Container(
                        width: 1.w,
                        height: 30.h,
                        color: const Color(0xFFD9D9D9),
                      ),
                    ),

                    // Income column
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Thu nhập',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 15.sp,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            '1,000,000 đ',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Montserrat',
                              fontSize: 15.sp,
                              color: const Color(0xFF4ABD57),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Divider
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 13.w),
                      child: Container(
                        width: 1.w,
                        height: 30.h,
                        color: const Color(0xFFD9D9D9),
                      ),
                    ),

                    // Total column
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Tổng',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 15.sp,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            '-168,000 đ',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Montserrat',
                              fontSize: 15.sp,
                              color: const Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Transactions list
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 30.sp), // Thêm margin ở đây
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // First date group
                    _buildDateHeader('03/03/2025 (Thứ 2)'),
                    _buildTransactionItem(
                      iconUrl: 'assets/images/cate29.png',
                      title: 'Tiền lương',
                      amount: '+1,000,000 đ',
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
  }) {
    return Container(
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
              color:
                  isIncome ? const Color(0xFF4ABD57) : const Color(0xFFFE0000),
            ),
          ),
        ],
      ),
    );
  }
}
