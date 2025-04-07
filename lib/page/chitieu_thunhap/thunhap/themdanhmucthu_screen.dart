import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../widgets/cateitem/category3_item.dart';

class ThemDanhMucThu extends StatefulWidget {
  const ThemDanhMucThu({Key? key}) : super(key: key);

  @override
  State<ThemDanhMucThu> createState() => _ThemDanhMucThuState();
}

class _ThemDanhMucThuState extends State<ThemDanhMucThu> {
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
              .collection('danh_muc_thu')
              .add({
            'ten_muc_thu': _categoryNameController.text,
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
        title: const Text(
          'Danh mục thu nhập',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 20,
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
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 25.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Tên danh mục",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0x80000000),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _categoryNameController,
                      decoration: const InputDecoration(
                        hintText: "Nhập tên danh mục",
                        hintStyle: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 17,
                          vertical: 18,
                        ),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 15,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 24.0),
                    child: Text(
                      "Biểu tượng",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
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
                      padding: const EdgeInsets.only(top: 20.0, bottom: 30),
                      child: ElevatedButton(
                        onPressed: _saveCategory,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E201E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          minimumSize: const Size(220, 0),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 70,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          "Lưu",
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 17,
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