// ignore_for_file: unused_local_variable, prefer_const_constructors, depend_on_referenced_packages, use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:snabbudget/Screens/schedule_transactions.dart';
import 'package:velocity_x/velocity_x.dart';
import '../models/currency_controller.dart';
import '../models/expanseDataModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction.dart';
import 'home_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddExpanse extends StatefulWidget {
  static const routeName = "add-expense";
  final num balance;
  final num snabWallet;
  const AddExpanse(
      {super.key, required this.balance, required this.snabWallet});

  @override
  State<AddExpanse> createState() => _AddExpanseState();
}

class _AddExpanseState extends State<AddExpanse> {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String pathFile = "";
  TimeOfDay _selectedTime = TimeOfDay.now();
  String formatTime = "${TimeOfDay.now().hour}:${TimeOfDay.now().minute}";
  bool isLoading = false;
  final storage = FirebaseStorage.instance;
  bool schedual = false;
  String? currency = "";
  XFile? pickImage;
  num snabWalletBalance = 0;
  TransactionCat? selectedCategory;
  List<ExpanseData> incomeDatList = [];
  int check = 0;
  final picker = ImagePicker();
  getCurrency() async {
    CurrencyData currencyData = CurrencyData();
    String? currencyThis = await currencyData.fetchCurrency(userId);
    //currency = currencyData.currency;
    //print(currency);
    setState(() {
      currency = currencyThis;
      print(currency);
    });
  }

  Future<void> selectImage(BuildContext context) async {
    final PermissionStatus status = await Permission.photos.request();
    if (status.isGranted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Select Image'),
            content: Text(
                'Do you want to select an image from the gallery or take a picture?'),
            actions: <Widget>[
              TextButton(
                child: Text('Gallery'),
                onPressed: () async {
                  //Navigator.of(context).pop();
                  //getImage(ImgSource.Gallery);
                  pickImage = await picker.pickImage(
                      source: ImageSource.gallery, imageQuality: 1);

                  // Handle the picked image
                  if (pickImage != null) {
                    _uploadPicture(pickImage as XFile);
                    // Do something with the picked image
                    // For example, you can display it in an Image widget
                  }
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Camera'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  pickImage = await picker.pickImage(
                      source: ImageSource.camera, imageQuality: 1);
                  // Handle the picked image
                  if (pickImage != null) {
                    _uploadPicture(pickImage as XFile);
                    // Do something with the picked image
                    // For example, you can display it in an Image widget
                  }
                },
              ),
            ],
          );
        },
      );
    } else {
      // Handle the case where the user denied permission
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Permission Denied'),
            content: Text('Please grant permission to access photos.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () async {
                  await Permission.photos.request();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void getInfo() async {
    var docSnapshot3 = await FirebaseFirestore.instance
        .collection('UserTransactions')
        .doc(userId)
        .collection("Accounts")
        .doc("snabbWallet")
        .get();
    if (docSnapshot3.exists) {
      Map<String, dynamic>? data = docSnapshot3.data();
      setState(() {
        snabWalletBalance = data!["amount"];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getInfo();
    getCurrency();
  }

  Future<void> _uploadPicture(XFile img) async {
    // final picker = ImagePicker();
    // var pickImage = await picker.pickImage(source: ImageSource.camera);
    var pathPickImage = img.path;

    setState(() {
      pathFile = img.path;
    });

    final File file = File(img.path);
    final String fileName = '${DateTime.now()}.jpg';
    final Reference storageRef = storage.ref().child(fileName);
    final UploadTask uploadTask = storageRef.putFile(file);

    await uploadTask.whenComplete(() async {
      final imageUrl = await storageRef.getDownloadURL();

      setState(() {
        pathPickImage = imageUrl;
      });
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      _selectedDate = pickedDate;
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (pickedTime != null) {
      _selectedTime = pickedTime;
      formatTime = "${_selectedTime.hour}:${_selectedTime.minute}";
    }
  }

//function for storing data and passing to another screen
  void _saveExpense() async {
    if (_formKey.currentState!.validate() && selectedCategory != null) {
      setState(() {
        isLoading = true;
      });

      double amount = double.parse(_amountController.text);
      String name = _nameController.text.isNotEmpty
          ? _nameController.text
          : selectedCategory!
              .name.capitalized; // Use category name if name is not provided

      String imageUrl = "";
      if (pathFile.isNotEmpty) {
        Reference storageReference =
            FirebaseStorage.instance.ref().child('images');
        TaskSnapshot taskSnapshot =
            await storageReference.putFile(File(pathFile));
        imageUrl = await taskSnapshot.ref.getDownloadURL();
      }
      // Save data to Firestore
      await FirebaseFirestore.instance
          .collection("UserTransactions")
          .doc(userId)
          .collection("transactions")
          .add({
        "name": name,
        "amount": double.parse(_amountController.text),
        "category": selectedCategory.toString(),
        "type": "TransactionType.expense",
        "date": _selectedDate,
        "time": formatTime,
        "imgUrl": getImgUrlForCategory(selectedCategory as TransactionCat),
        "fileUrl": imageUrl,
        "notes": _noteController.text // Use the obtained image URL
      });
      num updatedSnabBalance = snabWalletBalance - amount;
      // Update user's balance
      await FirebaseFirestore.instance
          .collection("UserTransactions")
          .doc(userId)
          .collection("data")
          .doc("userData")
          .update({"balance": widget.balance - amount});
      await FirebaseFirestore.instance
          .collection("UserTransactions")
          .doc(userId)
          .collection("Accounts")
          .doc("snabbWallet")
          .update({'amount': updatedSnabBalance});

      setState(() {
        _nameController.clear();
        _amountController.clear();
        isLoading = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      );
    }
  }

  void schedualeTransaction() async {
    if (_formKey.currentState!.validate() && selectedCategory != null) {
      double amount = double.parse(_amountController.text);
      String name = _nameController.text;
      String imageUrl = "";
      if (pathFile.isNotEmpty) {
        Reference storageReference =
            FirebaseStorage.instance.ref().child('images');
        TaskSnapshot taskSnapshot =
            await storageReference.putFile(File(pathFile));
        imageUrl = await taskSnapshot.ref.getDownloadURL();
      }
      await FirebaseFirestore.instance
          .collection("UserTransactions")
          .doc(userId)
          .collection("SchedualTrsanactions")
          .add({
        "name": name,
        "amount": int.parse(_amountController.text),
        "category": selectedCategory.toString(),
        "type": "TransactionType.expense",
        "date": _selectedDate,
        "time": formatTime,
        "fileUrl": imageUrl,
        "imgUrl": getImgUrlForCategory(selectedCategory as TransactionCat),
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScheduleTransactions(),
        ),
      );
    }
    setState(() {
      schedual = false;
    });
  }

  final List<File> _selectedFiles = [];

  // Future<void> _pickFiles() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles();

  //   if (result != null && result.files.isNotEmpty) {
  //     List<File> pickedFiles = result.paths.map((path) => File(path!)).toList();
  //     setState(() {
  //       _selectedFiles.addAll(pickedFiles);
  //     });
  //   }
  // }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  Future<bool> _onWillPop() async {
    if (isLoading) {
      return false;
    } else {
      return true;
    }
  }

  final Map<TransactionCat, String> categoryImgUrls = {
    TransactionCat.travelling: 'assets/images/travel.png',
    TransactionCat.shopping: 'assets/images/shopping.png',
    TransactionCat.transport: 'assets/images/transportation.png',
    TransactionCat.home: 'assets/images/home.png',
    TransactionCat.health: 'assets/images/health.png',
    TransactionCat.family: 'assets/images/family.png',
    TransactionCat.foodDrink: 'assets/images/fooddrink.png',
    TransactionCat.others: 'assets/images/others.png',
    TransactionCat.pets: 'assets/images/pet.png',
    //TransactionCat.cash: 'assets/images/income.png',
  };
  String getImgUrlForCategory(TransactionCat category) {
    return categoryImgUrls[category] ?? 'assets/images/others.png';
  }

  @override
  Widget build(BuildContext context) {
    if (check == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) => getInfo());
      check++;
    }
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 100,
          elevation: 0,
          title: Text(AppLocalizations.of(context)!.addExpense,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17)),
          centerTitle: true,
          leading: CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.white,
                  child: InkWell(
                      onTap: () {
                        if (!isLoading) {
                          Navigator.pop(context);
                        }
                      },
                      child: Icon(Icons.arrow_back_rounded)))
              .p(10),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
                  Color.fromRGBO(231, 147, 86, 1),
                  Color.fromRGBO(250, 129, 51, 1),
                  Color.fromRGBO(241, 96, 9, 1),
                ]),
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(18),
                    bottomLeft: Radius.circular(18))),
          ),
        ),
        body: SingleChildScrollView(
          child: SafeArea(
            child: SizedBox(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // ElevatedButton(onPressed: (){
                    //   print(snabWalletBalance);
                    // }, child: Text("test")),
                    SizedBox(
                      height: 50,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${AppLocalizations.of(context)!.expenseName} optional",
                          style:
                              TextStyle(fontSize: 16, color: Color(0xff2EA6C1)),
                        ),
                        SizedBox(
                          height: height / 80,
                        ),
                        TextFormField(
                          controller: _nameController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            errorStyle: TextStyle(color: Colors.black),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 20),
                            fillColor: Colors.black.withOpacity(0.2),
                            hintText: AppLocalizations.of(context)!.addExpense,
                            alignLabelWithHint: true,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: height / 80,
                        ),
                        Text(
                          AppLocalizations.of(context)!.amount,
                          style:
                              TextStyle(fontSize: 16, color: Color(0xff2EA6C1)),
                        ),
                        SizedBox(
                          height: height / 80,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter a valid amount';
                                  }
                                  if (value.isEmpty) {
                                    return 'Password must be at least 1 digit long';
                                  }
                                  return null;
                                },
                                controller: _amountController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  errorStyle: TextStyle(color: Colors.black),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 20),
                                  fillColor: Colors.black.withOpacity(0.2),
                                  hintText: "0.0 ",
                                  alignLabelWithHint: true,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                currency.toString(),
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: height / 80,
                        ),
                        Text(
                          AppLocalizations.of(context)!.category,
                          style:
                              TextStyle(fontSize: 16, color: Color(0xff2EA6C1)),
                        ),
                        SizedBox(
                          height: height / 80,
                        ),
                        SizedBox(
                          width: width / 1.3,
                          child: DropdownButtonFormField<TransactionCat>(
                            value: selectedCategory,
                            hint: Text(AppLocalizations.of(context)!.category),
                            onChanged: (TransactionCat? newValue) {
                              setState(() {
                                selectedCategory = newValue;
                              });
                            },
                            items: categoryImgUrls.keys
                                .map((TransactionCat category) {
                              return DropdownMenuItem<TransactionCat>(
                                value: category,
                                child: Row(
                                  children: [
                                    Image.asset(
                                      categoryImgUrls[category]!,
                                      width: 50,
                                      height: 50,
                                    ),
                                    SizedBox(width: 10),
                                    Text(category
                                        .toString()
                                        .split('.')
                                        .last
                                        .capitalized),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(
                          height: height / 30,
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: () => _selectDate(context),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.calendar_today),
                                  SizedBox(width: 15),
                                  Text(
                                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                    style: TextStyle(
                                        fontSize: 20, color: Color(0xff2EA6C1)),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: width / 3.3),
                            InkWell(
                              onTap: () => _selectTime(context),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.access_time),
                                  SizedBox(width: 15),
                                  Text(
                                    '${_selectedTime.hour}:${_selectedTime.minute}',
                                    style: TextStyle(
                                        fontSize: 20, color: Color(0xff2EA6C1)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: height / 30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.note_alt_outlined,
                              size: 35,
                            ).pOnly(right: 10),
                            Expanded(
                              child: TextFormField(
                                maxLines: 4,
                                controller: _noteController,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  errorStyle: TextStyle(color: Colors.black),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
                                  fillColor: Colors.black.withOpacity(0.2),
                                  hintText: "notes",
                                  alignLabelWithHint: true,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: height / 30,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.file_present_outlined,
                              size: 30,
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  //_takePicture();
                                  selectImage(context);
                                },
                                child: Text(
                                    AppLocalizations.of(context)!.addFile)),
                            SizedBox(width: 5),
                            SizedBox(
                                width: 200,
                                child: Text(
                                  pickImage != null ? pickImage!.name : "",
                                  softWrap: true,
                                )),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            !schedual
                                ? InkWell(
                                    onTap: () {
                                      setState(() {
                                        schedual = true;
                                      });
                                      schedualeTransaction();
                                    },
                                    child: Text(
                                      AppLocalizations.of(context)!.schedule,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xff2EA6C1)),
                                    ),
                                  )
                                : CircularProgressIndicator(),
                          ],
                        )
                      ],
                    ).pSymmetric(h: 20),
                    SizedBox(
                      height: height / 20,
                    ),
                    !isLoading
                        ? Center(
                            child: SizedBox(
                              width: width / 2,
                              child: ElevatedButton(
                                onPressed: () {
                                  _saveExpense();
                                },
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(50))),
                                child: Text(AppLocalizations.of(context)!.add),
                              ),
                            ),
                          )
                        : CircularProgressIndicator()
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DropdownItem {
  final String name;
  final String imagePath;

  DropdownItem(this.name, this.imagePath);
}
