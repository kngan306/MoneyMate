import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../widgets/input/password_new_input.dart';
import '../login/dangnhap_screen.dart';

class ResetPassword extends StatefulWidget {
  final String email;

  const ResetPassword({Key? key, required this.email}) : super(key: key);

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    String newPassword = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập mật khẩu mới')),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mật khẩu không khớp')),
      );
      return;
    }

    try {
      // Kiểm tra người dùng trong Firestore bằng email
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: widget.email)
          .get();

      if (userDoc.docs.isNotEmpty) {
        // Cập nhật mật khẩu trong Firebase Authentication
        User? user = FirebaseAuth.instance.currentUser ;
        if (user != null) {
          await user.updatePassword(newPassword);

          // Cập nhật mật khẩu trong Firestore
          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'password': newPassword, // Lưu mật khẩu mới vào Firestore
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Mật khẩu đã được cập nhật')),
          );

          // Chuyển hướng đến màn hình đăng nhập
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DangNhap()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không tìm thấy người dùng với email này')),
        );
      }
    } catch (e) {
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
          child: Container(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back, size: 26, color: Colors.black),
                      ),
                      Expanded(
                        child: Center(
                          child: const Text(
                            'Đặt lại mật khẩu',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
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
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Column(
                    children: [
                      Image.asset('assets/images/logo.png', width: 60, height: 60),
                      const Text(
                        'MoneyMate',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.52,
                          color: Color(0xFF1E201E),
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20.0),
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 140.0),
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/unlocked.png', width: 82, height: 82),
                      const SizedBox(height: 14),
                      const Text(
                        'Xác thực thành công',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Đã xác thực thành công, vui lòng nhập lại mật khẩu mới của bạn.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      const SizedBox(height: 25),
                      Row(
                        children: [
                          Image.asset('assets/images/password_icon.png', width: 27, height: 27),
                          const SizedBox(width: 2),
                          const Text(
                            'Mật khẩu mới',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      NewPasswordInputField(
                        controller: _passwordController,
                        isPasswordVisible: _passwordVisible,
                        onToggleVisibility: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                      const SizedBox(height: 21),
                      Row(
                        children: [
                          Image.asset('assets/images/password_icon.png', width: 27, height: 27),
                          const SizedBox(width: 2),
                          const Text(
                            'Xác nhận mật khẩu mới',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      NewPasswordInputField(
                        controller: _confirmPasswordController,
                        isPasswordVisible: _confirmPasswordVisible,
                        onToggleVisibility: () {
                          setState(() {
                            _confirmPasswordVisible = !_confirmPasswordVisible;
                          });
                        },
                      ),
                      const SizedBox(height: 25),
                      ElevatedButton(
                        onPressed: _updatePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E201E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          minimumSize: const Size(150, 48),
                          padding: const EdgeInsets.symmetric(horizontal: 59, vertical: 12),
                        ),
                        child: const Text(
                          'Lưu',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                              fontFamily: 'Montserrat',
                            ),
                            children: [
                              const TextSpan(
                                text: 'Lưu ý:',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.red, // Màu đỏ nổi bật hơn
                                ),
                              ),                              
                              const TextSpan(
                                text: ' Nếu bạn đã cập nhật mật khẩu mới thông qua đường link xác thực, vui lòng bỏ qua bước này và quay về trang ',
                              ),
                              TextSpan(
                                text: 'Đăng nhập',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                  // decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const DangNhap()),
                                    );
                                  },
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
      ),
    );
  }
}