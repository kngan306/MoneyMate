import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../login/dangnhap_screen.dart';
import 'xacthucotp_screen.dart';
import 'xacthucemail_screen.dart';
import '../../../widgets/input/phone_input.dart';
import '../../../widgets/input/email_input.dart';
import '../../../widgets/tab/registration_tab.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DangKy extends StatefulWidget {
  const DangKy({Key? key}) : super(key: key);

  @override
  State<DangKy> createState() => _DangKyState();
}

class _DangKyState extends State<DangKy> {
  bool isPhoneSelected = true; // Mặc định chọn Số điện thoại

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
                margin: EdgeInsets.only(top: 20.0.h),
                padding: EdgeInsets.fromLTRB(16.0.w, 16.0.h, 16.0.w, 222.0.h),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.r),
                    topRight: Radius.circular(40.r),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: RegistrationTab(
                            icon: isPhoneSelected
                                ? 'assets/images/verify_icon.png'
                                : 'assets/images/verify2_icon.png',
                            label: 'Số điện thoại',
                            isSelected: isPhoneSelected,
                            onTap: () {
                              setState(() {
                                isPhoneSelected = true;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 17.w),
                        Expanded(
                          child: RegistrationTab(
                            icon: isPhoneSelected
                                ? 'assets/images/verify2_icon.png'
                                : 'assets/images/verify_icon.png',
                            label: 'Email',
                            isSelected: !isPhoneSelected,
                            onTap: () {
                              setState(() {
                                isPhoneSelected = false;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 45.h),
                    if (isPhoneSelected) ...[
                      Text(
                        'Nhập số điện thoại',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      SizedBox(height: 19.h),
                      Text(
                        'Vui lòng nhập chính xác số điện thoại để nhận mã OTP và tiếp tục xác thực.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      SizedBox(height: 30.h),
                      const PhoneInput(),
                      SizedBox(height: 27.h),
                    ],
                    if (!isPhoneSelected) ...[
                      Text(
                        'Nhập email',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      SizedBox(height: 19.h),
                      Text(
                        'Vui lòng nhập chính xác email để nhận mã OTP và tiếp tục xác thực.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      SizedBox(height: 30.h),
                      const EmailInput(),
                      SizedBox(height: 27.h),
                    ],
                    ElevatedButton(
                      onPressed: () {
                        if (isPhoneSelected) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const XacThucOTP(),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const XacThucEmail(),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF333333),
                        foregroundColor: Colors.white,
                        minimumSize: Size(150.w, 0.h),
                        padding: EdgeInsets.symmetric(
                          horizontal: 60.w,
                          vertical: 12.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.r),
                        ),
                      ),
                      child: Text(
                        'Gửi',
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Montserrat',
                        ),
                        children: [
                          const TextSpan(text: 'Đã có tài khoản? '),
                          TextSpan(
                            text: 'Đăng nhập',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const DangNhap(),
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
