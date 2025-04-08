import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmailInput extends StatefulWidget {
  final TextEditingController controller; // Thêm biến controller

  const EmailInput({Key? key, required this.controller}) : super(key: key); // Nhận controller từ bên ngoài

  @override
  _EmailInputState createState() => _EmailInputState();
}

class _EmailInputState extends State<EmailInput> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 18.w,
        vertical: 4.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50.r),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.07),
            blurRadius: 4.r,
            offset: Offset(0, 4.r),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF1E201E),
          width: 1.w,
        ),
      ),
      child: Row(
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/email_icon.png',
                width: 32.w,
                height: 32.h,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 14.w),
              Container(
                width: 1.w,
                height: 35.h,
                color: const Color.fromRGBO(30, 32, 30, 0.1),
              ),
              SizedBox(width: 14.w),
            ],
          ),
          Expanded(
            child: TextField(
              controller: widget.controller, // Sử dụng controller từ widget
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
                fontFamily: 'Montserrat',
                color: Colors.black,
              ),
              decoration: InputDecoration(
                hintText: 'moneymate@gmail.com',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Montserrat',
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.clear,
              color: Colors.black,
              size: 22.r,
            ),
            onPressed: () {
              widget.controller.clear(); // Xóa nội dung của controller
            },
          ),
        ],
      ),
    );
  }
}