import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:snabbudget/Screens/theme_screen.dart';
import 'package:snabbudget/utils/custom_drawer.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column hide Row;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart' as pdfWidgets;
import 'package:syncfusion_officechart/officechart.dart';

import '../models/account.dart';
import '../models/currency_controller.dart';
import '../models/transaction.dart';
import '../models/transaction_controller.dart';
import 'currency_screen.dart';
import 'export.dart';
import 'language_screen.dart';

class SettingScreen extends StatefulWidget {
  static const routeName = "settings-screen";

  SettingScreen({
    super.key,
  });

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  List<Transaction> transactions = [];
  List<Account> accounts = [];

  @override
  void initState() {
    super.initState();
    TransactionData transactionData = TransactionData();
    transactionData.fetchTransactions(userId);
    getCurrency();
    transactions = transactionData.transactions;
  }

  Future<void> showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete All Data'),
          content: const Text(
              'Are you sure you want to delete all your data? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection("UserTransactions")
                    .doc(userId)
                    .collection("transactions")
                    .get()
                    .then((snapshot) {
                  for (DocumentSnapshot ds in snapshot.docs) {
                    ds.reference.delete();
                  }
                });
                await FirebaseFirestore.instance
                    .collection("UserTransactions")
                    .doc(userId)
                    .collection("data")
                    .doc("userData")
                    .update({
                  "balance": 0,
                  "currency": "\$",
                });
                await FirebaseFirestore.instance
                    .collection("UserTransactions")
                    .doc(userId)
                    .collection("SchedualTrsanactions")
                    .get()
                    .then((snapshot) {
                  for (DocumentSnapshot ds in snapshot.docs) {
                    ds.reference.delete();
                  }
                });
                await FirebaseFirestore.instance
                    .collection("UserTransactions")
                    .doc(userId)
                    .collection("Accounts")
                    .get()
                    .then((snapshot) {
                  for (DocumentSnapshot ds in snapshot.docs) {
                    if (ds.id == "snabbWallet") {
                      FirebaseFirestore.instance
                          .collection("UserTransactions")
                          .doc(userId)
                          .collection("Accounts")
                          .doc("snabbWallet")
                          .update({'amount': 0});
                    } else {
                      ds.reference.delete();
                    }
                  }
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> createExcel(
      List<Transaction> transactions, List<Account> account) async {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];
    Style globalStyle = workbook.styles.add('style');
    globalStyle.backColor = '#37D8E9';

    // Set header "Snabb Budget"
    sheet.getRangeByName('B1').setText('Snabb Budget!');

    sheet.getRangeByName('B1').columnWidth = 25;
    sheet.getRangeByName('B1').rowHeight = 80;

    final Range rangeA1C1 = sheet.getRangeByName('A1:D1');
    rangeA1C1.cellStyle.backColor = '#87CEEB';
    final Style cellStyle = sheet.getRangeByName('B1').cellStyle;

    cellStyle.backColor = '#87CEEB';
    cellStyle.fontSize = 28;

    // Replace with your desired color
    sheet.getRangeByName('A1').cellStyle = cellStyle;
    final Range rangeA2 = sheet.getRangeByIndex(2, 1);
    rangeA2.setText('Serial Number');
    rangeA2.cellStyle
      ..backColor = '#FFFF00' // Yellow background color
      ..hAlign = HAlignType.center;
    sheet.getRangeByIndex(1, 1).columnWidth = 15; // Increase width of column 1

    final Range rangeB2 = sheet.getRangeByIndex(2, 2);
    rangeB2.setText('Date');
    rangeB2.cellStyle
      ..backColor = '#FFFF00' // Yellow background color
      ..hAlign = HAlignType.center;
    sheet.getRangeByIndex(1, 2).columnWidth = 10; // Increase width of column 2

    final Range rangeC2 = sheet.getRangeByIndex(2, 3);
    rangeC2.setText('Transaction Category');
    rangeC2.cellStyle
      ..backColor = '#FFFF00' // Yellow background color
      ..hAlign = HAlignType.center;
    sheet.getRangeByIndex(1, 3).columnWidth = 18; // Increase width of column 3

    final Range rangeD2 = sheet.getRangeByIndex(2, 4);
    rangeD2.setText('Amount');
    rangeD2.cellStyle
      ..backColor = '#FFFF00' // Yellow background color
      ..hAlign = HAlignType.center;
    sheet.getRangeByIndex(1, 4).columnWidth = 8; // Increase width of column 4

    final Range rangeE2 = sheet.getRangeByIndex(2, 5);
    rangeE2.setText('Note');
    rangeE2.cellStyle
      ..backColor = '#FFFF00' // Yellow background color
      ..hAlign = HAlignType.center;
    sheet.getRangeByIndex(1, 5).columnWidth = 7; // Increase width of column 4

    sheet.getRangeByIndex(1, 5).columnWidth = 30; // Increase width of column 5
    sheet.getRangeByIndex(2, 1).setText('Serial Number');
    sheet.getRangeByIndex(2, 2).setText('Date');
    sheet.getRangeByIndex(2, 3).setText('Transaction Category');
    sheet.getRangeByIndex(2, 4).setText('Amount');
    sheet.getRangeByIndex(2, 5).setText('Note');

    // Add transaction data
    for (int i = 0; i < transactions.length; i++) {
      final Transaction transaction = transactions[i];
      final int row = i + 3; // Starting from row 3

      // Serial Number
      sheet.getRangeByIndex(row, 1).setNumber(i + 1);

      // Date
      sheet.getRangeByIndex(row, 2).setDateTime(transaction.date);

      // Transaction Category
      sheet
          .getRangeByIndex(row, 3)
          .setText(transaction.category.toString().split('.').last);

      // Amount
      sheet.getRangeByIndex(row, 4).setNumber(transaction.amount.toDouble());

      // Note (if exists)
      if (transaction.name.isNotEmpty) {
        sheet.getRangeByIndex(row, 5).setText(transaction.name);
      }
    }
    for (int i = 0; i < account.length; i++) {
      final Account accounts = account[i];
      final int column = i + 3; // Starting from row 3

      // Serial Number
      sheet.getRangeByIndex(column, 1).setNumber(i + 1);

      // Date

      // Transaction Category
      sheet.getRangeByIndex(column, 3).setText(accounts.name.split('.').last);

      // Amount
      sheet.getRangeByIndex(column, 4).setNumber(accounts.amount.toDouble());

      // Note (if exists)
      if (accounts.name.isNotEmpty) {
        sheet.getRangeByIndex(column, 5).setText(accounts.name);
      }
    }
// Create an instance of chart collection.
    final ChartCollection charts = ChartCollection(sheet);

// Add the chart.
    final Chart chart = charts.add();

// Set Chart Type.
    chart.chartType = ExcelChartType.column3D;
// Set data range in the worksheet.
    chart.dataRange = sheet.getRangeByName('C3:D${transactions.length + 2}');

// Set chart position.
    chart.topRow = transactions.length + 5;
    chart.bottomRow = transactions.length + 25;
    chart.leftColumn = 1;
    chart.rightColumn = 8;

// Set chart title.
    chart.chartTitle = 'Income Expanse';

// Set chart title font properties.

// Set chart data labels.
    //chart.hasTitle = true;

// Set chart legend.
    chart.hasLegend = true;
    chart.legend?.position = ExcelLegendPosition.right;

// Set charts to worksheet.
    sheet.charts = charts;
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final directory = await getApplicationSupportDirectory();
    final file = File('${directory.path}/Output.xlsx');
    await file.writeAsBytes(bytes, flush: true);

    OpenFile.open(file.path);
  }

  Future<void> createExcelWithChart() async {
    // Create a new Excel document.
    final Workbook workbook = Workbook();
    // Accessing worksheet via index.
    final Worksheet sheet = workbook.worksheets[0];

    // Setting value in the cell.
    sheet.getRangeByName('A1').setText('John');
    sheet.getRangeByName('A2').setText('Amy');
    sheet.getRangeByName('A3').setText('Jack');
    sheet.getRangeByName('A4').setText('Tiya');
    sheet.getRangeByName('B1').setNumber(10);
    sheet.getRangeByName('B2').setNumber(12);
    sheet.getRangeByName('B3').setNumber(20);
    sheet.getRangeByName('B4').setNumber(21);

    // Create an instance of chart collection.
    final ChartCollection charts = ChartCollection(sheet);

    // Add the chart.
    final Chart chart = charts.add();

    // Set Chart Type.
    chart.chartType = ExcelChartType.pie3D;

    // Set data range in the worksheet.
    chart.dataRange = sheet.getRangeByName('A1:B4');

    // Set chart position.
    chart.topRow = 1;
    chart.bottomRow = 20;
    chart.leftColumn = 1;
    chart.rightColumn = 8;

    // Set chart title.
    chart.chartTitle = 'Sample Chart';

    // Set chart title font properties.

    // Set chart data labels.
    chart.hasTitle = true;

    // Set chart legend.
    chart.hasLegend = true;
    chart.legend?.position = ExcelLegendPosition.bottom;

    // Set charts to worksheet.
    sheet.charts = charts;

    // Save the workbook.
    final List<int> bytes = workbook.saveAsStream();

    // Dispose the workbook.
    workbook.dispose();

    // Get the application support directory.
    final directory = await getApplicationSupportDirectory();

    // Create the output file path.
    final filePath = '${directory.path}/Chart.xlsx';

    // Write the bytes to the output file.
    await File(filePath).writeAsBytes(bytes, flush: true);

    // Open the file.
    OpenFile.open(filePath);
  }

  // Future<void> createExcel(List<Transaction> transactions) async {
  //   final Workbook workbook = Workbook();
  //   final Worksheet sheet = workbook.worksheets[0];

  //   // Set header "Snabb Budget"
  //   sheet.getRangeByName('A1').setText('Snabb Budget!');

  //   // Set column headers
  //   sheet.getRangeByIndex(2, 1).setText('Serial Number');
  //   sheet.getRangeByIndex(2, 2).setText('Date');
  //   sheet.getRangeByIndex(2, 3).setText('Transaction Category');
  //   sheet.getRangeByIndex(2, 4).setText('Amount');
  //   sheet.getRangeByIndex(2, 5).setText('Note');

  //   // Add transaction data
  //   for (int i = 0; i < transactions.length; i++) {
  //     final Transaction transaction = transactions[i];
  //     final int row = i + 3; // Starting from row 3

  //     // Serial Number
  //     sheet.getRangeByIndex(row, 1).setNumber(i + 1);

  //     // Date
  //     sheet.getRangeByIndex(row, 2).setDateTime(transaction.date);

  //     // Transaction Category
  //     sheet
  //         .getRangeByIndex(row, 3)
  //         .setText(transaction.category.toString().split('.').last);

  //     // Amount
  //     sheet.getRangeByIndex(row, 4).setNumber(transaction.amount.toDouble());

  //     // Note (if exists)
  //     if (transaction.name.isNotEmpty) {
  //       sheet.getRangeByIndex(row, 5).setText(transaction.name);
  //     }
  //   }

  //   final List<int> bytes = workbook.saveAsStream();
  //   workbook.dispose();

  //   final String path = (await getApplicationSupportDirectory()).path;
  //   final String fileName = '$path/Output.xlsx';
  //   final File file = File(fileName);
  //   await file.writeAsBytes(bytes, flush: true);
  //   OpenFile.open(fileName);
  // }

  Future<void> generateExcel() async {
    // Create a new Excel document
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];
    Style globalStyle = workbook.styles.add('style');

    globalStyle.fontSize = 20;

    // Set column widths
    sheet.getRangeByName('A1:D1').columnWidth = 15;

    // Apply formatting to the header cells
    final Style headerStyle = workbook.styles.add('headerStyle');
    headerStyle.fontColorRgb = Colors.white;
    headerStyle.backColorRgb = Colors.black;
    headerStyle.bold = true;
    headerStyle.hAlign = HAlignType.center;
    headerStyle.vAlign = VAlignType.center;
    sheet.getRangeByName('A1:D1').cellStyle = headerStyle;

    // Set header row values
    sheet.getRangeByName('A1').setText('S. No');
    sheet.getRangeByName('B1').setText('Date');
    sheet.getRangeByName('C1').setText('Type');
    sheet.getRangeByName('D1').setText('Details');
    sheet.getRangeByName('E1').setText('Amount');

    // Set account rows
    final List<List<dynamic>> accountData = [
      [1, '300,000'],
      [2, '200,000'],
      [3, '60,000'],
      [4, '100,000'],
    ];
    for (int i = 0; i < accountData.length; i++) {
      final List<dynamic> row = accountData[i];
      sheet.getRangeByIndex(i + 2, 1).setText(row[0].toString());
      sheet.getRangeByIndex(i + 2, 5).setText(row[1].toString());
    }

    // Set total income and total expense rows
    sheet.getRangeByIndex(6, 1).setText('Total Income');
    sheet.getRangeByIndex(6, 5).setText('120,000');
    sheet.getRangeByIndex(7, 1).setText('Total Expense');
    sheet.getRangeByIndex(7, 5).setText('116,000');

    // Set transaction rows
    final List<List<dynamic>> transactionData = [
      [1, 'Income', 'Rent', '50,000'],
      [2, 'Income', 'Salary', '70,000'],
      [1, 'Expense', 'Utilities', '30,000'],
      [2, 'Expense', 'Phone Bill', '10,000'],
      [3, 'Expense', 'Water Bill', '1,000'],
      [4, 'Expense', 'Gas Bill', '20,000'],
      [5, 'Expense', 'Electricity Bill', '15,000'],
      [6, 'Expense', 'WiFi Bill', '15,000'],
      [7, 'Expense', 'Education', '5,000'],
      [8, 'Expense', 'Registration fee', '20,000'],
    ];
    for (int i = 0; i < transactionData.length; i++) {
      final List<dynamic> row = transactionData[i];
      sheet.getRangeByIndex(i + 9, 1).setText(row[0].toString());
      sheet.getRangeByIndex(i + 9, 2).setText(row[1].toString());
      sheet.getRangeByIndex(i + 9, 3).setText(row[2].toString());
      sheet.getRangeByIndex(i + 9, 5).setText(row[3].toString());
    }

    // Save the Excel document
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    // Save the Excel document to a temporary file
    final Directory tempDir = await getTemporaryDirectory();
    final String tempPath = tempDir.path;
    final String filePath = '$tempPath/excel.xlsx';
    final File file = File(filePath);
    await file.writeAsBytes(bytes);
    print('Excel file generated at: $filePath');

    // Open the Excel file
    OpenFile.open(filePath);
  }

  Future<void> createPDF(List<Transaction> transactions) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Snabb Budget',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Table.fromTextArray(
              context: context,
              data: [
                <String>[
                  'Serial Number',
                  'Date',
                  'Transaction Category',
                  'Amount',
                  'Note'
                ],
                ...transactions.map((transaction) => [
                      '${transactions.indexOf(transaction) + 1}',
                      '${transaction.date}',
                      '${transaction.category.toString().split('.').last}',
                      '${transaction.amount.toDouble()}',
                      '${transaction.name}',
                    ]),
              ],
            ),
          ];
        },
      ),
    );

    final String path = (await getApplicationSupportDirectory()).path;
    final String fileName = '$path/Output.pdf';
    final File file = File(fileName);
    await file.writeAsBytes(await pdf.save());

    OpenFile.open(fileName);
  }

  String? currency = "";
  getCurrency() async {
    CurrencyData currencyData = CurrencyData();
    String? local = await currencyData.fetchCurrency(userId);
    setState(() {
      currency = local;
    });
    //currency = currencyData.currency;
    print(currency);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SafeArea(
                child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
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
                        Text(
                          AppLocalizations.of(context)!.settings,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          width: 50,
                        )
                      ],
                    ),
                  )),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 30, top: 41, right: 30),
                    child: Column(
                      children: [
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              AppLocalizations.of(context)!.basicSettings,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Theme.of(context).primaryColor),
                            )),
                        ListTile(
                          title: Text(
                            AppLocalizations.of(context)!.language,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle:
                              Text(AppLocalizations.of(context)!.languageName),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const LanguageScreen(),
                            ));
                          },
                        ),
                        ListTile(
                          title: Text(
                            AppLocalizations.of(context)!.currency,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(currency as String),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const CurrencyScreen(),
                            ));
                          },
                        ),
                        ListTile(
                          title: const Text(
                            "Change Theme",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text("Light"),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const ThemeChangeScreen(),
                            ));
                          },
                        ),
                        ListTile(
                          title: Text(
                            AppLocalizations.of(context)!.eraseAll,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle:
                              Text(AppLocalizations.of(context)!.eraseAllData),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded),
                          onTap: () {
                            showDeleteConfirmationDialog(context);
                          },
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 30, top: 41, right: 30),
                    child: Column(
                      children: [
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              AppLocalizations.of(context)!.databaseSettings,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Theme.of(context).primaryColor),
                            )),
                        ListTile(
                          title: Text(
                            AppLocalizations.of(context)!.report,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                              AppLocalizations.of(context)!.generateReports),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded),
                          onTap: () {
                            createPDF(transactions);
                          },
                        ),
                        ListTile(
                          title: const Text(
                            "Export ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text("xls"),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded),
                          onTap: () {
                            //generateExcel();
                            createExcel(transactions, accounts);
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 30, top: 41, right: 30),
                    child: Column(
                      children: [
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              AppLocalizations.of(context)!.help,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Theme.of(context).primaryColor),
                            )),
                        ListTile(
                          title: Text(
                            AppLocalizations.of(context)!.feedback,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(AppLocalizations.of(context)!
                              .giveFeedbackSupport),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded),
                          onTap: () {},
                        ),
                        ListTile(
                          title: Text(
                            AppLocalizations.of(context)!.help,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(AppLocalizations.of(context)!.askHelp),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
