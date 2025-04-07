import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dangkyfinal_screen.dart';
import '../../../widgets/input/otp_input.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class XacThucOTP extends StatefulWidget {
  final String verificationId;

  final String phoneNumber; // Thêm biến để nhận số điện thoại

  const XacThucOTP(
      {Key? key, required this.verificationId, required this.phoneNumber})
      : super(key: key);

  @override
  State<XacThucOTP> createState() => _XacThucOTPState();
}

class _XacThucOTPState extends State<XacThucOTP> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _verifyOtp() async {
    final otp = _otpControllers.map((controller) => controller.text).join();
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      // Navigate to the final registration screen with the phone number
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DangKyFinal(
            phoneNumber: widget.phoneNumber,
            email: '',
          ), // Truyền số điện thoại và email vào đây
        ),
      );
    } catch (e) {
      print('Failed to verify OTP: $e');
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid OTP')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFECDFCC),
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
                        // fontSize: 25,
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
                padding: EdgeInsets.fromLTRB(16.0.w, 16.0.h, 16.0.w, 205.0.h),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.0.r),
                    topRight: Radius.circular(40.0.r),
                  ),
                ),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/lock.png',
                      width: 82.w,
                      height: 82.h,
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 14.0.r),
                      child: Text(
                        'Nhập mã OTP',
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 14.0.h),
                      child: Text(
                        'Vui lòng nhập mã OTP bao gồm 6 số vừa được gửi về số điện thoại ${widget.phoneNumber}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: Colors.black,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 30.0.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          6, // Đảm bảo số lượng ô nhập là 6
                          (index) => OtpInputField(
                            controller: _otpControllers[index],
                            focusNode: _focusNodes[index],
                            onChanged: (value) {
                              if (value.length == 1) {
                                if (index < 5) {
                                  // Chỉ số không vượt quá 5
                                  _focusNodes[index + 1].requestFocus();
                                }
                              } else if (value.isEmpty && index > 0) {
                                _focusNodes[index - 1]
                                    .requestFocus(); // Quay lại ô trước nếu xóa ký tự
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: 30.0.h), // Giữ khoảng cách trên
                      child: ElevatedButton(
                        // onPressed: () {
                        //   // Navigator.pushNamed(context, AppRoutes.registerFinal);
                        //   Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //       builder: (context) => const DangKyFinal(),
                        //     ),
                        //   );
                        // },
                        onPressed: _verifyOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E201E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.0.r),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 12.0.h, horizontal: 62.0.w),
                        ),
                        child: Text(
                          'Xác thực',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 16.0.h),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black,
                            fontFamily: 'Montserrat',
                          ),
                          children: [
                            const TextSpan(text: 'Chưa nhận được mã? '),
                            WidgetSpan(
                              child: GestureDetector(
                                // onTap: _resendOtp,
                                child: const Text(
                                  'Gửi lại',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                    fontFamily: 'Montserrat',
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
            ],
          ),
        ),
      ),
    );
  }
}
