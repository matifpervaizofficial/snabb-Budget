import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_segmented_control/material_segmented_control.dart';
import 'package:snabbudget/utils/custom_drawer.dart';
import 'package:pie_chart/pie_chart.dart';

import '../models/transaction.dart';
import 'dashboard_screen.dart';

class SummaryScreen extends StatefulWidget {

  SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey =  GlobalKey<ScaffoldState>();
  final Map<String, double> dataMap = {
    "Expense": 3,
    "Income": 1,
  };
  int _currentSelection = 0;
    final Map<int, Widget> _children = {
  0: Text('Summary',style: GoogleFonts.montserrat(),),
  1:  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child:Text('Category',style: GoogleFonts.montserrat(),)),
  };
  List<DateTime> monthsWithTransactions = [];
    

  @override
  Widget build(BuildContext context) {
    Map<DateTime, List<Transaction>> transactionsByMonth = {};
    for (var transaction in transactions) {
      DateTime month = DateTime(transaction.date.year, transaction.date.month);
      if (transactionsByMonth.containsKey(month)) {
        transactionsByMonth[month]!.add(transaction);
      } else {
        transactionsByMonth[month] = [transaction];
      }
    }
    return Scaffold(
      key: scaffoldKey,
      drawer: CustomDrawer(scaffoldKey: scaffoldKey),
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
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 5,
           shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
      //set border radius more than 50% of height and width to make circle
  ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text("May 2023",style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(
            height: 100,
            width: 100,
            child: PieChart(
              dataMap: dataMap,
              colorList: const [Color.fromRGBO(255, 59, 59, 1), Color.fromRGBO(124, 179, 66,1)],
              legendOptions: const LegendOptions(
                showLegends: false,
              ),
              chartValuesOptions: const ChartValuesOptions(
                showChartValues: false,
              ),
              ),
                )
                    ]       
                ),
                const Column(
                  children: [
                    Text("Income ", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left,),SizedBox(width: 30,),
                    SizedBox(height: 10,),
                    Text("Expense", style: TextStyle(fontWeight: FontWeight.bold) ,textAlign: TextAlign.left),SizedBox(width: 30,),
                    SizedBox(height: 10,),
                    Text("Total      ", style: TextStyle(fontWeight: FontWeight.bold) ,textAlign: TextAlign.left),SizedBox(width: 30,),
                  ],
                ),
                const Column(
                  children: [
                    Text(" \$770", style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold),),
                    SizedBox(height: 10,),
                    Text("-\$840", style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),),
                    SizedBox(height: 10,),
                    Text(" \$770",style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                )
              ],
            ),
          ),
        ),
      ), 
      SizedBox(
      height: 200,
      child: ListView.builder(
        itemCount: 12,
        itemBuilder: (BuildContext context, int index) {
          DateTime month = DateTime(DateTime.now().year, index + 1);
          List<Transaction> transactionsForMonth = transactionsByMonth[month] ?? [];
          
          return transactionsForMonth.isNotEmpty ? Card(
            child: Column(
              children: [
                ListTile(
                  title: Text('${month.year}-${month.month}'),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: transactionsForMonth.length,
                  itemBuilder: (BuildContext context, int index) {
                    Transaction transaction = transactionsForMonth[index];
                    
                    return ListTile(
                      title: Text('Transaction ID: ${transaction.amount}'),
                      subtitle: Text('Date: ${transaction.date.toString()}'),
                    );
                  },
                ),
              ],
            ),
          ) : SizedBox.shrink();
        },
      ),
    )
          ],
        ),
      ))
    );
  }
}