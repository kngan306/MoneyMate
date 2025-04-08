import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../../widgets/input/email_input.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../login/dangnhap_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QuenMatKhau extends StatefulWidget {
  const QuenMatKhau({Key? key}) : super(key: key);

  @override
  State<QuenMatKhau> createState() => _QuenMatKhauState();
}

class _QuenMatKhauState extends State<QuenMatKhau> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    String email = _emailController.text.trim();
    if (email.isEmpty) {
      // Hiển thị thông báo lỗi nếu email trống
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập email')),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Đã gửi email khôi phục mật khẩu. Vui lòng kiểm tra hộp thư của bạn.')),
      );
      // Chuyển hướng đến màn hình ResetPassword với email đã nhập
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DangNhap()),
      );
    } catch (e) {
      // Hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Có lỗi xảy ra: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECDFCC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding:
                    // const EdgeInsets.only(left: 16.0, right: 16.0, top: 25.0),
                    EdgeInsets.only(left: 16.0.w, right: 16.0.w, top: 16.0.h),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.arrow_back,
                          size: 26.sp, color: Colors.black),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Quên mật khẩu',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0.sp,
                            color: Colors.black,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                // padding: const EdgeInsets.only(top: 30.0),
                padding: EdgeInsets.only(top: 20.0.h),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 60.w,
                      height: 60.h,
                    ),
                    Text(
                      'MoneyMate',
                      style: TextStyle(
                        fontSize: 21.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.52.sp,
                        color: Color(0xFF1E201E),
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: 20.0.h),
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 230.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.r),
                    topRight: Radius.circular(40.r),
                  ),
                ),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/locked.png',
                      width: 82.w,
                      height: 82.h,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      'Nhập email',
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      'Vui lòng nhập chính xác email mà bạn đã đăng ký để được xác thực.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    SizedBox(height: 30.h),
                    EmailInput(
                        controller:
                            _emailController), // Truyền controller vào đây
                    SizedBox(height: 27.h),
                    // button Gửi
                    ElevatedButton(
                      onPressed: _resetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(30, 32, 30, 1),
                        foregroundColor: Colors.white,
                        minimumSize: Size(150.w, 0),
                        padding: EdgeInsets.symmetric(
                            horizontal: 60.w, vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.r),
                        ),
                      ),
                      child: Text(
                        'Gửi',
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          fontFamily: 'Montserrat',
                        ),
                        children: [
                          const TextSpan(text: 'Không nhớ chính xác email? '),
                          TextSpan(
                            text: 'Thử cách khác',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Tính năng này chưa được hỗ trợ'),
                                  ),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
