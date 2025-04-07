import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../widgets/cateitem/category2_item.dart';
import 'themdanhmucchi_screen.dart';
import '../../mainpage.dart';

class DanhMucChi extends StatefulWidget {
  const DanhMucChi({Key? key}) : super(key: key);

  @override
  State<DanhMucChi> createState() => _DanhMucChiState();
}

class _DanhMucChiState extends State<DanhMucChi> {
  Map<String, bool> categoryCheckStates = {};
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allCategories = [];
  List<Map<String, dynamic>> _filteredCategories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories(); // Tải danh mục khi khởi tạo
    _searchController.addListener(_filterCategories);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Hàm tải danh mục từ Firestore
  Future<void> _loadCategories() async {
    List<Map<String, dynamic>> categories = await _loadExpenseCategories();
    setState(() {
      _allCategories = categories;
      _filteredCategories = List.from(_allCategories);
      // Đặt lại trạng thái checkbox
      categoryCheckStates.clear();
      for (var category in _allCategories) {
        categoryCheckStates[category['id']] = false;
      }
    });
  }

  Future<List<Map<String, dynamic>>> _loadExpenseCategories() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      if (userDoc.docs.isNotEmpty) {
        String userDocId = userDoc.docs.first.id;
        QuerySnapshot categorySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userDocId)
            .collection('danh_muc_chi')
            .get();

        return categorySnapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'name': doc['ten_muc_chi'] as String,
            'image': doc['image'] as String,
          };
        }).toList();
      }
    }
    return [];
  }

  void _filterCategories() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCategories = List.from(_allCategories);
      } else {
        _filteredCategories = _allCategories
            .where((category) => category['name'].toLowerCase().contains(query))
            .toList();
      }
    });
  }

  Future<void> _deleteSelectedCategories() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      if (userDoc.docs.isNotEmpty) {
        String userDocId = userDoc.docs.first.id;
        List<String> selectedCategoryIds = categoryCheckStates.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();

        if (selectedCategoryIds.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Vui lòng chọn ít nhất một danh mục để xóa')),
          );
          return;
        }

        for (String categoryId in selectedCategoryIds) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userDocId)
              .collection('danh_muc_chi')
              .doc(categoryId)
              .delete();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Đã xóa ${selectedCategoryIds.length} danh mục')),
        );

        // Tải lại danh mục sau khi xóa
        await _loadCategories();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E201E),
        title: const Text(
          'Danh mục chi tiêu',
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
      body: SafeArea(
        child: Center(
          child: Container(
            width: double.infinity,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 30.0, 16.0, 0.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color.fromRGBO(0, 0, 0, 0.5),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 11),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/search_icon.png',
                          width: 28,
                          height: 28,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Tìm kiếm danh mục đã thêm',
                              hintStyle: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 15,
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 30.0, 16.0, 0.0),
                  child: GestureDetector(
                    onTap: () async {
                      // Chuyển đến màn hình thêm danh mục và chờ kết quả
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ThemDanhMucChi(),
                        ),
                      );
                      // Nếu thêm danh mục thành công, tải lại danh sách
                      if (result == true) {
                        await _loadCategories();
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 17),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Thêm danh mục',
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 17,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Image.asset(
                            'assets/images/arrow2_icon.png',
                            width: 20,
                            height: 20,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 30.0, 16.0, 0.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 19, vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  bool newValue = !categoryCheckStates.values
                                      .every((element) => element);
                                  categoryCheckStates
                                      .updateAll((key, value) => newValue);
                                });
                              },
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                ),
                                child: categoryCheckStates.values
                                        .every((element) => element)
                                    ? const Icon(Icons.check, size: 16)
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 13),
                            Text(
                              'Chọn',
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 17,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: _deleteSelectedCategories,
                          child: Image.asset(
                            'assets/images/delete_icon.png',
                            width: 27,
                            height: 27,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 0.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color.fromRGBO(0, 0, 0, 0.1),
                        width: 1,
                      ),
                    ),
                    child: SizedBox(
                      height: 370,
                      child: SingleChildScrollView(
                        child: Column(
                          children:
                              _filteredCategories.asMap().entries.map((entry) {
                            int index = entry.key;
                            var category = entry.value;
                            return CategoryItem(
                              categoryKey: category['id'],
                              title: category['name'],
                              iconUrl: category['image'],
                              arrowUrl: 'assets/images/arrow2_icon.png',
                              isFirstItem: index == 0,
                              isLastItem:
                                  index == _filteredCategories.length - 1,
                              isChecked: categoryCheckStates[category['id']]!,
                              onCheckboxChanged: (value) {
                                setState(() {
                                  categoryCheckStates[category['id']] = value;
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
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
