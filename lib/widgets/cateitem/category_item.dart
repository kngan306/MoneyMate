import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoryItem extends StatelessWidget {
  final String imageUrl;
  final String label;
  final bool isSelected;
  final VoidCallback onTap; // Callback khi nhấn vào

  const CategoryItem({
    Key? key,
    required this.imageUrl,
    required this.label,
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
        // width: 90,
        // height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.r),
          border: isSelected ? Border.all(color: Colors.black, width: 1.w) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Căn giữa nội dung
          children: [
            Image.asset(
              imageUrl,
              width: 35.w,
              height: 35.h,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 5.h),
            // Cập nhật widget Text để giới hạn chiều dài
            Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
                fontFamily: 'Montserrat',
              ),
              textAlign: TextAlign.center,
              maxLines: 1, // Giới hạn số dòng
              overflow: TextOverflow.ellipsis, // Hiển thị dấu "..." nếu quá dài
            ),
          ],
        ),
      ),
    );
  }
}
