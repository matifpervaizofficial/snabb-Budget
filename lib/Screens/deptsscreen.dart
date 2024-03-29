// // ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter_gen/gen_l10n/app_localization.dart';
// import '../controller/balanceProvider.dart';
// import '../models/balance_data.dart';
// import '../models/currency_controller.dart';
// import '../models/dept.dart';
// import '../utils/balance_ex.dart';
// import '../utils/custom_drawer.dart';
// import 'package:velocity_x/velocity_x.dart';

// class BalanceScreen extends StatefulWidget {
//   static const routeName = "balance-screen";
//   final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

//   BalanceScreen({super.key});
//   @override
//   State<BalanceScreen> createState() => _BalanceScreenState();
// }

// class _BalanceScreenState extends State<BalanceScreen> {
//   String? currency = "";
//   final String userId = FirebaseAuth.instance.currentUser!.uid;
//   num balance = 0;
//   getCurrency() async {
//     CurrencyData currencyData = CurrencyData();
//     currency = await currencyData.fetchCurrency(userId);
//     //currency = currencyData.currency;
//     print(currency);
//   }

//   String calculateTotal(List<Dept> debts) {
//     double total = 0.0;

//     for (var debt in debts) {
//       if (debt.type == 'credit') {
//         total += debt.amount;
//       } else if (debt.type == 'debit') {
//         total -= debt.amount;
//       }
//     }

//     return total.toString();
//   }

//   Future<List<Dept>> fetchDepts(String userId) async {
//     List<Dept> depts = [];

//     try {
//       QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//           .collection("UserTransactions")
//           .doc(userId)
//           .collection("depts")
//           .get();

//       querySnapshot.docs.forEach((doc) {
//         Dept dept = Dept.fromDocumentSnapshot(doc, doc.id);
//         depts.add(dept);
//       });
//     } catch (e) {
//       print('Error fetching depts: $e');
//     }
//     setState(() {
//       for (Dept dept in depts) {
//         if (dept.type == "Credit") {
//           balance += dept.amount;
//         }
//         if (dept.type == "Debit") {
//           balance -= dept.amount;
//         }
//       }
//     });
//     return depts;
//   }

//   List<Dept> depts = [];
//   void getdepts() async {
//     depts = await fetchDepts(userId);
//   }

//   @override
//   void initState() {
//     super.initState();
//     getCurrency();
//     getdepts();
//   }

//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     final height = MediaQuery.of(context).size.height;

//     final width = MediaQuery.of(context).size.width;
//     return Scaffold(
//       key: widget.scaffoldKey,
//       extendBody: true,
//       drawer: CustomDrawer(),
//       //backgroundColor: Colors.grey[100],
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               Card(
//                   child: SizedBox(
//                 height: 50,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     IconButton(
//                         onPressed: () {
//                           widget.scaffoldKey.currentState?.openDrawer();
//                         },
//                         icon: const ImageIcon(
//                           AssetImage("assets/images/menu.png"),
//                           size: 40,
//                         )),
//                     const Text(
//                       "DEPTS",
//                       style:
//                           TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(
//                       width: 50,
//                     )
//                   ],
//                 ),
//               )).pOnly(top: 10),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     AppLocalizations.of(context)!.residualAmount,
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                   ),
//                   Text(balance.toString())
//                 ],
//               ).pSymmetric(h: 20, v: 20),
//               depts.isEmpty
//                   ? Column(
//                       children: [
//                         SizedBox(
//                           height: 200,
//                         ),
//                         Image.asset(
//                           'assets/images/icon.jpg',
//                           height: 100,
//                         ),
//                         SizedBox(
//                           height: 40,
//                         ),
//                         Center(
//                           child: Text(
//                             "  Your Debts are empty.\nWanna Create a Account?",
//                             style: TextStyle(fontSize: 19),
//                           ),
//                         ),
//                       ],
//                     )
//                   : SizedBox(
//                       height: height,
//                       width: size.width - 10,
//                       child: StreamBuilder<QuerySnapshot>(
//                         stream: FirebaseFirestore.instance
//                             .collection("UserTransactions")
//                             .doc(userId)
//                             .collection("depts")
//                             .snapshots(),
//                         builder: (context, snapshot) {
//                           if (snapshot.hasData) {
//                             List<Dept> depts = snapshot.data!.docs
//                                 .map((doc) =>
//                                     Dept.fromDocumentSnapshot(doc, doc.id))
//                                 .toList();

//                             // Display the depts on the screen
//                             return ListView.builder(
//                               itemCount: depts.length,
//                               itemBuilder: (context, index) {
//                                 Dept dept = depts[index];
//                                 return deptCard(dept, context);
//                               },
//                             );
//                           } else if (snapshot.hasError) {
//                             return Text('Error: ${snapshot.error}');
//                           } else {
//                             return CircularProgressIndicator();
//                           }
//                         },
//                       ),
//                     )
//             ],
//           ),
//         ),
//       ),
//       floatingActionButton: BlanceExpandableFloating(),
//     );
//   }

//   Column deptCard(
//     Dept dept,
//     BuildContext context,
//   ) {
//     return Column(
//       children: [
//         Stack(children: [
//           Card(
//             child: Container(
//                 decoration: BoxDecoration(
//                     // color: bgcolor,
//                     ),
//                 child: dept.type == "Credit"
//                     ? Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Image.asset("assets/images/paid.png"),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     '${dept.type}',
//                                     style: TextStyle(
//                                         fontSize: 20,
//                                         fontWeight: FontWeight.bold),
//                                   ),
//                                   Row(
//                                     children: [
//                                       Text(
//                                         AppLocalizations.of(context)!.you,
//                                         style: TextStyle(
//                                             fontSize: 20,
//                                             fontWeight: FontWeight.bold),
//                                       ),
//                                       Icon(
//                                         Icons.arrow_right_alt_sharp,
//                                         size: 35,
//                                         color: dept.type == "Credit"
//                                             ? Colors.green
//                                             : Colors.black,
//                                       ),
//                                       Text(
//                                         dept.to,
//                                         style: TextStyle(
//                                             fontSize: 20,
//                                             fontWeight: FontWeight.bold),
//                                       ),
//                                     ],
//                                   )
//                                 ],
//                               ).pOnly(left: 20),
//                             ],
//                           ).pSymmetric(v: 10),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text('${DateFormat.yMMMd().format(dept.date)}'),
//                               Text(
//                                 "%",
//                                 style: TextStyle(
//                                     fontSize: 17, fontWeight: FontWeight.bold),
//                               ),
//                               Text(
//                                   '${DateFormat.yMMMd().format(dept.backDate)}'),
//                             ],
//                           ),
//                           Container(
//                             height: 5,
//                             color: dept.type == "Credit"
//                                 ? Colors.green
//                                 : Colors.red,
//                           ).pSymmetric(v: 5),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text('0.00 Rs'),
//                               Text(
//                                 "0.00 Rs",
//                                 style: TextStyle(
//                                     fontSize: 17, fontWeight: FontWeight.bold),
//                               ),
//                               Text(
//                                   ' ${NumberFormat.currency(symbol: '$currency').format(dept.amount)}'),
//                             ],
//                           ),
//                           if (dept.type == "Debit")
//                             Row(
//                               children: [
//                                 Image.asset("assets/images/notpaid.png"),
//                                 Column(
//                                   children: [
//                                     Text(
//                                       '${dept.type}',
//                                       style: TextStyle(
//                                           fontSize: 20,
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                   ],
//                                 )
//                               ],
//                             ),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 AppLocalizations.of(context)!.residualAmount,
//                                 style: TextStyle(
//                                     fontSize: 16, fontWeight: FontWeight.bold),
//                               ),
//                               Text(
//                                   ' ${dept.status}  ${NumberFormat.currency(symbol: '$currency').format(dept.amount)}',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                   ))
//                             ],
//                           ),
//                         ],
//                       ).p(20)
//                     //debit
//                     : Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Image.asset("assets/images/notpaid.png"),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     '${dept.type}',
//                                     style: TextStyle(
//                                         fontSize: 20,
//                                         fontWeight: FontWeight.bold),
//                                   ),
//                                   Row(
//                                     children: [
//                                       Text(
//                                         dept.to,
//                                         style: TextStyle(
//                                             fontSize: 20,
//                                             fontWeight: FontWeight.bold),
//                                       ),
//                                       Icon(
//                                         Icons.arrow_right_alt_sharp,
//                                         size: 35,
//                                         color: dept.type == "Credit"
//                                             ? Colors.green
//                                             : Colors.black,
//                                       ),
//                                       Text(
//                                         AppLocalizations.of(context)!.you,
//                                         style: TextStyle(
//                                             fontSize: 20,
//                                             fontWeight: FontWeight.bold),
//                                       ),
//                                     ],
//                                   )
//                                 ],
//                               ).pOnly(left: 20)
//                             ],
//                           ).pSymmetric(v: 10),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text('${DateFormat.yMMMd().format(dept.date)}'),
//                               Text(
//                                 "%",
//                                 style: TextStyle(
//                                     fontSize: 17, fontWeight: FontWeight.bold),
//                               ),
//                               Text(
//                                   '${DateFormat.yMMMd().format(dept.backDate)}'),
//                             ],
//                           ),
//                           Container(
//                             height: 5,
//                             color: dept.type == "Credit"
//                                 ? Colors.green
//                                 : Colors.red,
//                           ).pSymmetric(v: 5),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text('0.00 Rs'),
//                               Text(
//                                 "0.00 Rs",
//                                 style: TextStyle(
//                                     fontSize: 17, fontWeight: FontWeight.bold),
//                               ),
//                               Text(
//                                   ' ${NumberFormat.currency(symbol: '$currency').format(dept.amount)}'),
//                             ],
//                           ),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 AppLocalizations.of(context)!.residualAmount,
//                                 style: TextStyle(
//                                     fontSize: 16, fontWeight: FontWeight.bold),
//                               ),
//                               Text(
//                                   ' ${dept.status}  ${NumberFormat.currency(symbol: '$currency').format(dept.amount)}',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                   ))
//                             ],
//                           ),
//                         ],
//                       ).p(20)),
//           ),
//           Positioned(
//             right: 10,
//             top: 10,
//             child: IconButton(
//               onPressed: () {
//                 deleteDept(dept);
//               },
//               icon: Icon(Icons.delete),
//             ),
//           )
//         ]),
//       ],
//     );
//   }

//   void deleteDept(Dept dept) async {
//     await FirebaseFirestore.instance
//         .collection("UserTransactions")
//         .doc(userId)
//         .collection("depts")
//         .doc(dept.id)
//         .delete();
//     setState(() {
//       depts.removeWhere((deptz) => deptz.id == dept.id);
//     });
//   }

//   void _openAddBalanceDialog(BuildContext context, String balanceType) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AddBalanceDialog(balanceType: balanceType);
//       },
//     );
//   }

//   ListTile drawerTile(String imgUrl, String title) {
//     return ListTile(
//         leading: ImageIcon(
//           AssetImage(imgUrl),
//           color: Colors.white,
//           size: 38,
//         ),
//         title: Text(
//           title,
//           style: const TextStyle(fontSize: 14, color: Colors.white),
//         ));
//   }
// }

// class ExpandableFloatingActionButton extends StatefulWidget {
//   const ExpandableFloatingActionButton({super.key});

//   @override
//   _ExpandableFloatingActionButtonState createState() =>
//       _ExpandableFloatingActionButtonState();
// }

// class _ExpandableFloatingActionButtonState
//     extends State<ExpandableFloatingActionButton>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _animation;
//   bool _isExpanded = false;

//   @override
//   void initState() {
//     super.initState();

//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );

//     _animation = Tween<double>(
//       begin: 0,
//       end: 1,
//     ).animate(_animationController);
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   void _toggleExpanded() {
//     setState(() {
//       _isExpanded = !_isExpanded;

//       if (_isExpanded) {
//         _animationController.forward();
//       } else {
//         _animationController.reverse();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.end,
//       crossAxisAlignment: CrossAxisAlignment.end,
//       children: [
//         if (_isExpanded)
//           if (_isExpanded) const SizedBox(height: 16),
//         if (_isExpanded)
//           FloatingActionButton(
//             onPressed: () {},
//             heroTag: null,
//             backgroundColor: Colors.red,
//             child: const ImageIcon(AssetImage("assets/images/minus.png")),
//           ),
//         if (_isExpanded) const SizedBox(height: 16),
//         if (_isExpanded)
//           FloatingActionButton(
//             onPressed: () {},
//             heroTag: null,
//             backgroundColor: Colors.green,
//             child: const Icon(Icons.add),
//           ),
//         const SizedBox(height: 16),
//         Padding(
//           padding: const EdgeInsets.only(bottom: 40),
//           child: SizedBox(
//               height: 60,
//               width: 60,
//               child: FittedBox(
//                   child: FloatingActionButton(
//                 backgroundColor: const Color.fromRGBO(46, 166, 193, 1),
//                 onPressed: _toggleExpanded,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(40.0),
//                 ),
//                 //  heroTag: null,
//                 child: AnimatedIcon(
//                   icon: AnimatedIcons.add_event,
//                   progress: _animation,
//                 ),
//               ))),
//         ),
//       ],
//     );
//   }
// }

// class AddBalanceDialog extends StatefulWidget {
//   final String balanceType;

//   AddBalanceDialog({required this.balanceType});

//   @override
//   _AddBalanceDialogState createState() => _AddBalanceDialogState();
// }

// class _AddBalanceDialogState extends State<AddBalanceDialog> {
//   final _formKey = GlobalKey<FormState>();
//   final String userId = FirebaseAuth.instance.currentUser!.uid;
//   TextEditingController _balanceController = TextEditingController();
//   TextEditingController _currentDateController = TextEditingController();
//   TextEditingController _dueDateController = TextEditingController();
//   TextEditingController _person = TextEditingController();

//   DateTime _currentDate = DateTime.now();
//   DateTime _dueDate = DateTime.now();

//   @override
//   void dispose() {
//     _balanceController.dispose();
//     _currentDateController.dispose();
//     _dueDateController.dispose();
//     _person.dispose();
//     super.dispose();
//   }

//   void _saveDeptData(BuildContext context) async {
//     if (_formKey.currentState!.validate()) {
//       final balanceData = BalanceData(
//           balanceType: widget.balanceType,
//           balance: double.parse(_balanceController.text),
//           currentDate: _currentDate,
//           dueDate: _dueDate,
//           person: _person.text);

//       Provider.of<BalanceProvider>(context, listen: false)
//           .addBalance(balanceData);
//       Dept dept = Dept(
//           id: DateTime.now().millisecond.toString(),
//           status: "paid",
//           type: widget.balanceType,
//           amount: double.parse(_balanceController.text),
//           date: _currentDate,
//           backDate: _dueDate,
//           to: _person.text);
//       await FirebaseFirestore.instance
//           .collection("UserTransactions")
//           .doc(userId)
//           .collection("depts")
//           .add({
//         "type": dept.type,
//         "amount": dept.amount,
//         "date": dept.date,
//         "backDate": dept.backDate,
//         "to": dept.to
//       });
//       Navigator.pop(context);
//     }
//   }

//   Future<void> _selectDate(BuildContext context,
//       TextEditingController controller, DateTime initialDate) async {
//     final DateTime? selectedDate = await showDatePicker(
//       context: context,
//       initialDate: initialDate,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );

//     if (selectedDate != null) {
//       setState(() {
//         controller.text = DateFormat.yMMMd().format(selectedDate);
//         if (controller == _currentDateController) {
//           _currentDate = selectedDate;
//         } else if (controller == _dueDateController) {
//           _dueDate = selectedDate;
//         }
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       content: SingleChildScrollView(
//         child: Form(
//           key: _formKey,
//           child: Container(
//             height: 440,
//             width: 400,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   widget.balanceType == "Debit" ? 'New Deptor' : "New Creditor",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: TextFormField(
//                         controller: _balanceController,
//                         keyboardType:
//                             TextInputType.numberWithOptions(decimal: true),
//                         decoration: InputDecoration(
//                             labelText:
//                                 "${AppLocalizations.of(context)!.balance}Amount"),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter the balance amount';
//                           }
//                           return null;
//                         },
//                       ),
//                     ),
//                     Image.asset(
//                       "assets/images/cal.png",
//                       height: 50,
//                       width: 50,
//                     ),
//                   ],
//                 ).pSymmetric(v: 10),
//                 Row(
//                   children: [
//                     Text(
//                       "Create the associated \ntransaction (Expense)",
//                       style: TextStyle(fontSize: 18),
//                     ),
//                   ],
//                 ),
//                 Column(
//                   children: [
//                     Row(
//                       children: [
//                         IconButton(onPressed: () {}, icon: Icon(Icons.wallet)),
//                         Text(
//                           "${AppLocalizations.of(context)!.wallet}:",
//                           style: TextStyle(fontSize: 20),
//                         ),
//                       ],
//                     )
//                   ],
//                 ),
//                 InkWell(
//                   onTap: () => _selectDate(
//                       context, _currentDateController, _currentDate),
//                   child: IgnorePointer(
//                     child: TextFormField(
//                       controller: _currentDateController,
//                       decoration: InputDecoration(
//                         labelText: 'Date',
//                         prefixIcon: Icon(Icons.calendar_today),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter the current date';
//                         }
//                         return null;
//                       },
//                     ),
//                   ),
//                 ),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: InkWell(
//                         onTap: () =>
//                             _selectDate(context, _dueDateController, _dueDate),
//                         child: IgnorePointer(
//                           child: TextFormField(
//                             controller: _dueDateController,
//                             decoration: InputDecoration(
//                               labelText: 'Payback Date',
//                               prefixIcon: Icon(Icons.calendar_today),
//                             ),
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please enter the due date';
//                               }
//                               return null;
//                             },
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 TextFormField(
//                   controller: _person,
//                   decoration: InputDecoration(
//                     labelText: widget.balanceType == "Debit" ? 'From' : 'To',
//                     prefixIcon: Icon(Icons.person),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter a name';
//                     }
//                     return null;
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           child: Text('Cancel'),
//         ),
//         TextButton(
//           onPressed: () => _saveDeptData(context),
//           child: Text('Save'),
//         ),
//       ],
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import '../controller/balanceProvider.dart';
import '../models/balance_data.dart';
import '../models/currency_controller.dart';
import '../models/dept.dart';
import '../utils/balance_ex.dart';
import '../utils/custom_drawer.dart';
import 'package:velocity_x/velocity_x.dart';

class BalanceScreen extends StatefulWidget {
  static const routeName = "balance-screen";
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  BalanceScreen({super.key});
  @override
  State<BalanceScreen> createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> {
  String? currency = "";
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  num balance = 0;
  List<Dept> depts = [];

  @override
  void initState() {
    super.initState();
    getCurrency();
    fetchDepts(userId).then((depts) {
      setState(() {
        this.depts = depts;
        for (Dept dept in depts) {
          if (dept.type == "Credit") {
            balance += dept.amount;
          }
          if (dept.type == "Debit") {
            balance -= dept.amount;
          }
        }
      });
    });
  }

  Future<String?> getCurrency() async {
    CurrencyData currencyData = CurrencyData();
    currency = await currencyData.fetchCurrency(userId);
    return currency;
  }

  Future<List<Dept>> fetchDepts(String userId) async {
    List<Dept> depts = [];

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("UserTransactions")
          .doc(userId)
          .collection("depts")
          .get();

      querySnapshot.docs.forEach((doc) {
        Dept dept = Dept.fromDocumentSnapshot(doc, doc.id);
        depts.add(dept);
      });
    } catch (e) {
      print('Error fetching depts: $e');
    }

    return depts;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final height = MediaQuery.of(context).size.height;

    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: widget.scaffoldKey,
      extendBody: true,
      drawer: CustomDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
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
                          widget.scaffoldKey.currentState?.openDrawer();
                        },
                        icon: const ImageIcon(
                          AssetImage("assets/images/menu.png"),
                          size: 40,
                        ),
                      ),
                      const Text(
                        "DEPTS",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        width: 50,
                      ),
                    ],
                  ),
                ),
              ).pOnly(top: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.residualAmount,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(balance.toString()),
                ],
              ).pSymmetric(h: 20, v: 20),
              depts.isEmpty
                  ? Column(
                      children: [
                        SizedBox(
                          height: 200,
                        ),
                        Image.asset(
                          'assets/images/icon.jpg',
                          height: 100,
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        Center(
                          child: Text(
                            "  Your Debts are empty.\nWanna Create a Account?",
                            style: TextStyle(fontSize: 19),
                          ),
                        ),
                      ],
                    )
                  : SizedBox(
                      height: height / 1.4,
                      width: size.width - 10,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("UserTransactions")
                            .doc(userId)
                            .collection("depts")
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            List<Dept> depts = snapshot.data!.docs
                                .map((doc) =>
                                    Dept.fromDocumentSnapshot(doc, doc.id))
                                .toList();

                            // Display the depts on the screen
                            return ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: depts.length,
                              itemBuilder: (context, index) {
                                Dept dept = depts.reversed.toList()[index];
                                return deptCard(dept, context);
                              },
                            );
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return CircularProgressIndicator();
                          }
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
      floatingActionButton: BlanceExpandableFloating(),
    );
  }

  Column deptCard(
    Dept dept,
    BuildContext context,
  ) {
    return Column(
      children: [
        Stack(
          children: [
            Card(
              child: Container(
                decoration: BoxDecoration(),
                child: dept.type == "Credit"
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Image.asset("assets/images/paid.png"),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${dept.type}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!.you,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_right_alt_sharp,
                                        size: 35,
                                        color: dept.type == "Credit"
                                            ? Colors.green
                                            : Colors.black,
                                      ),
                                      Text(
                                        dept.to,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ).pOnly(left: 20),
                            ],
                          ).pSymmetric(v: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${DateFormat.yMMMd().format(dept.date)}',
                              ),
                              Text(
                                "%",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${DateFormat.yMMMd().format(dept.backDate)}',
                              ),
                            ],
                          ),
                          Container(
                            height: 5,
                            color: dept.type == "Credit"
                                ? Colors.green
                                : Colors.red,
                          ).pSymmetric(v: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('0.00 Rs'),
                              Text(
                                "0.00 Rs",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                ' ${NumberFormat.currency(symbol: '$currency').format(dept.amount)}',
                              ),
                            ],
                          ),
                          if (dept.type == "Debit")
                            Row(
                              children: [
                                Image.asset("assets/images/notpaid.png"),
                                Column(
                                  children: [
                                    Text(
                                      '${dept.type}',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.residualAmount,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                ' ${dept.status}  ${NumberFormat.currency(symbol: '$currency').format(dept.amount)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ).p(20)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Image.asset("assets/images/notpaid.png"),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${dept.type}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        dept.to,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_right_alt_sharp,
                                        size: 35,
                                        color: dept.type == "Credit"
                                            ? Colors.green
                                            : Colors.black,
                                      ),
                                      Text(
                                        AppLocalizations.of(context)!.you,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ).pOnly(left: 20),
                            ],
                          ).pSymmetric(v: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${DateFormat.yMMMd().format(dept.date)}',
                              ),
                              Text(
                                "%",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${DateFormat.yMMMd().format(dept.backDate)}',
                              ),
                            ],
                          ),
                          Container(
                            height: 5,
                            color: dept.type == "Credit"
                                ? Colors.green
                                : Colors.red,
                          ).pSymmetric(v: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('0.00 Rs'),
                              Text(
                                "0.00 Rs",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                ' ${NumberFormat.currency(symbol: '$currency').format(dept.amount)}',
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.residualAmount,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                ' ${dept.status}  ${NumberFormat.currency(symbol: '$currency').format(dept.amount)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ).p(20),
              ),
            ),
            Positioned(
              right: 10,
              top: 10,
              child: IconButton(
                onPressed: () {
                  deleteDept(dept);
                },
                icon: Icon(Icons.delete),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void deleteDept(Dept dept) async {
    await FirebaseFirestore.instance
        .collection("UserTransactions")
        .doc(userId)
        .collection("depts")
        .doc(dept.id)
        .delete();

    setState(() {
      depts.removeWhere((deptz) => deptz.id == dept.id);
      if (dept.type == "Credit") {
        balance -= dept.amount;
      }
      if (dept.type == "Debit") {
        balance += dept.amount;
      }
    });
  }

  void _openAddBalanceDialog(BuildContext context, String balanceType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddBalanceDialog(balanceType: balanceType);
      },
    );
  }

  ListTile drawerTile(String imgUrl, String title) {
    return ListTile(
      leading: ImageIcon(
        AssetImage(imgUrl),
        color: Colors.white,
        size: 38,
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, color: Colors.white),
      ),
    );
  }
}

class ExpandableFloatingActionButton extends StatefulWidget {
  const ExpandableFloatingActionButton({super.key});

  @override
  _ExpandableFloatingActionButtonState createState() =>
      _ExpandableFloatingActionButtonState();
}

class _ExpandableFloatingActionButtonState
    extends State<ExpandableFloatingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;

      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isExpanded) ...[
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {},
            heroTag: null,
            backgroundColor: Colors.red,
            child: const ImageIcon(AssetImage("assets/images/minus.png")),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {},
            heroTag: null,
            backgroundColor: Colors.green,
            child: const Icon(Icons.add),
          ),
        ],
        SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: SizedBox(
            height: 60,
            width: 60,
            child: FittedBox(
              child: FloatingActionButton(
                backgroundColor: const Color.fromRGBO(46, 166, 193, 1),
                onPressed: _toggleExpanded,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0),
                ),
                child: AnimatedIcon(
                  icon: AnimatedIcons.add_event,
                  progress: _animation,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AddBalanceDialog extends StatefulWidget {
  final String balanceType;

  AddBalanceDialog({required this.balanceType});

  @override
  _AddBalanceDialogState createState() => _AddBalanceDialogState();
}

class _AddBalanceDialogState extends State<AddBalanceDialog> {
  final _formKey = GlobalKey<FormState>();
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  TextEditingController _balanceController = TextEditingController();
  TextEditingController _currentDateController = TextEditingController();
  TextEditingController _dueDateController = TextEditingController();
  TextEditingController _person = TextEditingController();

  DateTime _currentDate = DateTime.now();
  DateTime _dueDate = DateTime.now();

  @override
  void dispose() {
    _balanceController.dispose();
    _currentDateController.dispose();
    _dueDateController.dispose();
    _person.dispose();
    super.dispose();
  }

  void _saveDeptData(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final balanceData = BalanceData(
          balanceType: widget.balanceType,
          balance: double.parse(_balanceController.text),
          currentDate: _currentDate,
          dueDate: _dueDate,
          person: _person.text);

      Provider.of<BalanceProvider>(context, listen: false)
          .addBalance(balanceData);
      Dept dept = Dept(
          id: DateTime.now().millisecond.toString(),
          status: "paid",
          type: widget.balanceType,
          amount: double.parse(_balanceController.text),
          date: _currentDate,
          backDate: _dueDate,
          to: _person.text);
      await FirebaseFirestore.instance
          .collection("UserTransactions")
          .doc(userId)
          .collection("depts")
          .add({
        "type": dept.type,
        "amount": dept.amount,
        "date": dept.date,
        "backDate": dept.backDate,
        "to": dept.to
      });
      Navigator.pop(context);
    }
  }

  Future<void> _selectDate(BuildContext context,
      TextEditingController controller, DateTime initialDate) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        controller.text = DateFormat.yMMMd().format(selectedDate);
        if (controller == _currentDateController) {
          _currentDate = selectedDate;
        } else if (controller == _dueDateController) {
          _dueDate = selectedDate;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            height: 440,
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.balanceType == "Debit" ? 'New Deptor' : "New Creditor",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _balanceController,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                            labelText:
                                "${AppLocalizations.of(context)!.balance}Amount"),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the balance amount';
                          }
                          return null;
                        },
                      ),
                    ),
                    Image.asset(
                      "assets/images/cal.png",
                      height: 50,
                      width: 50,
                    ),
                  ],
                ).pSymmetric(v: 10),
                Row(
                  children: [
                    Text(
                      "Create the associated \ntransaction (Expense)",
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        IconButton(onPressed: () {}, icon: Icon(Icons.wallet)),
                        Text(
                          "${AppLocalizations.of(context)!.wallet}:",
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    )
                  ],
                ),
                InkWell(
                  onTap: () => _selectDate(
                      context, _currentDateController, _currentDate),
                  child: IgnorePointer(
                    child: TextFormField(
                      controller: _currentDateController,
                      decoration: InputDecoration(
                        labelText: 'Date',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the current date';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () =>
                            _selectDate(context, _dueDateController, _dueDate),
                        child: IgnorePointer(
                          child: TextFormField(
                            controller: _dueDateController,
                            decoration: InputDecoration(
                              labelText: 'Payback Date',
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the due date';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  controller: _person,
                  decoration: InputDecoration(
                    labelText: widget.balanceType == "Debit" ? 'From' : 'To',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () => _saveDeptData(context),
          child: Text('Save'),
        ),
      ],
    );
  }
}
