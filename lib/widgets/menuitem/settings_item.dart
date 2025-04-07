import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsItem extends StatelessWidget {
  final String title;
  final String value;
  final String icon; // Thay đổi kiểu dữ liệu của icon
  final bool hasBorder;

  const SettingsItem({
    Key? key,
    required this.title,
    required this.value,
    required this.icon, // Giữ nguyên
    this.hasBorder = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      padding: EdgeInsets.symmetric(horizontal: 13.w),
      decoration: BoxDecoration(
        border: hasBorder
            ? Border(
                bottom: BorderSide(
                  color: Color(0x1A000000),
                  width: 1.w,
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Montserrat', // Sử dụng font Montserrat đã thêm
              fontSize: 15.sp,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Montserrat', // Sử dụng font Montserrat đã thêm
              fontSize: 15.sp,
              color: Colors.black,
            ),
          ),
          SizedBox(width: 7.w),
          // Sử dụng Image.asset để lấy biểu tượng từ assets
          Image.asset(
            icon, // Sử dụng icon từ tham số
            width: 20.w,
            height: 20.h,
          ),
        ],
      ),
    );
  }
}