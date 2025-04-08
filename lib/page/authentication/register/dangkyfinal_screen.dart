import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../login/dangnhap_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

  // Thêm: Dữ liệu mặc định cho danh_muc_chi
  final List<Map<String, dynamic>> defaultExpenseCategories = [
    {'image': 'assets/images/wifi.png', 'ten_muc_chi': 'Cáp & Wifi'},
    {'image': 'assets/images/quanao.png', 'ten_muc_chi': 'Quần áo'},
    {'image': 'assets/images/cate50.png', 'ten_muc_chi': 'Xả stress'},
    {'image': 'assets/images/yte.png', 'ten_muc_chi': 'Y tế'},
    {'image': 'assets/images/mypham.png', 'ten_muc_chi': 'Mỹ phẩm'},
    {'image': 'assets/images/xemay.png', 'ten_muc_chi': 'Đi lại'},
    {'image': 'assets/images/food.png', 'ten_muc_chi': 'Ăn uống'},
  ];

  // Thêm: Dữ liệu mặc định cho danh_muc_thu
  final List<Map<String, dynamic>> defaultIncomeCategories = [
    {'image': 'assets/images/cate31.png', 'ten_muc_thu': 'Thu nhập phụ'},
    {'image': 'assets/images/cate29.png', 'ten_muc_thu': 'Tiền lương'},
    {'image': 'assets/images/cate32.png', 'ten_muc_thu': 'Tiền thưởng'},
    {'image': 'assets/images/cate33.png', 'ten_muc_thu': 'Phụ cấp'},
    {'image': 'assets/images/cate30.png', 'ten_muc_thu': 'Đầu tư'},
  ];

  // Thêm: Dữ liệu mặc định cho vi_tien
  final List<Map<String, dynamic>> defaultWallets = [
    {'ten_vi': 'Tiền mặt'},
    {'ten_vi': 'Chuyển khoản'},
  ];

  // Thêm: Hàm thêm dữ liệu mặc định vào Firestore
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

    // Tạo các collection trống: thu_nhap và chi_tieu
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

  @override
  void initState() {
    super.initState();
    // Gán số điện thoại và email vào controller
    _phoneController.text =
        widget.phoneNumber; // Sử dụng số điện thoại đã truyền vào
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
                padding: const EdgeInsets.only(top: 20),
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
                margin: const EdgeInsets.only(top: 20.0),
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 25.0),
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

                              // Sửa: Lưu thông tin người dùng vào Firestore và lấy user ID
                              String userId = userCredential.user!.uid;
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(userId)
                                  .set({
                                'email': email,
                                'username': username,
                                'sdt': phoneNumber,
                                'password': password,
                                'image': '',
                              });

                              // Thêm: Gọi hàm thêm dữ liệu mặc định sau khi tạo user
                              await addDefaultDataToFirestore(userId);

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
