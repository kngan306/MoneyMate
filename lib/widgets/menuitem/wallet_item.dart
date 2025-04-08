import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WalletItem extends StatelessWidget {
  final String iconPath; // Đường dẫn đến biểu tượng
  final String title;
  final String amount;
  final bool showAction;
  final String actionText;

  const WalletItem({
    Key? key,
    required this.iconPath,
    required this.title,
    required this.amount,
    this.showAction = false,
    this.actionText = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4.r,
            offset: Offset(0, 4.r),
          ),
        ],
      ),
      child: Padding(
        padding:  EdgeInsets.all(15.0.w),
        child: Row(
          children: [
            // Icon
            Image.asset(
              iconPath, // Sử dụng Image.asset để lấy biểu tượng từ assets
              width: 40.w,
              height: 40.h,
            ),

            SizedBox(width: 21.w),

            // Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Montserrat',
                  ),
                ),

                SizedBox(height: 2.h),

                // Amount
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontFamily: 'Montserrat',
                  ),
                ),

                SizedBox(height: 4.h),

                // Action button (if needed)
                if (showAction)
                  Row(
                    children: [
                      // Thay thế Container bằng Image.asset
                      Image.asset(
                        'assets/images/add_icon.png', // Đường dẫn đến biểu tượng của bạn
                        width: 20.w,
                        height: 20.h,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        actionText,
                        style: TextStyle(
                          color: Color(0xFF4ABD57),
                          fontSize: 15.sp,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
