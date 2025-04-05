import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class DatabaseHelper {
  // Singleton pattern
  static final DatabaseHelper instance = DatabaseHelper._init();
  DatabaseHelper._init();

  // Tham chiếu đến Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Hàm thêm người dùng (users)
  Future<void> addUser(Map<String, dynamic> userData) async {
    await _firestore.collection('users').add({
      'sdt': userData['sdt'],
      'email': userData['email'],
      'username': userData['username'],
      'password': userData['password'],
      'image': userData['image'] ?? 'assets/images/default_user.png',
    });
  }

  // Hàm lấy danh sách người dùng
  Future<List<Map<String, dynamic>>> getUsers() async {
    QuerySnapshot snapshot = await _firestore.collection('users').get();
    return snapshot.docs.map((doc) => {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        }).toList();
  }

  // Hàm thêm ví tiền (vi_tien)
  Future<void> addViTien(Map<String, dynamic> viTienData) async {
    await _firestore.collection('vi_tien').add({
      'ten_vi': viTienData['ten_vi'],
    });
  }

  // Hàm lấy danh sách ví tiền
  Future<List<Map<String, dynamic>>> getViTien() async {
    QuerySnapshot snapshot = await _firestore.collection('vi_tien').get();
    return snapshot.docs.map((doc) => {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        }).toList();
  }

  // Hàm thêm danh mục thu (danh_muc_thu)
  Future<void> addDanhMucThu(Map<String, dynamic> danhMucThuData) async {
    await _firestore.collection('danh_muc_thu').add({
      'ten_muc_thu': danhMucThuData['ten_muc_thu'],
      'image': danhMucThuData['image'] ?? 'assets/images/default_income.png',
    });
  }

  // Hàm lấy danh sách danh mục thu
  Future<List<Map<String, dynamic>>> getDanhMucThu() async {
    QuerySnapshot snapshot = await _firestore.collection('danh_muc_thu').get();
    return snapshot.docs.map((doc) => {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        }).toList();
  }

  // Hàm thêm thu nhập (thu_nhap)
  Future<void> addThuNhap(Map<String, dynamic> thuNhapData) async {
    await _firestore.collection('thu_nhap').add({
      'ngay': thuNhapData['ngay'], // Định dạng dd/MM/yy
      'so_tien': thuNhapData['so_tien'],
      'ghi_chu': thuNhapData['ghi_chu'],
      'muc_thu_nhap': thuNhapData['muc_thu_nhap'], // ID tham chiếu đến danh_muc_thu
      'loai_vi': thuNhapData['loai_vi'], // ID tham chiếu đến vi_tien
    });
  }

  // Hàm lấy danh sách thu nhập
  Future<List<Map<String, dynamic>>> getThuNhap() async {
    QuerySnapshot snapshot = await _firestore.collection('thu_nhap').get();
    return snapshot.docs.map((doc) => {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        }).toList();
  }

  // Hàm thêm danh mục chi (danh_muc_chi)
  Future<void> addDanhMucChi(Map<String, dynamic> danhMucChiData) async {
    await _firestore.collection('danh_muc_chi').add({
      'ten_muc_chi': danhMucChiData['ten_muc_chi'],
      'image': danhMucChiData['image'] ?? 'assets/images/default_expense.png',
    });
  }

  // Hàm lấy danh sách danh mục chi
  Future<List<Map<String, dynamic>>> getDanhMucChi() async {
    QuerySnapshot snapshot = await _firestore.collection('danh_muc_chi').get();
    return snapshot.docs.map((doc) => {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        }).toList();
  }

  // Hàm thêm chi tiêu (chi_tieu)
  Future<void> addChiTieu(Map<String, dynamic> chiTieuData) async {
    await _firestore.collection('chi_tieu').add({
      'ngay': chiTieuData['ngay'], // Định dạng dd/MM/yy
      'so_tien': chiTieuData['so_tien'],
      'ghi_chu': chiTieuData['ghi_chu'],
      'muc_chi_tieu': chiTieuData['muc_chi_tieu'], // ID tham chiếu đến danh_muc_chi
      'loai_vi': chiTieuData['loai_vi'], // ID tham chiếu đến vi_tien
    });
  }

  // Hàm lấy danh sách chi tiêu
  Future<List<Map<String, dynamic>>> getChiTieu() async {
    QuerySnapshot snapshot = await _firestore.collection('chi_tieu').get();
    return snapshot.docs.map((doc) => {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        }).toList();
  }

  // Hàm kiểm tra kết nối mạng và thực hiện đồng bộ (nếu cần)
  Future<void> autoSync() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      // Dữ liệu đã được lưu trực tiếp trên Firestore, không cần đồng bộ thủ công
      print("Đã kết nối mạng, dữ liệu được lưu trên Firestore.");
    } else {
      print("Không có kết nối mạng.");
    }
  }
}