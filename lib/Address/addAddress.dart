import 'package:e_shop/Config/config.dart';
import 'package:e_shop/Store/storehome.dart';
import 'package:e_shop/Widgets/customAppBar.dart';
import 'package:e_shop/Models/address.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddAddress extends StatelessWidget {

  final formKey = GlobalKey<FormState>();
  final cName = TextEditingController();
  final cPhoneNumber = TextEditingController();
  final cFlatHomeNumber = TextEditingController();
  final cCity = TextEditingController();
  final cState = TextEditingController();
  final cPinCode = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              if(formKey.currentState.validate())
                {
                  final model = AddressModel(
                    name: cName.text.trim(),
                    state: cState.text.trim(),
                    pincode: cPinCode.text,
                    phoneNumber: cPhoneNumber.text,
                    flatNumber: cFlatHomeNumber.text,
                    city: cCity.text.trim(),
                  ).toJson();

                  //Add to Firestore
                  EcommerceApp.firestore.collection(EcommerceApp.collectionUser)
                      .document(EcommerceApp.sharedPreferences.getString(EcommerceApp.userUID))
                      .collection(EcommerceApp.subCollectionAddress)
                      .document(DateTime.now().millisecondsSinceEpoch.toString())
                      .setData(model).then((value) {
                        Fluttertoast.showToast(
                          msg: "New Address added successfully"
                        );

                        FocusScope.of(context).requestFocus(FocusNode());
                        formKey.currentState.reset();

                        Route route = MaterialPageRoute(builder: (context)=> StoreHome());
                        Navigator.pushReplacement(context, route);
                  });
                }
            },
            label: Text("Done"),
          backgroundColor: Colors.blue,
          icon: Icon(Icons.check),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Add New Address",
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20.0),
                  ),
                ),
              ),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    MyTextField(
                      hint: "Name",
                      controller: cName,
                    ),
                    MyTextField(
                      hint: "Phone Number",
                      controller: cPhoneNumber,
                    ),
                    MyTextField(
                      hint: "Flat Number / House Number",
                      controller: cFlatHomeNumber,
                    ),
                    MyTextField(
                      hint: "City",
                      controller: cCity,
                    ),
                    MyTextField(
                      hint: "State / Country",
                      controller: cState,
                    ),
                    MyTextField(
                      hint: "Pin Code",
                      controller: cPinCode,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MyTextField extends StatelessWidget {

  final String hint;
  final TextEditingController controller;

  MyTextField({Key key, this.hint, this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration.collapsed(
          hintText: hint,
        ),
        validator: (val)=> val.isEmpty ? "Required" : null,
      ),
    );
  }
}
