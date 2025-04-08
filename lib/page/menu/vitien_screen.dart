import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/menuitem/wallet_item.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:diacritic/diacritic.dart';

class ViTien extends StatefulWidget {
  const ViTien({Key? key}) : super(key: key);

  @override
  _ViTienState createState() => _ViTienState();
}

class _ViTienState extends State<ViTien> {
  String? userDocId;
  String? cashWalletId;
  String? transferWalletId;
  double cashBalance = 0.0;
  double transferBalance = 0.0;
  double totalBalance = 0.0;
  String username = 'Người dùng';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print('User UID: ${user.uid}');
      print('User Email: ${user.email}');

      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      print('Number of user documents found: ${userDoc.docs.length}');
      if (userDoc.docs.isNotEmpty) {
        userDocId = userDoc.docs.first.id;
        print('User Document ID: $userDocId');

        username = userDoc.docs.first.data()['username'] ?? 'Người dùng';
        print('Username: $username');

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

  Future<void> _loadWalletIds(String userDocId) async {
    QuerySnapshot walletSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userDocId)
        .collection('vi_tien')
        .get();

    print('Number of wallets found: ${walletSnapshot.docs.length}');
    for (var doc in walletSnapshot.docs) {
      String walletName = doc['ten_vi'] as String;
      print('Wallet ID: ${doc.id}, Name: $walletName');

      String normalizedWalletName = removeDiacritics(walletName).toLowerCase();
      print('Normalized Wallet Name: $normalizedWalletName');

      if (normalizedWalletName == removeDiacritics('Tiền mặt').toLowerCase()) {
        cashWalletId = doc.id;
      } else if (normalizedWalletName ==
          removeDiacritics('Chuyển khoản').toLowerCase()) {
        transferWalletId = doc.id;
      }
    }
    print('Cash Wallet ID: $cashWalletId');
    print('Transfer Wallet ID: $transferWalletId');
  }

  Future<void> _calculateBalances(String userDocId) async {
    if (cashWalletId == null || transferWalletId == null) {
      print('Không tìm thấy ID của ví "Tiền mặt" hoặc "Chuyển khoản".');
      return;
    }

    // Thêm: In toàn bộ dữ liệu trong thu_nhap và chi_tieu để debug
    print('--- Debugging thu_nhap ---');
    QuerySnapshot allIncomeSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userDocId)
        .collection('thu_nhap')
        .get();
    print('Total Income Documents: ${allIncomeSnapshot.docs.length}');
    for (var doc in allIncomeSnapshot.docs) {
      print('Income Doc ID: ${doc.id}, Data: ${doc.data()}');
    }

    print('--- Debugging chi_tieu ---');
    QuerySnapshot allExpenseSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userDocId)
        .collection('chi_tieu')
        .get();
    print('Total Expense Documents: ${allExpenseSnapshot.docs.length}');
    for (var doc in allExpenseSnapshot.docs) {
      print('Expense Doc ID: ${doc.id}, Data: ${doc.data()}');
    }

    // Tính tổng thu nhập và chi tiêu cho "Tiền mặt"
    QuerySnapshot cashIncomeSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userDocId)
        .collection('thu_nhap')
        .where('loai_vi', isEqualTo: cashWalletId)
        .get();
    print('Cash Income Documents: ${cashIncomeSnapshot.docs.length}');
    double cashIncome = cashIncomeSnapshot.docs.fold(0.0, (sum, doc) {
      double amount = (doc['so_tien'] as num).toDouble();
      print('Cash Income - Doc ID: ${doc.id}, Amount: $amount');
      return sum + amount;
    });

    QuerySnapshot cashExpenseSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userDocId)
        .collection('chi_tieu')
        .where('loai_vi', isEqualTo: cashWalletId)
        .get();
    print('Cash Expense Documents: ${cashExpenseSnapshot.docs.length}');
    double cashExpense = cashExpenseSnapshot.docs.fold(0.0, (sum, doc) {
      double amount = (doc['so_tien'] as num).toDouble();
      print('Cash Expense - Doc ID: ${doc.id}, Amount: $amount');
      return sum + amount;
    });

    cashBalance = cashIncome - cashExpense;
    print('Cash Balance: $cashBalance');

    // Tính tổng thu nhập và chi tiêu cho "Chuyển khoản"
    QuerySnapshot transferIncomeSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userDocId)
        .collection('thu_nhap')
        .where('loai_vi', isEqualTo: transferWalletId)
        .get();
    print('Transfer Income Documents: ${transferIncomeSnapshot.docs.length}');
    double transferIncome = transferIncomeSnapshot.docs.fold(0.0, (sum, doc) {
      double amount = (doc['so_tien'] as num).toDouble();
      print('Transfer Income - Doc ID: ${doc.id}, Amount: $amount');
      return sum + amount;
    });

    QuerySnapshot transferExpenseSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userDocId)
        .collection('chi_tieu')
        .where('loai_vi', isEqualTo: transferWalletId)
        .get();
    print('Transfer Expense Documents: ${transferExpenseSnapshot.docs.length}');
    double transferExpense = transferExpenseSnapshot.docs.fold(0.0, (sum, doc) {
      double amount = (doc['so_tien'] as num).toDouble();
      print('Transfer Expense - Doc ID: ${doc.id}, Amount: $amount');
      return sum + amount;
    });

    transferBalance = transferIncome - transferExpense;
    print('Transfer Balance: $transferBalance');

    totalBalance = cashBalance + transferBalance;
    print('Total Balance: $totalBalance');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          "Ví của tôi",
          style: TextStyle(
            fontSize: 20.sp,
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
                  padding: EdgeInsets.fromLTRB(16.0.w, 30.0.h, 16.0.w, 0.0.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 22.0.h),
                        child: Text(
                          'Xin chào $username!',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                      WalletItem(
                        iconPath: 'assets/images/calculator.png',
                        title: 'Tổng cộng',
                        amount:
                            NumberFormat.currency(locale: 'vi_VN', symbol: 'đ')
                                .format(totalBalance),
                        showAction: false,
                      ),
                      SizedBox(height: 11.h),
                      WalletItem(
                        iconPath: 'assets/images/cate30.png',
                        title: 'Tiền mặt',
                        amount:
                            NumberFormat.currency(locale: 'vi_VN', symbol: 'đ')
                                .format(cashBalance),
                      ),
                      SizedBox(height: 11.h),
                      WalletItem(
                        iconPath: 'assets/images/cate29.png',
                        title: 'Chuyển khoản',
                        amount:
                            NumberFormat.currency(locale: 'vi_VN', symbol: 'đ')
                                .format(transferBalance),
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
