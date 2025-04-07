import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../login/dangnhap_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DangKyFinal extends StatefulWidget {
  final String phoneNumber; // Thêm biến để lưu số điện thoại
  final String email; // Thêm biến để lưu email

  const DangKyFinal({Key? key, required this.phoneNumber, required this.email})
      : super(key: key);

  @override
  State<DangKyFinal> createState() => _DangKyFinalState();
}

class _DangKyFinalState extends State<DangKyFinal> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    // Gán số điện thoại và email vào controller
    _phoneController.text = widget.phoneNumber; // Sử dụng số điện thoại đã truyền vào
    _emailController.text = widget.email; // Sử dụng email đã truyền vào
  }

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
                    const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back,
                        size: 26,
                        color: Colors.black,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: const Text(
                          'Đăng ký',
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
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      // width: 70,
                      // height: 70,
                      width: 60,
                      height: 60,
                    ),
                    const Text(
                      'MoneyMate',
                      style: TextStyle(
                        // fontSize: 25,
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

              // Form section
              Container(
                margin: const EdgeInsets.only(top: 20.0),
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 25.0),
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
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
                            width: 27,
                            height: 27,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 2),
                          const Text(
                            'Số điện thoại',
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
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 1,
                            ),
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          fontFamily: 'Montserrat',
                        ),
                      ),

                      // Email field
                      const SizedBox(height: 21),
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/email_icon.png', // Replace with actual asset path
                            width: 27,
                            height: 27,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 2),
                          const Text(
                            'Email',
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
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 1,
                            ),
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          fontFamily: 'Montserrat',
                        ),
                      ),

                      // Username field
                      const SizedBox(height: 21),
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/user_icon.png', // Replace with actual asset path
                            width: 27,
                            height: 27,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 2),
                          const Text(
                            'Tên đăng nhập',
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
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 1,
                            ),
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          fontFamily: 'Montserrat',
                        ),
                      ),

                      // Password field
                      const SizedBox(height: 21),
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/password_icon.png', // Replace with actual asset path
                            width: 27,
                            height: 27,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 2),
                          const Text(
                            'Mật khẩu',
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
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 17, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 1,
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
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          fontFamily: 'Montserrat',
                        ),
                      ),

                      // Confirm password field
                      const SizedBox(height: 21),
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/password_icon.png', // Replace with actual asset path
                            width: 27,
                            height: 27,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 2),
                          const Text(
                            'Xác nhận mật khẩu',
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
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: !_isConfirmPasswordVisible,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 17, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 1,
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
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          fontFamily: 'Montserrat',
                        ),
                      ),

                      // Register button
                      const SizedBox(height: 21),
                      Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            // Lấy dữ liệu từ các trường nhập liệu
                            String email = _emailController.text.trim();
                            String username = _usernameController.text.trim();
                            String password = _passwordController.text.trim();
                            String confirmPassword =
                                _confirmPasswordController.text.trim();
                            String phoneNumber = _phoneController.text.trim();

                            // Kiểm tra các trường bắt buộc
                            if (email.isEmpty ||
                                username.isEmpty ||
                                password.isEmpty ||
                                phoneNumber.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Vui lòng điền đầy đủ thông tin')),
                              );
                              return;
                            }

                            // Kiểm tra mật khẩu
                            if (password != confirmPassword) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Mật khẩu không khớp')),
                              );
                              return;
                            }

                            try {
                              // Tạo người dùng mới trong Firebase Authentication
                              UserCredential userCredential = await FirebaseAuth
                                  .instance
                                  .createUserWithEmailAndPassword(
                                email: email,
                                password: password,
                              );

                              // Lưu thông tin người dùng vào Firestore
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userCredential.user?.uid)
                                  .set({
                                'email': email,
                                'username': username,
                                'sdt': phoneNumber,
                                'password': password,
                                'image': '', // Trường này có thể cập nhật sau
                              });

                              // Hiển thị thông báo đăng ký thành công
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Đăng ký thành công!')),
                              );

                              // Chuyển hướng đến màn hình đăng nhập hoặc màn hình chính
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DangNhap(),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Đăng ký không thành công: ${e.toString()}')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E201E),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(200, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 64, vertical: 12),
                          ),
                          child: const Text(
                            'Đăng ký',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                      ),

                      // Login link
                      const SizedBox(height: 21),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            // Navigate to login screen
                          },
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 14,
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
