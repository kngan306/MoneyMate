import 'package:flutter/material.dart';
import 'package:flutter_moneymate_01/page/authentication/login/dangnhap_screen.dart';
import 'package:flutter_moneymate_01/page/authentication/register/dangky_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChaoMung extends StatelessWidget {
  const ChaoMung({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          // constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 65.h),
              // logo image
              Image.asset(
                'assets/images/logo.png', // Replace with actual asset path
                width: 70.w,
                height: 70.h,
                fit: BoxFit.contain,
              ),

              // App name
              Padding(
                padding: EdgeInsets.only(top: 5.h),
                child: Text(
                  'MoneyMate',
                  style: TextStyle(
                    color: Color(0xFF3C3D37),
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.52.sp,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),

              // Tagline
              Padding(
                padding: EdgeInsets.only(top: 14.h),
                child: Text(
                  'Bạn đồng hành quản lý tiền bạc',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                    color: Colors.black,
                    letterSpacing: 1.5.sp,
                  ),
                ),
              ),

              // Main image
              Padding(
                padding: EdgeInsets.only(top: 60.h),
                child: Image.asset(
                  'assets/images/main_image.png',
                  width: 250.w,
                  fit: BoxFit.contain,
                ),
              ),

              // Bottom section with buttons
              Container(
                width: double.infinity,
                // padding: const EdgeInsets.fromLTRB(50, 40, 50, 36),
                // padding: const EdgeInsets.fromLTRB(50, 40, 50, 94),
                padding: EdgeInsets.fromLTRB(50.w, 65.h, 50.w, 94.h),
                decoration: BoxDecoration(
                  color: Color(0xFFECDFCC), // Cream
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.r),
                    topRight: Radius.circular(40.r),
                  ),
                ),
                child: Column(
                  children: [
                    // Login button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          // Navigator.pushNamed(context, AppRoutes.login);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DangNhap(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Color(0xFF697565), // Dark Green
                            width: 5.w,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 17.h),
                        ),
                        child: Text(
                          'Đăng nhập',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat',
                            color: Color(0xFF697565), // Dark Green
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 25.h),
                    // Register button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DangKy(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF697565), // Dark Green
                          foregroundColor: const Color(0xFFECDFCC), // Cream
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 17.h),
                        ),
                        child: Text(
                          'Đăng ký',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat',
                          ),
                        ),
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
