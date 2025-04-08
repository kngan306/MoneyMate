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

  // **Dữ liệu mặc định cho danh_muc_chi**
  final List<Map<String, dynamic>> defaultExpenseCategories = [
    {'image': 'assets/images/wifi.png', 'ten_muc_chi': 'Cáp & Wifi'},
    {'image': 'assets/images/quanao.png', 'ten_muc_chi': 'Quần áo'},
    {'image': 'assets/images/cate50.png', 'ten_muc_chi': 'Xả stress'},
    {'image': 'assets/images/yte.png', 'ten_muc_chi': 'Y tế'},
    {'image': 'assets/images/mypham.png', 'ten_muc_chi': 'Mỹ phẩm'},
    {'image': 'assets/images/xemay.png', 'ten_muc_chi': 'Đi lại'},
    {'image': 'assets/images/food.png', 'ten_muc_chi': 'Ăn uống'},
  ];

  // **Dữ liệu mặc định cho danh_muc_thu**
  final List<Map<String, dynamic>> defaultIncomeCategories = [
    {'image': 'assets/images/cate31.png', 'ten_muc_thu': 'Thu nhập phụ'},
    {'image': 'assets/images/cate29.png', 'ten_muc_thu': 'Tiền lương'},
    {'image': 'assets/images/cate32.png', 'ten_muc_thu': 'Tiền thưởng'},
    {'image': 'assets/images/cate33.png', 'ten_muc_thu': 'Phụ cấp'},
    {'image': 'assets/images/cate30.png', 'ten_muc_thu': 'Đầu tư'},
  ];

  // **Dữ liệu mặc định cho vi_tien**
  final List<Map<String, dynamic>> defaultWallets = [
    {'ten_vi': 'Tiền mặt'},
    {'ten_vi': 'Chuyển khoản'},
  ];

  // **Hàm thêm dữ liệu mặc định vào Firestore**
  Future<void> addDefaultDataToFirestore(String userDocId) async {
    final firestore = FirebaseFirestore.instance;

    // Thêm danh mục chi tiêu mặc định
    final expenseCategoriesRef =
        firestore.collection('users').doc(userDocId).collection('danh_muc_chi');
    for (var category in defaultExpenseCategories) {
      final existingCategory = await expenseCategoriesRef
          .where('ten_muc_chi', isEqualTo: category['ten_muc_chi'])
          .get();
      if (existingCategory.docs.isEmpty) {
        await expenseCategoriesRef.add(category);
      }
    }

    // Thêm danh mục thu nhập mặc định
    final incomeCategoriesRef =
        firestore.collection('users').doc(userDocId).collection('danh_muc_thu');
    for (var category in defaultIncomeCategories) {
      final existingCategory = await incomeCategoriesRef
          .where('ten_muc_thu', isEqualTo: category['ten_muc_thu'])
          .get();
      if (existingCategory.docs.isEmpty) {
        await incomeCategoriesRef.add(category);
      }
    }

    // Thêm ví tiền mặc định
    final walletsRef =
        firestore.collection('users').doc(userDocId).collection('vi_tien');
    for (var wallet in defaultWallets) {
      final existingWallet =
          await walletsRef.where('ten_vi', isEqualTo: wallet['ten_vi']).get();
      if (existingWallet.docs.isEmpty) {
        await walletsRef.add(wallet);
      }
    }

    // Tạo các collection trống: thu_nhap và chi_tieu (không cần dữ liệu mặc định)
    await firestore
        .collection('users')
        .doc(userDocId)
        .collection('thu_nhap')
        .doc()
        .set({});
    await firestore
        .collection('users')
        .doc(userDocId)
        .collection('chi_tieu')
        .doc()
        .set({});
    // Xóa document rỗng ngay sau khi tạo để giữ collection trống
    await firestore
        .collection('users')
        .doc(userDocId)
        .collection('thu_nhap')
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
    await firestore
        .collection('users')
        .doc(userDocId)
        .collection('chi_tieu')
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    });

    print('🔥 Đã thêm dữ liệu mặc định cho người dùng mới!');
  }

  // **Hàm lưu thông tin người dùng Google vào Firestore**
  Future<void> saveGoogleUserToFirestore(User user) async {
    final userRef = FirebaseFirestore.instance.collection('users');

    // Kiểm tra xem user đã tồn tại chưa (bằng email)
    final existingUser =
        await userRef.where('email', isEqualTo: user.email).get();

    if (existingUser.docs.isEmpty) {
      // Nếu chưa tồn tại -> thêm user mới
      final newUserDoc = await userRef.add({
        'username': user.displayName ?? '',
        'email': user.email ?? '',
        'image': user.photoURL ?? '',
        'sdt': '', // Có thể cập nhật sau trong phần hồ sơ
        'password': '', // Để trống vì đăng nhập bằng Google
      });

      // Thêm dữ liệu mặc định sau khi tạo user mới
      await addDefaultDataToFirestore(newUserDoc.id);

      print('🔥 Thêm người dùng Google mới vào Firestore thành công!');
    } else {
      print('✅ Người dùng đã tồn tại trong Firestore.');
    }
  }

  // **Hàm đăng nhập bằng Google**
  Future<void> login() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // Người dùng đã hủy đăng nhập
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
        await saveGoogleUserToFirestore(user);
        // Chuyển hướng đến trang chính
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const Mainpage(selectedIndex: 0)),
        );
      }
    } catch (e) {
      print("Lỗi đăng nhập Google: $e");
      setState(() {
        _errorMessage = 'Đăng nhập bằng Google không thành công';
      });
    }
  }

  // **Hàm đăng nhập bằng email và mật khẩu**
  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng nhập email và mật khẩu.';
      });
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        var userDoc = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: user.email)
            .get();

        if (userDoc.docs.isNotEmpty) {
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
      }

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
                      child: Icon(Icons.arrow_back,
                          size: 26.sp, color: Colors.black),
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
                    Image.asset('assets/images/logo.png',
                        width: 60.w, height: 60.h),
                    Text(
                      'MoneyMate',
                      style: TextStyle(
                        fontSize: 21.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.52.sp,
                        color: const Color(0xFF1E201E),
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
                    Row(
                      children: [
                        Image.asset('assets/images/user_icon.png',
                            width: 27.w, height: 27.h),
                        SizedBox(width: 2.w),
                        Text('Email',
                            style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Montserrat')),
                      ],
                    ),
                    SizedBox(height: 7.h),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 14.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.r),
                          borderSide:
                              const BorderSide(color: Colors.black, width: 1),
                        ),
                        hintText: 'Nhập email',
                        hintStyle: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 15.sp,
                            color: Colors.grey),
                      ),
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 15.sp,
                          color: Colors.black),
                    ),
                    SizedBox(height: 21.h),
                    Row(
                      children: [
                        Image.asset('assets/images/password_icon.png',
                            width: 27.w, height: 27.h),
                        SizedBox(width: 2.w),
                        Text('Mật khẩu',
                            style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Montserrat')),
                      ],
                    ),
                    SizedBox(height: 7.h),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 17.w, vertical: 12.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.r),
                          borderSide:
                              const BorderSide(color: Colors.black, width: 1),
                        ),
                        hintText: 'Nhập mật khẩu',
                        hintStyle: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 15.sp,
                            color: Colors.grey),
                        suffixIcon: IconButton(
                          icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.black),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 15.sp,
                          color: Colors.black),
                    ),
                    if (_errorMessage != null)
                      Padding(
                        padding: EdgeInsets.only(top: 8.0.h),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 14.sp,
                              fontFamily: 'Montserrat'),
                        ),
                      ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const QuenMatKhau())),
                          child: Text(
                            'Quên mật khẩu?',
                            style: TextStyle(
                                fontSize: 14.sp,
                                fontFamily: 'Montserrat',
                                decoration: TextDecoration.underline),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 21.h),
                    Center(
                      child: GestureDetector(
                        onTap: _login,
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
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 21.h),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: 'Montserrat',
                              color: Colors.black),
                          children: [
                            const TextSpan(text: 'Chưa có tài khoản? '),
                            TextSpan(
                              text: 'Đăng ký',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const DangKy())),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 21.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            width: 133.w,
                            height: 1.h,
                            color: const Color(0x4D000000)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.w),
                          child: Text('hoặc',
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w300,
                                  fontFamily: 'Montserrat')),
                        ),
                        Container(
                            width: 133.w,
                            height: 1.h,
                            color: const Color(0x4D000000)),
                      ],
                    ),
                    SizedBox(height: 30.h),
                    GestureDetector(
                      onTap: login,
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 300.w),
                        padding: EdgeInsets.fromLTRB(17.w, 10.h, 17.w, 10.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15.r),
                          border: Border.all(
                              color: const Color(0xFF1E201E), width: 1),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Image.asset('assets/images/google_icon.png',
                                    width: 30.w, height: 30.h),
                                SizedBox(width: 10.w),
                                Text('Tiếp tục với Google',
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        fontFamily: 'Montserrat')),
                              ],
                            ),
                            Icon(Icons.arrow_forward, size: 26.sp),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 26.h),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Tính năng này chưa được hỗ trợ'),
                              duration: Duration(seconds: 2)),
                        );
                      },
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 300.w),
                        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15.r),
                          border: Border.all(
                              color: const Color(0xFF1E201E), width: 1),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Image.asset('assets/images/facebook_icon.png',
                                    width: 35.w, height: 35.h),
                                SizedBox(width: 7.w),
                                Text('Tiếp tục với Facebook',
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        fontFamily: 'Montserrat')),
                              ],
                            ),
                            Icon(Icons.arrow_forward, size: 26.sp),
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
