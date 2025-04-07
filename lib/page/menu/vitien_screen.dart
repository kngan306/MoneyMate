import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/menuitem/wallet_item.dart';

class ViTien extends StatefulWidget {
  const ViTien({Key? key}) : super(key: key);

  @override
  _ViTienState createState() => _ViTienState();
}

class _ViTienState extends State<ViTien> {
  String? userDocId; // ID của document người dùng trong Firestore
  String? cashWalletId; // ID của ví "Tiền mặt"
  String? transferWalletId; // ID của ví "Chuyển khoản"
  double cashBalance = 0.0; // Tổng tiền mặt
  double transferBalance = 0.0; // Tổng chuyển khoản
  double totalBalance = 0.0; // Tổng cộng
  String username = 'Người dùng'; // Giá trị mặc định nếu không tìm thấy username

  @override
  void initState() {
    super.initState();
    _loadData(); // Tải dữ liệu khi khởi tạo
  }

  // Hàm tải dữ liệu từ Firestore
  Future<void> _loadData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print('User UID: ${user.uid}'); // In UID của người dùng từ Firebase Auth
      print('User Email: ${user.email}'); // In email của người dùng

      // Lấy document người dùng từ Firestore dựa trên email
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      print('Number of user documents found: ${userDoc.docs.length}'); // In số lượng document tìm thấy
      if (userDoc.docs.isNotEmpty) {
        userDocId = userDoc.docs.first.id;
        print('User Document ID: $userDocId'); // In ID của document người dùng

        // Lấy username từ document người dùng
        username = userDoc.docs.first.data()['username'] ?? 'Người dùng'; // Nếu không có username, dùng giá trị mặc định
        print('Username: $username'); // In username

        await _loadWalletIds(userDocId!);
        await _calculateBalances(userDocId!);
        setState(() {});
      } else {
        print('Không tìm thấy thông tin người dùng trong Firestore.');
      }
    } else {
      print('Không có người dùng đăng nhập.');
    }
  }

  // Hàm lấy ID của các ví từ Firestore
  Future<void> _loadWalletIds(String userDocId) async {
    QuerySnapshot walletSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userDocId)
        .collection('vi_tien')
        .get();

    print('Number of wallets found: ${walletSnapshot.docs.length}'); // In số lượng ví tìm thấy
    for (var doc in walletSnapshot.docs) {
      String walletName = doc['ten_vi'] as String;
      print('Wallet ID: ${doc.id}, Name: $walletName'); // In ID và tên của từng ví
      if (walletName == 'Tiền mặt') {
        cashWalletId = doc.id;
      } else if (walletName == 'Chuyển khoản') {
        transferWalletId = doc.id;
      }
    }
    print('Cash Wallet ID: $cashWalletId'); // In ID của ví "Tiền mặt"
    print('Transfer Wallet ID: $transferWalletId'); // In ID của ví "Chuyển khoản"
  }

  // Hàm tính toán số dư cho từng loại ví
  Future<void> _calculateBalances(String userDocId) async {
    if (cashWalletId == null || transferWalletId == null) {
      print('Không tìm thấy ID của ví "Tiền mặt" hoặc "Chuyển khoản".');
      return;
    }

    // Tính tổng thu nhập và chi tiêu cho "Tiền mặt"
    QuerySnapshot cashIncomeSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userDocId)
        .collection('thu_nhap')
        .where('loai_vi', isEqualTo: cashWalletId)
        .get();
    print('Cash Income Documents: ${cashIncomeSnapshot.docs.length}'); // In số bản ghi thu nhập của "Tiền mặt"
    double cashIncome = cashIncomeSnapshot.docs.fold(0.0, (sum, doc) {
      double amount = (doc['so_tien'] as num).toDouble();
      print('Cash Income - Doc ID: ${doc.id}, Amount: $amount'); // In chi tiết từng bản ghi
      return sum + amount;
    });

    QuerySnapshot cashExpenseSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userDocId)
        .collection('chi_tieu')
        .where('loai_vi', isEqualTo: cashWalletId)
        .get();
    print('Cash Expense Documents: ${cashExpenseSnapshot.docs.length}'); // In số bản ghi chi tiêu của "Tiền mặt"
    double cashExpense = cashExpenseSnapshot.docs.fold(0.0, (sum, doc) {
      double amount = (doc['so_tien'] as num).toDouble();
      print('Cash Expense - Doc ID: ${doc.id}, Amount: $amount'); // In chi tiết từng bản ghi
      return sum + amount;
    });

    cashBalance = cashIncome - cashExpense;
    print('Cash Balance: $cashBalance'); // In số dư của "Tiền mặt"

    // Tính tổng thu nhập và chi tiêu cho "Chuyển khoản"
    QuerySnapshot transferIncomeSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userDocId)
        .collection('thu_nhap')
        .where('loai_vi', isEqualTo: transferWalletId)
        .get();
    print('Transfer Income Documents: ${transferIncomeSnapshot.docs.length}'); // In số bản ghi thu nhập của "Chuyển khoản"
    double transferIncome = transferIncomeSnapshot.docs.fold(0.0, (sum, doc) {
      double amount = (doc['so_tien'] as num).toDouble();
      print('Transfer Income - Doc ID: ${doc.id}, Amount: $amount'); // In chi tiết từng bản ghi
      return sum + amount;
    });

    QuerySnapshot transferExpenseSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userDocId)
        .collection('chi_tieu')
        .where('loai_vi', isEqualTo: transferWalletId)
        .get();
    print('Transfer Expense Documents: ${transferExpenseSnapshot.docs.length}'); // In số bản ghi chi tiêu của "Chuyển khoản"
    double transferExpense = transferExpenseSnapshot.docs.fold(0.0, (sum, doc) {
      double amount = (doc['so_tien'] as num).toDouble();
      print('Transfer Expense - Doc ID: ${doc.id}, Amount: $amount'); // In chi tiết từng bản ghi
      return sum + amount;
    });

    transferBalance = transferIncome - transferExpense;
    print('Transfer Balance: $transferBalance'); // In số dư của "Chuyển khoản"

    // Tính tổng cộng
    totalBalance = cashBalance + transferBalance;
    print('Total Balance: $totalBalance'); // In tổng cộng
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
         title: Text(
          "Ví của tôi",
          style: TextStyle(
            fontSize: 17,
            color: Colors.white,
          ),
        ),
        showToggleButtons: false,
        showMenuButton: true,
        onMenuPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 30.0, 16.0, 0.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting
                      Padding(
                        padding: const EdgeInsets.only(bottom: 22.0),
                        child: Text(
                          'Xin chào $username!', // Hiển thị username
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),

                      // Total Card
                      WalletItem(
                        iconPath: 'assets/images/calculator.png',
                        title: 'Tổng cộng',
                        amount: NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(totalBalance),
                        showAction: false,
                      ),

                      const SizedBox(height: 11),

                      // Cash Card
                      WalletItem(
                        iconPath: 'assets/images/cate30.png',
                        title: 'Tiền mặt',
                        amount: NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(cashBalance),
                      ),

                      const SizedBox(height: 11),

                      // E-wallet Card
                      WalletItem(
                        iconPath: 'assets/images/cate29.png',
                        title: 'Chuyển khoản',
                        amount: NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(transferBalance),
                      ),
                    ],
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