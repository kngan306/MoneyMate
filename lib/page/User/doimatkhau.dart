import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../widgets/custom_app_bar.dart';
import '../authentication/forgotpass/quenmatkhau_screen.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isCurrentObscured = true;
  bool _isNewObscured = true;
  bool _isConfirmObscured = true;

  Future<void> _changePassword() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu mới không khớp')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      if (userDoc.docs.isNotEmpty) {
        final storedPassword = userDoc.docs.first['password'];

        if (storedPassword != currentPassword) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mật khẩu hiện tại không đúng')),
          );
          return;
        }

        // Update password in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userDoc.docs.first.id)
            .update({'password': newPassword});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đổi mật khẩu thành công')),
        );

        Navigator.pop(context); // Quay lại màn trước
      }
    }
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool isObscured,
    VoidCallback toggleObscure,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset(
              'assets/images/password_icon.png',
              width: 27.w,
              height: 27.h,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 8.w),
            Text(
              label,
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
                  controller: controller,
                  obscureText: isObscured,
                  style: TextStyle(fontSize: 15.sp),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  isObscured ? Icons.visibility_off : Icons.visibility,
                  color: Colors.black,
                ),
                onPressed: toggleObscure,
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: CustomAppBar(
        title: Text(
          "Đổi mật khẩu",
          style: TextStyle(
            fontSize: 20.sp,
            color: Colors.white,
          ),
        ),
        showBackButton: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPasswordField(
              "Mật khẩu hiện tại",
              _currentPasswordController,
              _isCurrentObscured,
              () => setState(() => _isCurrentObscured = !_isCurrentObscured),
            ),
            _buildPasswordField(
              "Mật khẩu mới",
              _newPasswordController,
              _isNewObscured,
              () => setState(() => _isNewObscured = !_isNewObscured),
            ),
            _buildPasswordField(
              "Xác nhận mật khẩu mới",
              _confirmPasswordController,
              _isConfirmObscured,
              () => setState(() => _isConfirmObscured = !_isConfirmObscured),
            ),
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
            SizedBox(height: 15.h),
            Center(
              child: SizedBox(
                width: 200.w,
                child: OutlinedButton(
                  onPressed: _changePassword,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    side: BorderSide(color: Colors.white, width: 2.w),
                    backgroundColor: Color(0xFF4ABD57),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                  ),
                  child: Text(
                    "Đổi mật khẩu",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
