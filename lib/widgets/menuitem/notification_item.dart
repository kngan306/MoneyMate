import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationItem extends StatelessWidget {
  final String category;
  final String timeAgo;
  final String message;
  final bool isFirst;
  final bool isLast;

  const NotificationItem({
    Key? key,
    required this.category,
    required this.timeAgo,
    required this.message,
    required this.isFirst,
    required this.isLast,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 15.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: isFirst ? Radius.circular(10.r) : Radius.zero,
          topRight: isFirst ? Radius.circular(10.r) : Radius.zero,
          bottomLeft: isLast ? Radius.circular(10.r) : Radius.zero,
          bottomRight: isLast ? Radius.circular(10.r) : Radius.zero,
        ),
        border: Border(
          bottom: BorderSide(
            color: const Color(0x1A000000),
            width: 1.w,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with category and time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Montserrat',
                ),
              ),
              Text(
                timeAgo,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          // Notification message
          Text(
            message,
            style: TextStyle(
              color: Colors.black,
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }
}