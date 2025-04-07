import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../login/dangnhap_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class DangKyFinal extends StatefulWidget {
  const DangKyFinal({Key? key}) : super(key: key);

  @override
  State<DangKyFinal> createState() => _DangKyFinalState();
}

class _DangKyFinalState extends State<DangKyFinal> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final TextEditingController _phoneController =
      TextEditingController(text: '0123456789');
  final TextEditingController _emailController =
      TextEditingController(text: 'kimngan@gmail.com');
  final TextEditingController _usernameController =
      TextEditingController(text: 'kngan306');
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
                    EdgeInsets.only(left: 16.0.w, right: 16.0.w, top: 16.0.h),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.arrow_back,
                        size: 26.sp,
                        color: Colors.black,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Đăng ký',
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
                padding: EdgeInsets.only(top: 20.h),
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

              // Form section
              Container(
                margin: EdgeInsets.only(top: 20.0.h),
                padding: EdgeInsets.fromLTRB(16.0.w, 16.0.h, 16.0.w, 25.0.h),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.r),
                    topRight: Radius.circular(40.r),
                  ),
                ),
                child: Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Phone number field
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/phone_icon.png', // Replace with actual asset path
                            width: 27.w,
                            height: 27.h,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Số điện thoại',
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 7.h),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 14.h),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.r),
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 1.w,
                            ),
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          fontFamily: 'Montserrat',
                        ),
                      ),

                      // Email field
                      SizedBox(height: 21.h),
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/email_icon.png', // Replace with actual asset path
                            width: 27.w,
                            height: 27.h,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 7.h),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 14.h),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.r),
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 1.w,
                            ),
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          fontFamily: 'Montserrat',
                        ),
                      ),

                      // Username field
                      SizedBox(height: 21.h),
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/user_icon.png', // Replace with actual asset path
                            width: 27.w,
                            height: 27.h,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Tên đăng nhập',
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 7.h),
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 14.w, vertical: 14.h),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.r),
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 1.w,
                            ),
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          fontFamily: 'Montserrat',
                        ),
                      ),

                      // Password field
                      SizedBox(height: 21.h),
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/password_icon.png', // Replace with actual asset path
                            width: 27.w,
                            height: 27.h,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Mật khẩu',
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 7.h),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 17.w, vertical: 12.h),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.r),
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 1.w,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          fontFamily: 'Montserrat',
                        ),
                      ),

                      // Confirm password field
                      SizedBox(height: 21.h),
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/password_icon.png', // Replace with actual asset path
                            width: 27.w,
                            height: 27.h,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Xác nhận mật khẩu',
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 7.h),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: !_isConfirmPasswordVisible,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 17.w, vertical: 12.h),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.r),
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 1.w,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          fontFamily: 'Montserrat',
                        ),
                      ),

                      // Register button
                      SizedBox(height: 21.h),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigator.pushNamed(context, AppRoutes.login);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DangNhap(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E201E),
                            foregroundColor: Colors.white,
                            minimumSize: Size(200.w, 48.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50.r),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 64.w, vertical: 12.h),
                          ),
                          child: Text(
                            'Đăng ký',
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                      ),

                      // Login link
                      SizedBox(height: 21.h),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            // Navigate to login screen
                          },
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                                fontFamily: 'Montserrat',
                              ),
                              children: [
                                const TextSpan(text: 'Đã có tài khoản? '),
                                TextSpan(
                                  text: 'Đăng nhập',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      // Navigator.pushNamed(
                                      //     context, AppRoutes.login);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const DangNhap(),
                                        ),
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
