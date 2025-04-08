import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoryItem extends StatelessWidget {
  final String imageUrl;
  final bool isSelected;
  final VoidCallback onTap; // Callback khi nhấn vào

  const CategoryItem({
    Key? key,
    required this.imageUrl,
    this.isSelected = false,
    required this.onTap, // Thêm tham số onTap
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Sử dụng GestureDetector để xử lý nhấn
      onTap: onTap, // Gọi callback khi nhấn
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 13.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.w),
          border: isSelected ? Border.all(color: Colors.black, width: 1.w) : null,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Căn giữa theo chiều dọc
          children: [
            Image.asset(
              imageUrl,
              width: 40.w,
              height: 40.h,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
