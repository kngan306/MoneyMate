import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../login/dangnhap_screen.dart';
import 'xacthucotp_screen.dart';
import 'dangkyfinal_screen.dart';
import '../../../widgets/input/phone_input.dart';
import '../../../widgets/input/email_input.dart';
import '../../../widgets/tab/registration_tab.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
//import 'package:flutter_screenutil/flutter_screenutil.dart';

class DangKy extends StatefulWidget {
  const DangKy({Key? key}) : super(key: key);

  @override
  State<DangKy> createState() => _DangKyState();
}

class _DangKyState extends State<DangKy> {
  bool isPhoneSelected = true; // Mặc định chọn Số điện thoại
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    // Gọi hàm xử lý Dynamic Link
    _handleDynamicLinks();
  }

  void _handleDynamicLinks() async {
    // Xử lý link khi ứng dụng được mở từ một link
    try {
      final PendingDynamicLinkData? data = await FirebaseDynamicLinks.instance.getInitialLink();
      _navigateToDangKyFinal(data);
    } catch (e) {
      print('Error handling initial dynamic link: $e');
    }

    // Lắng nghe các Dynamic Link mới
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLink) {
      _navigateToDangKyFinal(dynamicLink);
    }).onError((error) {
      print('Error listening to dynamic links: $error');
    });
  }

  void _navigateToDangKyFinal(PendingDynamicLinkData? data) {
    final Uri? deepLink = data?.link;

    if (deepLink != null) {
      String email = deepLink.queryParameters['email'] ?? '';
      print('Dynamic link email: $email');
      if (email.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DangKyFinal(
              phoneNumber: '',
              email: email,
            ),
          ),
        );
      }
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
                margin: const EdgeInsets.only(top: 20.0),
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 222.0),
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
                      const SizedBox(height: 30),
                      PhoneInput(
                          controller:
                              _phoneController), // Pass the controller here
                      const SizedBox(height: 27),
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
                      const SizedBox(height: 30),
                      EmailInput(
                          controller:
                              _emailController), // Truyền controller vào đây
                      const SizedBox(height: 27),
                    ],
                    ElevatedButton(
                      onPressed: () async {
                        // hàm xử lý khi ấn vào nút Số điện thoại
                        if (isPhoneSelected) {
                          String phoneNumber = _phoneController.text.trim();
                          if (phoneNumber.startsWith('0')) {
                            phoneNumber =
                                phoneNumber.substring(1); // Bỏ số 0 đầu
                          }
                          if (phoneNumber.isNotEmpty) {
                            await _auth.verifyPhoneNumber(
                              phoneNumber:
                                  '+84$phoneNumber', // Assuming the user enters the number without the country code
                              verificationCompleted:
                                  (PhoneAuthCredential credential) async {
                                await _auth.signInWithCredential(credential);
                              },
                              verificationFailed: (FirebaseAuthException e) {
                                print('Lỗi xác thực: ${e.code} - ${e.message}');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Lỗi: ${e.code} - ${e.message}')),
                                );
                              },
                              codeSent:
                                  (String verificationId, int? resendToken) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => XacThucOTP(
                                      verificationId: verificationId,
                                      phoneNumber:
                                          phoneNumber, // Truyền số điện thoại vào đây
                                    ),
                                  ),
                                );
                              },
                              codeAutoRetrievalTimeout:
                                  (String verificationId) {},
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Vui lòng nhập số điện thoại hợp lệ')),
                            );
                          }
                        }

                        // hàm xử lý khi ấn vào nút Email
                        if (!isPhoneSelected) {
                          String email = _emailController.text.trim();
                          if (email.isNotEmpty) {
                            try {
                              // Tạo Dynamic Link với email
                              String dynamicLink = 'https://moneymateapp.page.link/email-link-verify?email=$email';                           
                              
                              // Gửi mã xác thực đến email
                              await _auth.sendSignInLinkToEmail(
                                email: email,
                                actionCodeSettings: ActionCodeSettings(
                                  // url: 'https://moneymateapp.page.link/email-link-verify', // Sử dụng Dynamic Link đã tạo
                                  url: dynamicLink, // Sử dụng Dynamic Link đã tạo
                                  handleCodeInApp: true,
                                  androidPackageName: 'com.example.flutter_moneymate_01',
                                  androidInstallApp: true,
                                  androidMinimumVersion: '29',
                                ),
                              );

                              // Hiển thị thông báo thành công
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Mã xác thực đã được gửi đến $email. Vui lòng kiểm tra email của bạn.')),
                              );

                              // Gọi hàm xử lý Dynamic Link
                              _handleDynamicLinks();
                              
                              // Chuyển đến màn hình đăng ký hoàn tất
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => DangKyFinal(
                              //         phoneNumber: '',
                              //         email: email), // Chuyển đến DangKyFinal
                              //   ),
                              // );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Lỗi gửi mã xác thực: ${e.toString()}')),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Vui lòng nhập email hợp lệ')),
                            );
                          }
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
