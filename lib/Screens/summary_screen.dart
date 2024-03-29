import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_segmented_control/material_segmented_control.dart';
import '../models/transaction.dart';
import '../models/transaction_controller.dart';
import 'package:snabbudget/utils/custom_drawer.dart';
 import '../utils/category_widget.dart';
import '../utils/summary_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class SummaryScreen extends StatefulWidget {
  static const routeName = "summary-screen";
  SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey =  GlobalKey<ScaffoldState>();
  int check = 0;
  List<String> months = [
    "Janvary",
    "Feburary",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];
  int _currentSelection = 0;

  final String userId = FirebaseAuth.instance.currentUser!.uid;
  List<Transaction> transactions = [];

  @override
  void initState() {
    super.initState();
  TransactionData transactionData = TransactionData();
   transactionData.fetchTransactions(userId);
   transactions = transactionData.transactions;
   print(transactions);
  }
  
  @override
  Widget build(BuildContext context) {
  final Map<int, Widget> _children = {
  0: Text(AppLocalizations.of(context)!.summary,style: GoogleFonts.montserrat(),),
  1:  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child:Text(AppLocalizations.of(context)!.category,style: GoogleFonts.montserrat(),)),
  };
    List<Widget> children = [
    SummaryWidget(transactions: transactions,months: months,),
    CategoryWidget(transactions: transactions, months:months)
  ];
    return Scaffold(
      key: scaffoldKey,
      drawer: const CustomDrawer(),
      body: SafeArea(child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Card(
              child: SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 IconButton(
                            onPressed: () {
                              scaffoldKey.currentState?.openDrawer();
                            },
                            icon: const ImageIcon(
                              AssetImage("assets/images/menu.png"),
                              size: 40,
                            )),
                const Text(
                  "Summery",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 50,)
              ],
            ),
          )),
          const SizedBox(height: 5,),
          MaterialSegmentedControl(
            verticalOffset: 12,
          selectionIndex: _currentSelection,
          borderColor: Theme.of(context).primaryColor ,
          selectedColor: Theme.of(context).primaryColor,
          unselectedColor: Colors.white,
          selectedTextStyle: const TextStyle(color: Colors.white),
          unselectedTextStyle: TextStyle(color: Theme.of(context).primaryColor),
          borderWidth: 0.7,
          borderRadius: 32.0,
          disabledChildren: const [3],
          onSegmentTapped: (index) {
        setState(() {
          _currentSelection = index;
        });
          },
          children: _children,
      ),
      const SizedBox(height: 10,),
      children[_currentSelection]
          ],
        ),
      ))
    );
  }
}