import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../widgets/cateitem/category3_item.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ThemDanhMucChi extends StatefulWidget {
  const ThemDanhMucChi({Key? key}) : super(key: key);

  @override
  State<ThemDanhMucChi> createState() => _ThemDanhMucChiState();
}

class _ThemDanhMucChiState extends State<ThemDanhMucChi> {
  final TextEditingController _categoryNameController = TextEditingController();
  int? _selectedIconIndex;

  final List<String> _iconCate =
      List.generate(56, (index) => 'assets/images/cate${index + 1}.png');

  @override
  void dispose() {
    _categoryNameController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (_categoryNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập tên danh mục')),
      );
      return;
    }

    if (_selectedIconIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng chọn một biểu tượng')),
      );
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        var userDoc = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: user.email)
            .get();

        if (userDoc.docs.isNotEmpty) {
          String userDocId = userDoc.docs.first.id;

          await FirebaseFirestore.instance
              .collection('users')
              .doc(userDocId)
              .collection('danh_muc_chi')
              .add({
            'ten_muc_chi': _categoryNameController.text,
            'image': _iconCate[_selectedIconIndex!],
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã lưu danh mục thành công')),
          );

          setState(() {
            _categoryNameController.clear();
            _selectedIconIndex = null;
          });

          // Trả về true để thông báo rằng danh mục đã được thêm thành công
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không tìm thấy thông tin người dùng')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi lưu danh mục: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng đăng nhập để lưu danh mục')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E201E),
        title: Text(
          'Danh mục chi tiêu',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 20.sp,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 16.0.w,
                right: 16.0.w,
                top: 25.0.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tên danh mục",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17.sp,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0x80000000),
                        width: 1.w,
                      ),
                    ),
                    child: TextField(
                      controller: _categoryNameController,
                      decoration: InputDecoration(
                        hintText: "Nhập tên danh mục",
                        hintStyle: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 15.sp,
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 17.w,
                          vertical: 18.h,
                        ),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 15.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 24.0.h),
                    child: Text(
                      "Biểu tượng",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 17.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0.h),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5,
                        childAspectRatio: 1.08,
                      ),
                      itemCount: _iconCate.length,
                      itemBuilder: (context, index) {
                        return CategoryItem(
                          imageUrl: _iconCate[index],
                          isSelected: _selectedIconIndex == index,
                          onTap: () {
                            setState(() {
                              _selectedIconIndex = index;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 20.0.h, bottom: 30.h),
                      child: ElevatedButton(
                        onPressed: _saveCategory,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E201E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          minimumSize: Size(220.w, 0),
                          padding: EdgeInsets.symmetric(
                            horizontal: 70.w,
                            vertical: 12.h,
                          ),
                        ),
                        child: Text(
                          "Lưu",
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 17.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
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
    );
  }
}
