import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Admin/uploadItems.dart';
import 'package:e_shop/DialogBox/errorDialog.dart';
import 'package:e_shop/DialogBox/loadingDialog.dart';
import 'package:e_shop/Widgets/customTextField.dart';
import 'package:e_shop/Widgets/loadingWidget.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class AdminRegisterPage extends StatefulWidget {
  @override
  _AdminRegisterPageState createState() => _AdminRegisterPageState();
}

class _AdminRegisterPageState extends State<AdminRegisterPage> {

  final TextEditingController _adminIDTextEditingController = TextEditingController();
  final TextEditingController _passwordTextEditingController = TextEditingController();
  final TextEditingController _confirmPasswordTextEditingController = TextEditingController();
  final TextEditingController _nameTextEditingController = TextEditingController();
  final TextEditingController _phoneTextEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool loading = false;
  String userImageUrl = "";
  File _imageFile;

  Future<void> _selectAndPickImage() async {
    _imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
  }


  registerAdmin() {
    if(_adminIDTextEditingController.text.isNotEmpty && _nameTextEditingController.text.isNotEmpty
    && _phoneTextEditingController.text.isNotEmpty && _imageFile != null && _passwordTextEditingController.text.isNotEmpty && _confirmPasswordTextEditingController.text.isNotEmpty)
      {
        if(_confirmPasswordTextEditingController.text != _passwordTextEditingController.text)
          {
            showDialog(
                context: context,
                builder: (c) {
                  return ErrorAlertDialog(message: "Password does not match");
                }
            );
          }
        else
          {
            uploadToStorage();
          }
      }
    else
      {
        showDialog(
            context: context,
            builder: (c) {
              return ErrorAlertDialog(message: "Fill in the required fields",);
            }
        );
      }
  }

  uploadToStorage() async {
    showDialog(
        context: context,
        builder: (c) {
          return LoadingAlertDialog(message: 'Registering, Please wait...',);
        }
    );

    String imageFileName = DateTime.now().millisecondsSinceEpoch.toString();

    StorageReference storageReference = FirebaseStorage.instance.ref().child(imageFileName);

    StorageUploadTask storageUploadTask = storageReference.putFile(_imageFile);

    StorageTaskSnapshot taskSnapshot = await storageUploadTask.onComplete;

    await taskSnapshot.ref.getDownloadURL().then((url) {
      userImageUrl = url;

      saveToFirestore();
    });
  }

  saveToFirestore() async {
    await Firestore.instance.collection("admins").document(_adminIDTextEditingController.text.trim()).setData(
        {
          "name": _nameTextEditingController.text.trim(),
          "id": _adminIDTextEditingController.text.trim(),
          "phone": _phoneTextEditingController.text.trim(),
          "password": _passwordTextEditingController.text.trim(),
          "url": userImageUrl,
        }).then((value) {
      Fluttertoast.showToast(msg: "Registration Successful");
    });

    Route route = MaterialPageRoute(builder: (context)=> UploadPage(
      name: _nameTextEditingController.text.trim(),
      phone: _phoneTextEditingController.text.trim(),
      userID: _adminIDTextEditingController.text.trim(),
    ));
    Navigator.pushReplacement(context, route);
  }

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width, _screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.blue[900], Colors.lightBlue],
                  begin: FractionalOffset(0.0, 0.0),
                  end: FractionalOffset(1.0, 0.0),
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp
              )
          ),
        ),
        title: Text(
          "Admin Registration",
          style: GoogleFonts.fredokaOne(
              color: Colors.white,
              fontSize: 30.0,
              //fontFamily: "Signatra"
          ),
        ),
        centerTitle: true,
      ),
      body: loading ? circularProgress() : SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(height: 10.0,),
              InkWell(
                onTap: _selectAndPickImage,
                child: CircleAvatar(
                  radius: _screenWidth * 0.15,
                  backgroundColor: Colors.white,
                  backgroundImage: _imageFile == null ? null : FileImage(_imageFile),
                  child: _imageFile == null
                      ? Container(
                    height: _screenWidth * 0.3,
                    width: _screenWidth * 0.3,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(_screenWidth * 0.15),
                        image: DecorationImage(
                            image: AssetImage("images/profile.png"),
                            fit: BoxFit.cover
                        )
                    ),
                  ) : null,
                ),
              ),
              SizedBox(height: 8.0,),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _nameTextEditingController,
                      data: Icons.person,
                      hintText: "First Name",
                      isObscure: false,
                    ),
                    CustomTextField(
                      controller: _phoneTextEditingController,
                      data: Icons.phone_android,
                      hintText: "Phone Number",
                      isObscure: false,
                    ),
                    CustomTextField(
                      controller: _adminIDTextEditingController,
                      data: Icons.person,
                      hintText: "National ID",
                      isObscure: false,
                    ),
                    CustomTextField(
                      controller: _passwordTextEditingController,
                      data: Icons.lock_outlined,
                      hintText: "Password",
                      isObscure: true,
                    ),
                    CustomTextField(
                      controller: _confirmPasswordTextEditingController,
                      data: Icons.lock_outlined,
                      hintText: "Confirm Password",
                      isObscure: true,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              RaisedButton(
                onPressed: () {
                  registerAdmin();
                },
                color: Colors.blue,
                child: Text("Register", style: TextStyle(color: Colors.white),),
              ),
              SizedBox(
                height: 50.0,
              ),
              Container(
                height: 4.0,
                width: _screenWidth * 0.8,
                color: Colors.blue,
              ),
              SizedBox(
                height: 20.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
