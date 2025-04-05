import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'database_helper.dart'; // Import DatabaseHelper từ file của bạn

class InitData {
  static Future<void> initializeSampleData() async {
    // Đảm bảo Firebase đã được khởi tạo
    await Firebase.initializeApp();

    final dbHelper = DatabaseHelper.instance;

    // Thêm người dùng mẫu
    await dbHelper.addUser({
      'sdt': '0764474686',
      'email': 'duykhaduongwork@gmail.com',
      'username': 'DuyKhaaa',
      'password': '123',
      'image': 'assets/images/avt.jpg',
    });
    print('Đã thêm người dùng mẫu');

    // Thêm ví tiền mẫu
    DocumentReference viTienRef = await _addViTienSample(dbHelper);
    String viTienId = viTienRef.id;

    // Thêm danh mục thu mẫu
    DocumentReference danhMucThuRef = await _addDanhMucThuSample(dbHelper);
    String danhMucThuId = danhMucThuRef.id;

    // Thêm danh mục chi mẫu
    DocumentReference danhMucChiRef = await _addDanhMucChiSample(dbHelper);
    String danhMucChiId = danhMucChiRef.id;

    // Thêm thu nhập mẫu
    await dbHelper.addThuNhap({
      'ngay': '05/04/25',
      'so_tien': 1000000,
      'ghi_chu': 'Lương tháng 4',
      'muc_thu_nhap': danhMucThuId, // Sử dụng ID từ danh_muc_thu
      'loai_vi': viTienId, // Sử dụng ID từ vi_tien
    });
    print('Đã thêm thu nhập mẫu');

    // Thêm chi tiêu mẫu
    await dbHelper.addChiTieu({
      'ngay': '05/04/25',
      'so_tien': 200000,
      'ghi_chu': 'Ăn trưa',
      'muc_chi_tieu': danhMucChiId, // Sử dụng ID từ danh_muc_chi
      'loai_vi': viTienId, // Sử dụng ID từ vi_tien
    });
    print('Đã thêm chi tiêu mẫu');

    print('Khởi tạo dữ liệu mẫu hoàn tất!');
  }

  // Hàm phụ để thêm ví tiền và trả về DocumentReference
  static Future<DocumentReference> _addViTienSample(DatabaseHelper dbHelper) async {
    return await FirebaseFirestore.instance.collection('vi_tien').add({
      'ten_vi': 'Tiền mặt',
      'ten_vi': 'Chuyển khoản',
    });
  }

  // Hàm phụ để thêm danh mục thu và trả về DocumentReference
  static Future<DocumentReference> _addDanhMucThuSample(DatabaseHelper dbHelper) async {
    return await FirebaseFirestore.instance.collection('danh_muc_thu').add({
      'ten_muc_thu': 'Tiền lương',
      'image': 'assets/images/salary.png',
    });
  }

  // Hàm phụ để thêm danh mục chi và trả về DocumentReference
  static Future<DocumentReference> _addDanhMucChiSample(DatabaseHelper dbHelper) async {
    return await FirebaseFirestore.instance.collection('danh_muc_chi').add({
      'ten_muc_chi': 'Ăn uống',
      'image': 'assets/images/cate5.png',
    });
  }
}