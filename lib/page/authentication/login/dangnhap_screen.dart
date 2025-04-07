import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../forgotpass/quenmatkhau_screen.dart';
import '../register/dangky_screen.dart';
import '../../dashboard/dashboardwidget.dart';
import '../../mainpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DangNhap extends StatefulWidget {
  const DangNhap({Key? key}) : super(key: key);

  @override
  State<DangNhap> createState() => _DangNhapState();
}

class _DangNhapState extends State<DangNhap> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;

  Future<void> saveGoogleUserToFirestore(User user) async {
    final userRef = FirebaseFirestore.instance.collection('users');

    // Kiểm tra xem user đã tồn tại chưa (bằng email)
    final existingUser =
        await userRef.where('email', isEqualTo: user.email).get();

    if (existingUser.docs.isEmpty) {
      // Nếu chưa tồn tại -> thêm user mới
      await userRef.add({
        'username': user.displayName ?? '',
        'email': user.email ?? '',
        'image': user.photoURL ?? '',
        'sdt': '', // Bạn có thể cập nhật sau trong phần hồ sơ
        'password': '', // Để trống vì đăng nhập bằng Google
        // 'createdAt': FieldValue.serverTimestamp(),
      });

      print('🔥 Thêm người dùng Google mới vào Firestore thành công!');
    } else {
      print('✅ Người dùng đã tồn tại trong Firestore.');
    }
  }

  login() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // Người dùng đã hủy đăng nhập, không làm gì cả
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Đăng nhập với Firebase
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        await saveGoogleUserToFirestore(user); // Thêm dòng này
        // Đăng nhập thành công, chuyển hướng đến Trang chủ
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  Mainpage(selectedIndex: 0)), // nếu bạn hỗ trợ initialIndex
        );
      }
    } catch (e) {
      print("Lỗi đăng nhập Google: $e");
      setState(() {
        _errorMessage = 'Đăng nhập bằng Google không thành công';
      });
    }
  }

  // Hàm đăng nhập với Firebase Authentication
  Future<void> _login() async {
    // Kiểm tra xem người dùng có nhập email và mật khẩu không
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng nhập email và mật khẩu.';
      });
      return;
    }

    try {
      // Đăng nhập với Firebase Authentication bằng email và mật khẩu
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Lấy thông tin người dùng từ Firestore
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        var userDoc = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: user.email)
            .get();

        if (userDoc.docs.isNotEmpty) {
          // In thông tin người dùng ra terminal
          var data = userDoc.docs.first.data();
          print('Đăng nhập thành công! Thông tin người dùng từ Firestore:');
          print('ID: ${userDoc.docs.first.id}');
          print('SĐT: ${data['sdt']}');
          print('Email: ${data['email']}');
          print('Username: ${data['username']}');
          print('Password: ${data['password']}');
          print('Image: ${data['image']}');
        } else {
          print('Không tìm thấy thông tin người dùng trong Firestore.');
        }
      } else {
        print('Không lấy được thông tin user từ Firebase Auth.');
      }

      // Đăng nhập thành công, chuyển đến Mainpage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Mainpage()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found' || e.code == 'wrong-password') {
          _errorMessage = 'Email hoặc mật khẩu không đúng.';
        } else {
          _errorMessage = 'Đã xảy ra lỗi: ${e.message}';
        }
      });
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
                          'Đăng nhập',
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
                padding: EdgeInsets.fromLTRB(16.0.w, 30.0.h, 16.0.w, 88.0.h),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.r),
                    topRight: Radius.circular(40.r),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Username field
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
                          'Email',
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 7.h),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 14.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.r),
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 1.w,
                          ),
                        ),
                        hintText: 'Nhập email',
                        hintStyle: TextStyle(
                          fontFamily:
                              'Montserrat', // Áp dụng font cho hint text
                          fontSize: 15.sp,
                          color: Colors.grey,
                        ),
                      ),
                      style: TextStyle(
                        fontFamily:
                            'Montserrat', // Áp dụng font cho nội dung nhập vào
                        fontSize: 15.sp,
                        color: Colors.black,
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
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 7.h),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 17.w,
                          vertical: 12.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.r),
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 1.w,
                          ),
                        ),
                        hintText: 'Nhập mật khẩu',
                        hintStyle: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 15.sp,
                          color: Colors.grey,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 15.sp,
                        color: Colors.black,
                      ),
                    ),

                    // Hiển thị lỗi (nếu có)
                    if (_errorMessage != null)
                      Padding(
                        padding: EdgeInsets.only(top: 8.0.h),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14.sp,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const QuenMatKhau(),
                              ),
                            );
                          },
                          child: Text(
                            'Quên mật khẩu?',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: 'Montserrat',
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Login button
                    SizedBox(height: 21.h),
                    Center(
                      child: GestureDetector(
                        onTap: _login, // Gọi hàm đăng nhập
                        // onTap: () {
                        //   // Navigator.pushNamed(context, '/dashboard');
                        //   Navigator.pushReplacement(
                        //     context,
                        //     MaterialPageRoute(
                        //       builder: (context) => Mainpage(),
                        //     ),
                        //   );
                        // },
                        child: Container(
                          width: 200.w,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E201E),
                            borderRadius: BorderRadius.circular(50.r),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Đăng nhập',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Register link
                    SizedBox(height: 21.h),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: 'Montserrat',
                            color: Colors.black,
                          ),
                          children: [
                            const TextSpan(text: 'Chưa có tài khoản? '),
                            TextSpan(
                                text: 'Đăng ký',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () =>
                                      // Navigator.pushNamed(ontext, AppRoutes.register)
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const DangKy(),
                                        ),
                                      )),
                          ],
                        ),
                      ),
                    ),

                    // Divider
                    SizedBox(height: 21.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 133.w,
                          height: 1.h,
                          color: const Color(0x4D000000),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.w),
                          child: Text(
                            'hoặc',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w300,
                              fontFamily: 'Montserrat',
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Container(
                          width: 133.w,
                          height: 1.h,
                          color: const Color(0x4D000000),
                        ),
                      ],
                    ),

                    // Google login button
                    SizedBox(height: 30.h),
                    GestureDetector(
                      onTap: () {
                        login();
                      },
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 300.w),
                        padding: EdgeInsets.fromLTRB(17.w, 10.h, 17.w, 10.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15.r),
                          border: Border.all(
                            color: const Color(0xFF1E201E),
                            width: 1.w,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  'assets/images/google_icon.png',
                                  width: 30.w,
                                  height: 30.h,
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(width: 10.w),
                                Text(
                                  'Tiếp tục với Google',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontFamily: 'Montserrat',
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              Icons.arrow_forward,
                              size: 26.sp,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Facebook login button
                    SizedBox(height: 26.h),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Tính năng này chưa được hỗ trợ'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 300.w),
                        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15.r),
                          border: Border.all(
                            color: const Color(0xFF1E201E),
                            width: 1.w,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  'assets/images/facebook_icon.png',
                                  width: 35.w,
                                  height: 35.h,
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(width: 7.w),
                                Text(
                                  'Tiếp tục với Facebook',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontFamily: 'Montserrat',
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              Icons.arrow_forward,
                              size: 26.sp,
                              color: Colors.black,
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
