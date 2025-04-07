import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BaoCaoTab extends StatelessWidget {
  final bool isExpenseSelected; // Track if "Chi tiêu" is selected
  final ValueChanged<bool> onTabSelected; // Callback to notify parent

  const BaoCaoTab({
    Key? key,
    required this.isExpenseSelected,
    required this.onTabSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0, left: 0, right: 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
        ),
        padding: EdgeInsets.symmetric(vertical: 9.h), // Ensure no padding misalignment
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => onTabSelected(true), // Select "Chi tiêu"
                    child: Column(
                      children: [
                        Text(
                          'Chi tiêu',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w500,
                            color: isExpenseSelected ? Colors.black : const Color(0xFFD9D9D9),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 4.h), // Adjust this value to move the underline down
                          width: 135.w, // Adjust width to fit "Chi tiêu"
                          height: 2.h,
                          color: isExpenseSelected ? Colors.black : Colors.transparent, // Change color based on selection
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 1.w,
                  height: 35.h,
                  color: const Color(0xFFD9D9D9),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => onTabSelected(false), // Select "Thu nhập"
                    child: Column(
                      children: [
                        Text(
                          'Thu nhập',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w500,
                            color: isExpenseSelected ? const Color(0xFFD9D9D9) : Colors.black,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 4.h), // Adjust this value to move the underline down
                          width: 135.w, // Adjust width to fit "Thu nhập"
                          height: 2.h,
                          color: isExpenseSelected ? Colors.transparent : Colors.black, // Change color based on selection
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}