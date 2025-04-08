import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../User/doimatkhau.dart';

class UserWidget extends StatefulWidget {
  const UserWidget({super.key});
  @override
  _UserWidgetState createState() => _UserWidgetState();
}

class _UserWidgetState extends State<UserWidget> {
  bool _isObscured = true; // Biến kiểm soát hiển thị/ẩn mật khẩu
  late TextEditingController
      _usernameController; // Controller cho tên đăng nhập
  late TextEditingController _emailController; // Controller cho email
  late TextEditingController _phoneController; // Controller cho số điện thoại
  late TextEditingController _passwordController; // Controller cho mật khẩu

  late String _initialUsername;
  late String _initialEmail;
  late String _initialPhone;

  String? _imageUrl; // Biến để lưu URL hoặc asset path của hình ảnh

  // Thêm biến để lưu trữ hình ảnh đã chọn
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    // Khởi tạo các TextEditingController
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    // Gọi hàm load dữ liệu từ Firestore khi widget được khởi tạo
    _loadUserData();
  }

  // Call this method after logging in
  void refreshUserData() {
    _loadUserData(); // Refresh user data
  }

  // Hàm load dữ liệu người dùng từ Firestore
  Future<void> _loadUserData() async {
    User? user = FirebaseAuth
        .instance.currentUser; // Lấy thông tin user hiện tại từ Firebase Auth
    if (user != null) {
      try {
        var userDoc = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: user.email)
            .get(); // Truy vấn document trong collection 'users' với email khớp

        if (userDoc.docs.isNotEmpty) {
          var data =
              userDoc.docs.first.data(); // Lấy dữ liệu từ document đầu tiên
          setState(() {
            // Cập nhật giá trị cho các controller từ Firestore
            _usernameController.text = data['username'] ?? '';
            _emailController.text = data['email'] ?? '';
            _phoneController.text = data['sdt'] ?? '';
            _passwordController.text = data['password'] ?? '';
            _imageUrl = data['image']; // Lấy URL hoặc asset path của hình ảnh
            _selectedImage = null; // Đặt lại _selectedImage nếu không cần thiết

            // Gán giá trị ban đầu
            _initialUsername = _usernameController.text;
            _initialEmail = _emailController.text;
            _initialPhone = _phoneController.text;
          });
        } else {
          print('Không tìm thấy thông tin người dùng trong Firestore.');
        }
      } catch (e) {
        print('Lỗi khi load dữ liệu từ Firestore: $e');
      }
    }
  }

  // Getter để hiển thị mật khẩu dạng dấu * hoặc text thật
  String get displayText {
    if (_isObscured) {
      return '*' *
          _passwordController
              .text.length; // Hiển thị dấu * theo độ dài mật khẩu
    }
    return _passwordController.text; // Hiển thị mật khẩu thật
  }

  // Hàm thay đổi hình ảnh avatar
  Future<void> _changeAvatar() async {
    final ImagePicker _picker = ImagePicker();
    // Mở thư viện ảnh
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path); // Lưu hình ảnh đã chọn
        _imageUrl = image.path; // Cập nhật URL hình ảnh
      });

      // Cập nhật hình ảnh lên Firestore
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        var userDoc = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: user.email)
            .get();
        if (userDoc.docs.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userDoc.docs.first.id)
              .update({
            'image': _imageUrl, // Cập nhật URL hình ảnh mới
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          "Tài khoản",
          style: TextStyle(
            fontSize: 17.sp,
            color: Colors.white,
          ),
        ),
        showToggleButtons: false,
        showMenuButton: true, // Hiển thị nút menu (Drawer)
        onMenuPressed: () {
          Scaffold.of(context).openDrawer(); // Mở drawer từ MainPage
        },
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        // child: Container(
          child: SingleChildScrollView(
            // child: ConstrainedBox(
            //   constraints: BoxConstraints(maxWidth: 400.w),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 30.0.h, horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Phần hiển thị thông tin chính
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.0.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Avatar người dùng
                          Center(
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 65.r,
                                  backgroundColor: _selectedImage == null &&
                                          (_imageUrl == null ||
                                              _imageUrl!.isEmpty)
                                      ? Colors
                                          .white // Hình tròn trắng nếu không có hình
                                      : null,
                                  backgroundImage: _imageUrl != null &&
                                          _imageUrl!.isNotEmpty
                                      ? (_imageUrl!.startsWith('assets/')
                                          ? AssetImage(
                                              _imageUrl!) // Sử dụng AssetImage nếu là hình ảnh từ assets
                                          : (_imageUrl!.startsWith(
                                                  'http') // Kiểm tra nếu hình ảnh là hình ảnh mạng
                                              ? NetworkImage(
                                                  _imageUrl!) // Sử dụng NetworkImage nếu là hình ảnh từ URL
                                              : FileImage(File(
                                                  _imageUrl!)))) // Sử dụng FileImage nếu là hình ảnh từ file
                                      : (_selectedImage != null
                                          ? FileImage(
                                              _selectedImage!) // Sử dụng FileImage nếu có hình ảnh từ file
                                          : null),
                                ),
                                Positioned(
                                  bottom: 5.h,
                                  right: 5.w,
                                  child: GestureDetector(
                                    onTap:
                                        _changeAvatar, // Gọi hàm thay đổi hình ảnh
                                    child: Container(
                                      width: 35.w,
                                      height: 35.h,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            blurRadius: 4.r,
                                            spreadRadius: 1.r,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.camera_alt,
                                        color: Colors.black54,
                                        size: 20.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16.h),
                          // Phần tên đăng nhập
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/user_icon.png',
                                width: 27.w,
                                height: 27.h,
                                fit: BoxFit.contain,
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                'Tên đăng nhập',
                                style: TextStyle(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 7.h),
                          Container(
                            height: 55.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15.r),
                              border: Border.all(
                                color: const Color(0xFF1E201E),
                                width: 2.w,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 2.h,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller:
                                        _usernameController, // Sử dụng controller từ Firestore
                                    style: TextStyle(fontSize: 15.sp),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Nhập tên...',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Phần email
                          SizedBox(height: 21.h),
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/image.png',
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
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 7.h),
                          Container(
                            height: 55.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15.r),
                              border: Border.all(
                                color: const Color(0xFF1E201E),
                                width: 2.w,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 2.h,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller:
                                        _emailController, // Sử dụng controller từ Firestore
                                    style: TextStyle(fontSize: 15.sp),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Nhập email...',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Phần số điện thoại
                          SizedBox(height: 21.h),
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/phone_icon.png',
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
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 7.h),
                          Container(
                            height: 55.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15.r),
                              border: Border.all(
                                color: const Color(0xFF1E201E),
                                width: 2.w,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 2.h,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller:
                                        _phoneController, // Sử dụng controller từ Firestore
                                    style: TextStyle(fontSize: 15.sp),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Nhập số điện thoại...',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Phần mật khẩu
                          // SizedBox(height: 21.h),
                          // Row(
                          //   children: [
                          //     Image.asset(
                          //       'assets/images/password_icon.png',
                          //       width: 27.w,
                          //       height: 27.h,
                          //       fit: BoxFit.contain,
                          //     ),
                          //     SizedBox(width: 2.w),
                          //     Text(
                          //       'Mật khẩu',
                          //       style: TextStyle(
                          //         fontSize: 17.sp,
                          //         fontWeight: FontWeight.w500,
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // SizedBox(height: 7.h),
                          // Container(
                          //   height: 55.h,
                          //   decoration: BoxDecoration(
                          //     color: Colors.white,
                          //     borderRadius: BorderRadius.circular(15.r),
                          //     border: Border.all(
                          //       color: const Color(0xFF1E201E),
                          //       width: 2.w,
                          //     ),
                          //   ),
                          //   padding: EdgeInsets.symmetric(
                          //     horizontal: 16.w,
                          //     vertical: 2.h,
                          //   ),
                          //   child: Row(
                          //     children: [
                          //       Expanded(
                          //         child: TextField(
                          //           controller: TextEditingController(
                          //               text: displayText),
                          //           style: TextStyle(fontSize: 15.sp),
                          //           readOnly: true,
                          //           decoration: const InputDecoration(
                          //             border: InputBorder.none,
                          //           ),
                          //         ),
                          //       ),
                          //       IconButton(
                          //         icon: Icon(
                          //           _isObscured
                          //               ? Icons.visibility_off
                          //               : Icons.visibility,
                          //           color: Colors.black,
                          //         ),
                          //         onPressed: () {
                          //           setState(() {
                          //             _isObscured =
                          //                 !_isObscured; // Đổi trạng thái hiển thị mật khẩu
                          //           });
                          //         },
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          // Link đổi mật khẩu
                          SizedBox(height: 10.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ChangePasswordPage()),
                                  );
                                },
                                child: Text(
                                  'Đổi mật khẩu ',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Image.asset(
                                'assets/images/arrow2_icon.png',
                                width: 15.w,
                                height: 15.h,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Phần nút "Lưu thay đổi" và "Hủy"
                    SizedBox(height: 20.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0.w),
                      child: Row(
                        children: [
                          // Nút hủy
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // Khôi phục dữ liệu ban đầu từ Firestore
                                _loadUserData();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  side: BorderSide(
                                    color: Color(0xFFFE0000),
                                    width: 1.w,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Hủy',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFFE0000),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          // Nút lưu thay đổi
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                // Lưu thay đổi lên Firestore
                                User? user = FirebaseAuth.instance.currentUser;
                                if (user != null) {
                                  var userDoc = await FirebaseFirestore.instance
                                      .collection('users')
                                      .where('email', isEqualTo: user.email)
                                      .get();
                                  if (userDoc.docs.isNotEmpty) {
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(userDoc.docs.first.id)
                                        .update({
                                      'image':
                                          _imageUrl, // Cập nhật trường hình ảnh
                                      'username': _usernameController.text,
                                      'email': _emailController.text,
                                      'sdt': _phoneController.text,
                                      // Không cập nhật mật khẩu ở đây, xử lý riêng trong dialog
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Đã lưu thay đổi')),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  side: BorderSide(
                                    color: Color(0xFF4ABD57),
                                    width: 1.w,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Lưu thay đổi',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF4ABD57),
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
            // ),
          ),
        // ),
      ),
    );
  }

  @override
  void dispose() {
    // Giải phóng các controller để tránh rò rỉ bộ nhớ
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
