import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseHelper {
  // Singleton pattern để đảm bảo chỉ có một instance của DatabaseHelper
  static final DatabaseHelper instance = DatabaseHelper._init();
  DatabaseHelper._init();

  // Tham chiếu đến Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Hàm lấy UID của người dùng hiện tại từ Firebase Authentication
  String? _getCurrentUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  // Hàm thêm người dùng (users) vào Firestore
  Future<void> addUser(Map<String, dynamic> userData) async {
    await _firestore.collection('users').doc(userData['email']).set({
      'sdt': userData['sdt'],
      'email': userData['email'],
      'username': userData['username'],
      'password': userData['password'],
      'image': userData['image'], // Không đặt giá trị mặc định, để null nếu không có
    });
  }

  // Hàm lấy thông tin người dùng hiện tại
  Future<Map<String, dynamic>?> getCurrentUser() async {
    String? userId = _getCurrentUserId();
    if (userId != null) {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }
    }
    return null;
  }

  // Hàm thêm ví tiền (vi_tien) cho người dùng hiện tại
  Future<void> addViTien(Map<String, dynamic> viTienData) async {
    String? userId = _getCurrentUserId();
    if (userId != null) {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('vi_tien')
          .add({
        'ten_vi': viTienData['ten_vi'],
      });
    }
  }

  // Hàm lấy danh sách ví tiền của người dùng hiện tại
  Future<List<Map<String, dynamic>>> getViTien() async {
    String? userId = _getCurrentUserId();
    if (userId != null) {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('vi_tien')
          .get();
      return snapshot.docs.map((doc) => {
            'id': doc.id,
            ...doc.data() as Map<String, dynamic>,
          }).toList();
    }
    return [];
  }

  // Hàm thêm danh mục thu (danh_muc_thu) cho người dùng hiện tại
  Future<void> addDanhMucThu(Map<String, dynamic> danhMucThuData) async {
    String? userId = _getCurrentUserId();
    if (userId != null) {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('danh_muc_thu')
          .add({
        'ten_muc_thu': danhMucThuData['ten_muc_thu'],
        'image': danhMucThuData['image'], // Không đặt giá trị mặc định, để null nếu không có
      });
    }
  }

  // Hàm lấy danh sách danh mục thu của người dùng hiện tại
  Future<List<Map<String, dynamic>>> getDanhMucThu() async {
    String? userId = _getCurrentUserId();
    if (userId != null) {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('danh_muc_thu')
          .get();
      return snapshot.docs.map((doc) => {
            'id': doc.id,
            ...doc.data() as Map<String, dynamic>,
          }).toList();
    }
    return [];
  }

  // Hàm thêm thu nhập (thu_nhap) cho người dùng hiện tại
  Future<void> addThuNhap(Map<String, dynamic> thuNhapData) async {
    String? userId = _getCurrentUserId();
    if (userId != null) {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('thu_nhap')
          .add({
        'ngay': thuNhapData['ngay'], // Định dạng dd/MM/yy
        'so_tien': thuNhapData['so_tien'],
        'ghi_chu': thuNhapData['ghi_chu'],
        'muc_thu_nhap': thuNhapData['muc_thu_nhap'], // ID tham chiếu đến danh_muc_thu
        'loai_vi': thuNhapData['loai_vi'], // ID tham chiếu đến vi_tien
      });
    }
  }

  // Hàm lấy danh sách thu nhập của người dùng hiện tại
  Future<List<Map<String, dynamic>>> getThuNhap() async {
    String? userId = _getCurrentUserId();
    if (userId != null) {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('thu_nhap')
          .get();
      return snapshot.docs.map((doc) => {
            'id': doc.id,
            ...doc.data() as Map<String, dynamic>,
          }).toList();
    }
    return [];
  }

  // Hàm thêm danh mục chi (danh_muc_chi) cho người dùng hiện tại
  Future<void> addDanhMucChi(Map<String, dynamic> danhMucChiData) async {
    String? userId = _getCurrentUserId();
    if (userId != null) {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('danh_muc_chi')
          .add({
        'ten_muc_chi': danhMucChiData['ten_muc_chi'],
        'image': danhMucChiData['image'], // Không đặt giá trị mặc định, để null nếu không có
      });
    }
  }

  // Hàm lấy danh sách danh mục chi của người dùng hiện tại
  Future<List<Map<String, dynamic>>> getDanhMucChi() async {
    String? userId = _getCurrentUserId();
    if (userId != null) {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('danh_muc_chi')
          .get();
      return snapshot.docs.map((doc) => {
            'id': doc.id,
            ...doc.data() as Map<String, dynamic>,
          }).toList();
    }
    return [];
  }

  // Hàm thêm chi tiêu (chi_tieu) cho người dùng hiện tại
  Future<void> addChiTieu(Map<String, dynamic> chiTieuData) async {
    String? userId = _getCurrentUserId();
    if (userId != null) {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('chi_tieu')
          .add({
        'ngay': chiTieuData['ngay'], // Định dạng dd/MM/yy
        'so_tien': chiTieuData['so_tien'],
        'ghi_chu': chiTieuData['ghi_chu'],
        'muc_chi_tieu': chiTieuData['muc_chi_tieu'], // ID tham chiếu đến danh_muc_chi
        'loai_vi': chiTieuData['loai_vi'], // ID tham chiếu đến vi_tien
      });
    }
  }

  // Hàm lấy danh sách chi tiêu của người dùng hiện tại
  Future<List<Map<String, dynamic>>> getChiTieu() async {
    String? userId = _getCurrentUserId();
    if (userId != null) {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('chi_tieu')
          .get();
      return snapshot.docs.map((doc) => {
            'id': doc.id,
            ...doc.data() as Map<String, dynamic>,
          }).toList();
    }
    return [];
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