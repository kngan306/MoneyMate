import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoryItem extends StatelessWidget {
  final String categoryKey;
  final String title;
  final String iconUrl;
  final String arrowUrl;
  final bool isFirstItem;
  final bool isLastItem;
  final bool isChecked; // Thay đổi ở đây
  final Function(bool) onCheckboxChanged;
  final bool hasCheckmark;

  const CategoryItem({
    Key? key,
    required this.categoryKey,
    required this.title,
    required this.iconUrl,
    required this.arrowUrl,
    required this.isFirstItem,
    required this.isLastItem,
    required this.isChecked, // Thay đổi ở đây
    required this.onCheckboxChanged,
    this.hasCheckmark = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: !isLastItem
            ? Border(
                bottom: BorderSide(
                  color: Color.fromRGBO(0, 0, 0, 0.1),
                  width: 1.w,
                ),
              )
            : null,
        borderRadius: BorderRadius.only(
          topLeft: isFirstItem ? Radius.circular(10.r) : Radius.zero,
          topRight: isFirstItem ? Radius.circular(10.r) : Radius.zero,
          bottomLeft: isLastItem ? Radius.circular(10.r) : Radius.zero,
          bottomRight: isLastItem ? Radius.circular(10.r) : Radius.zero,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  // Cập nhật trạng thái checkbox
                  onCheckboxChanged(!isChecked);
                },
                child: Container(
                  width: 20.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5.r),
                    border: Border.all(
                      color: Colors.black,
                      width: 1.w,
                    ),
                  ),
                  child: isChecked
                      ? Center(
                          child: Image.asset(
                            'assets/images/check_icon.png', // Hình ảnh checkbox từ assets
                            width: 15.w,
                            height: 15.h,
                            fit: BoxFit.contain,
                          ),
                        )
                      : null,
                ),
              ),
              SizedBox(width: 13.w),
              Image.asset(
                iconUrl, // Hình ảnh biểu tượng danh mục từ assets
                width: 35.w,
                height: 35.h,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 13.w),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 15.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          Image.asset(
            arrowUrl, // Hình ảnh mũi tên từ assets
            width: 20.w,
            height: 20.h,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
