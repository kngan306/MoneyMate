import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../forgotpass/quenmatkhau_screen.dart';
import '../register/dangky_screen.dart';
import '../../dashboard/dashboardwidget.dart';
import '../../mainpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
        'createdAt': FieldValue.serverTimestamp(),
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
    try {
      // Đăng nhập với Firebase Authentication
      await FirebaseAuth.instance.signInWithEmailAndPassword(
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
                    // const EdgeInsets.only(left: 16.0, right: 16.0, top: 25.0),
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
                          'Đăng nhập',
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
                // padding: const EdgeInsets.only(top: 30.0),
                padding: const EdgeInsets.only(top: 20.0),
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
              Container(
                // margin: const EdgeInsets.only(top: 30.0),
                margin: const EdgeInsets.only(top: 20.0),
                padding: const EdgeInsets.fromLTRB(16.0, 30.0, 16.0, 88.0),
                // padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 25.0),
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
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
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: Colors.black,
                            width: 1,
                          ),
                        ),
                        hintText: 'Nhập tên đăng nhập',
                        hintStyle: const TextStyle(
                          fontFamily:
                              'Montserrat', // Áp dụng font cho hint text
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                      style: const TextStyle(
                        fontFamily:
                            'Montserrat', // Áp dụng font cho nội dung nhập vào
                        fontSize: 15,
                        color: Colors.black,
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
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 17,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: Colors.black,
                            width: 1,
                          ),
                        ),
                        hintText: 'Nhập mật khẩu',
                        hintStyle: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 15,
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
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),

                    // Hiển thị lỗi (nếu có)
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: GestureDetector(
                          onTap: () {
                            // Navigator.pushNamed(context, '/quenmatkhau');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const QuenMatKhau(),
                              ),
                            );
                          },
                          child: const Text(
                            'Quên mật khẩu?',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Login button
                    const SizedBox(height: 21),
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
                          width: 200,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E201E),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Đăng nhập',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Register link
                    const SizedBox(height: 21),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14,
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
                    const SizedBox(height: 21),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 133,
                          height: 1,
                          color: const Color(0x4D000000),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2),
                          child: Text(
                            'hoặc',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                              fontFamily: 'Montserrat',
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Container(
                          width: 133,
                          height: 1,
                          color: const Color(0x4D000000),
                        ),
                      ],
                    ),

                    // Google login button
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: () {
                        login();
                      },
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 300),
                        padding: const EdgeInsets.fromLTRB(17, 10, 17, 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: const Color(0xFF1E201E),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  'assets/images/google_icon.png',
                                  width: 30,
                                  height: 30,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Tiếp tục với Google',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Montserrat',
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              Icons.arrow_forward,
                              size: 26,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Facebook login button
                    const SizedBox(height: 26),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 300),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: const Color(0xFF1E201E),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/facebook_icon.png',
                                width: 35,
                                height: 35,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(width: 7),
                              Text(
                                'Tiếp tục với Facebook',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Montserrat',
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.arrow_forward,
                            size: 26,
                            color: Colors.black,
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
