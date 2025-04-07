import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RegistrationTab extends StatelessWidget {
  final String icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const RegistrationTab({
    Key? key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 13.w,
          vertical: 14.h,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50.r),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.07),
              blurRadius: 4.r,
              offset: Offset(0.w, 4.h),
            ),
          ],
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1E201E)
                : const Color.fromRGBO(0, 0, 0, 0.2),
            width: 1.w,
          ),
        ),
        child: Row(
          children: [
            Image.asset(
              icon,
              width: 18.w,
              height: 18.h,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 5.w),
            Text(
              label,
              style: TextStyle(
                color: Colors.black,
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
      ),
    );
  }
}