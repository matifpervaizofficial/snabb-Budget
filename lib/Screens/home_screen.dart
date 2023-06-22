// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction ;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:snabbudget/Screens/daily_stats.dart';
import 'package:snabbudget/Screens/dashboard_screen.dart';

import '../models/transaction.dart';
import '../utils/custom_bottombar.dart';
import '../utils/expandable_fab.dart';
import 'auth/profileview.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = "home-screen";
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  int check = 0;
  late PageController _pageController;
  String name = "";
  String email = "";
  String phone = "";
  List<Transaction> transactionsList= [];
  final userId = FirebaseAuth.instance.currentUser!.uid;
  void getInfo() async {
    var collection = FirebaseFirestore.instance.collection('UsersData');
    var docSnapshot = await collection.doc(userId).get();
    if (docSnapshot.exists) {
      print("ok");
      Map<String, dynamic>? data = docSnapshot.data();
      setState(() {
        name = data?["First Name"];
        email = data?["Email"];
      });
    }
    print(userId);
  }
  
Future<List<Transaction>> fetchTransactions() async {
  List<Transaction> transactions = [];

  QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
      .collection('UserTransactions')
      .doc(userId)
      .collection('transactions')
      .get();

  List<QueryDocumentSnapshot<Map<String, dynamic>>> documents = querySnapshot.docs;

  for (var document in documents) {
    Transaction transaction = Transaction.fromJson(document.data());
    transactions.add(transaction);
  }

  setState(() {
    transactionsList = transactions;
  });
  return transactions;
}

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    fetchTransactions();
    print(transactionsList);
  }

  @override
  Widget build(BuildContext context) {
    if (check == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) => getInfo());
      check++;
    }
    final List<Widget> pages = [
    DashboardScreen(transactions: transactionsList,),
    DailyStats(),
    ProfileView(name: name,email: email),
  ];
    return Scaffold(
      key: scaffoldKey,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: const ExpandableFloatingActionButton(),
      body: PageView(
        controller: _pageController,
        children: pages,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      bottomNavigationBar: CustomBottomBar(
        selectedIndex: _selectedIndex,
        onTabSelected: (index) {
          setState(() {
            _selectedIndex = index;
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        },
      ),
    );
  }
}
