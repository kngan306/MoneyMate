import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UserWidget extends StatefulWidget {
  const UserWidget({super.key});
  @override
  _UserWidgetState createState() => _UserWidgetState();
}

class _UserWidgetState extends State<UserWidget> {
  bool _isObscured = true; // Biến kiểm soát hiển thị/ẩn mật khẩu
  late TextEditingController _usernameController; // Controller cho tên đăng nhập
  late TextEditingController _emailController; // Controller cho email
  late TextEditingController _phoneController; // Controller cho số điện thoại
  late TextEditingController _passwordController; // Controller cho mật khẩu
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
    User? user = FirebaseAuth.instance.currentUser; // Lấy thông tin user hiện tại từ Firebase Auth
    if (user != null) {
      try {
        var userDoc = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: user.email)
            .get(); // Truy vấn document trong collection 'users' với email khớp

        if (userDoc.docs.isNotEmpty) {
          var data = userDoc.docs.first.data(); // Lấy dữ liệu từ document đầu tiên
          setState(() {
            // Cập nhật giá trị cho các controller từ Firestore
            _usernameController.text = data['username'] ?? '';
            _emailController.text = data['email'] ?? '';
            _phoneController.text = data['sdt'] ?? '';
            _passwordController.text = data['password'] ?? '';
            _imageUrl = data['image']; // Lấy URL hoặc asset path của hình ảnh
            _selectedImage = null; // Đặt lại _selectedImage nếu không cần thiết
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

  // Hàm hiển thị dialog đổi mật khẩu
  void showChangePasswordDialog() {
    bool _isNewObscured = true; // Ẩn mật khẩu mới
    bool _isConfirmObscured = true; // Ẩn xác nhận mật khẩu

    TextEditingController _newPasswordController = TextEditingController();
    TextEditingController _confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.transparent,
              content: Container(
                width: 400,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Đổi mật khẩu",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      "Mật khẩu mới",
                      _newPasswordController,
                      _isNewObscured,
                      () {
                        setState(() {
                          _isNewObscured = !_isNewObscured;
                        });
                      },
                    ),
                    _buildPasswordField(
                      "Xác nhận mật khẩu mới",
                      _confirmPasswordController,
                      _isConfirmObscured,
                      () {
                        setState(() {
                          _isConfirmObscured = !_isConfirmObscured;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Nút Hủy
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(
                                color: Color(0xFFFE0000), // Màu viền nút Hủy
                                width: 1,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Hủy',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFFE0000), // Màu chữ nút Hủy
                            ),
                          ),
                        ),
                        // Nút Xác nhận
                        ElevatedButton(
                          onPressed: () async {
                            // Lấy giá trị nhập
                            String newPassword = _newPasswordController.text.trim();
                            String confirmPassword = _confirmPasswordController.text.trim();

                            // Kiểm tra nếu ô nhập trống
                            if (newPassword.isEmpty || confirmPassword.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Vui lòng nhập mật khẩu cần đổi')),
                              );
                              return;
                            }

                            // Kiểm tra mật khẩu mới và xác nhận
                            if (newPassword == confirmPassword) {
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
                                    'password': _newPasswordController.text, // Cập nhật mật khẩu mới
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Đã đổi mật khẩu thành công')),
                                  );
                                  Navigator.pop(context); // Đóng dialog
                                }
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Mật khẩu không khớp')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(
                                color: const Color(0xFF4ABD57),
                                width: 1,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Xác nhận',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF4ABD57), // Màu chữ nút Hủy
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Hàm tạo TextField cho dialog đổi mật khẩu
  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool isObscured,
    VoidCallback toggleVisibility,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: isObscured,
        style: const TextStyle(fontSize: 14), // <-- Thêm dòng này
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 14), // <-- Font size cho label
          suffixIcon: IconButton(
            icon: Icon(
              isObscured ? Icons.visibility_off : Icons.visibility,
              size: 22, // 👈 Kích thước icon
            ),
            onPressed: toggleVisibility,
          ),
          border: const OutlineInputBorder(),
        ),
      ),
    );
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
      User? user = FirebaseAuth.instance.currentUser ;
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
        title: "Tài khoản",
        showToggleButtons: false,
        showMenuButton: true, // Hiển thị nút menu (Drawer)
        onMenuPressed: () {
          Scaffold.of(context).openDrawer(); // Mở drawer từ MainPage
        },
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Phần hiển thị thông tin chính
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Avatar người dùng
                          Center(
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 65,
                                  backgroundColor: _selectedImage == null && (_imageUrl == null || _imageUrl!.isEmpty)
                                      ? Colors.white // Hình tròn trắng nếu không có hình
                                      : null,
                                  backgroundImage: _imageUrl != null && _imageUrl!.isNotEmpty
                                      ? ( _imageUrl!.startsWith('assets/')
                                          ? AssetImage(_imageUrl!) // Sử dụng AssetImage nếu là hình ảnh từ assets
                                          : (_imageUrl!.startsWith('http') // Kiểm tra nếu hình ảnh là hình ảnh mạng
                                              ? NetworkImage(_imageUrl!) // Sử dụng NetworkImage nếu là hình ảnh từ URL
                                              : FileImage(File(_imageUrl!)))) // Sử dụng FileImage nếu là hình ảnh từ file
                                      : (_selectedImage != null 
                                          ? FileImage(_selectedImage!) // Sử dụng FileImage nếu có hình ảnh từ file
                                          : null),
                                ),
                                Positioned(
                                  bottom: 5,
                                  right: 5,
                                  child: GestureDetector(
                                    onTap: _changeAvatar, // Gọi hàm thay đổi hình ảnh
                                    child: Container(
                                      width: 35,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            blurRadius: 4,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.black54,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Phần tên đăng nhập
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/user_icon.png',
                                width: 27,
                                height: 27,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(width: 3),
                              const Text(
                                'Tên đăng nhập',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 7),
                          Container(
                            height: 55,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: const Color(0xFF1E201E),
                                width: 2,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 2,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller:
                                        _usernameController, // Sử dụng controller từ Firestore
                                    style: const TextStyle(fontSize: 15),
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
                          const SizedBox(height: 21),
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/image.png',
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
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 7),
                          Container(
                            height: 55,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: const Color(0xFF1E201E),
                                width: 2,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 2,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller:
                                        _emailController, // Sử dụng controller từ Firestore
                                    style: const TextStyle(fontSize: 15),
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
                          const SizedBox(height: 21),
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/phone_icon.png',
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
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 7),
                          Container(
                            height: 55,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: const Color(0xFF1E201E),
                                width: 2,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 2,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller:
                                        _phoneController, // Sử dụng controller từ Firestore
                                    style: const TextStyle(fontSize: 15),
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
                          const SizedBox(height: 21),
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/password_icon.png',
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
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 7),
                          Container(
                            height: 55,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: const Color(0xFF1E201E),
                                width: 2,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 2,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: TextEditingController(text: displayText),
                                    style: const TextStyle(fontSize: 15),
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    _isObscured
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isObscured =
                                          !_isObscured; // Đổi trạng thái hiển thị mật khẩu
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          // Link đổi mật khẩu
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: showChangePasswordDialog,
                                child: const Text(
                                  'Đổi mật khẩu ',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Image.asset(
                                'assets/images/arrow2_icon.png',
                                width: 15,
                                height: 15,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Phần nút "Lưu thay đổi" và "Hủy"
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(
                                    color: Color(0xFFFE0000),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: const Text(
                                'Hủy',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFFE0000),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
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
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(
                                    color: Color(0xFF4ABD57),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: const Text(
                                'Lưu thay đổi',
                                style: TextStyle(
                                  fontSize: 17,
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
            ),
          ),
        ),
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
