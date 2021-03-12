import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Admin/adminRegister.dart';
import 'package:e_shop/Widgets/customTextField.dart';
import 'package:e_shop/DialogBox/errorDialog.dart';
import 'package:e_shop/DialogBox/loadingDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../Store/storehome.dart';
import 'package:e_shop/Config/config.dart';



class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}



class _RegisterState extends State<Register>
{
  final TextEditingController _nameTextEditingController = TextEditingController();
  final TextEditingController _emailTextEditingController = TextEditingController();
  final TextEditingController _passwordTextEditingController = TextEditingController();
  final TextEditingController _cPasswordTextEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String userImageUrl = "";
  File _imageFile;
  
  Future<void> _selectAndPickImage() async {
    _imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
  }

  Future<void> uploadAndSaveImage() async {
    if(_imageFile == null)
      {
        showDialog(
            context: context,
          builder: (c) {
              return ErrorAlertDialog(message: "Please select an image",);
          }
        );
      }
    else
      {
        _passwordTextEditingController.text
            == _cPasswordTextEditingController.text
            ? _emailTextEditingController.text.isNotEmpty
            && _passwordTextEditingController.text.isNotEmpty
            && _cPasswordTextEditingController.text.isNotEmpty
            && _nameTextEditingController.text.isNotEmpty

            ? uploadToStorage()
            : displayDialog("Write the required registration form")
            : displayDialog("Password does not match");
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

      _registerUser();
    });
  }

  FirebaseAuth _auth = FirebaseAuth.instance;
  void _registerUser() async{
    FirebaseUser firebaseUser;

    await _auth.createUserWithEmailAndPassword(
      email: _emailTextEditingController.text.trim(),
      password: _passwordTextEditingController.text.trim(),
    ).then((auth) {
      firebaseUser = auth.user;
    }).catchError((error) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (c) {
          return ErrorAlertDialog(message: error.message.toString(),);
        }
      );
    });

    if(firebaseUser != null)
      {
        saveUserToFireStore(firebaseUser).then((value) {
          Navigator.pop(context);
          Route route = MaterialPageRoute(builder: (context) => StoreHome());
          Navigator.pushReplacement(context, route);
        });
      }
  }

  Future saveUserToFireStore(FirebaseUser fUser) async {
    Firestore.instance.collection("users").document(fUser.uid).setData({
      "uid": fUser.uid,
      "email": fUser.email,
      "name": _nameTextEditingController.text.trim(),
      "url": userImageUrl,
      EcommerceApp.userCartList: ["garbageValue"]
    });

    await EcommerceApp.sharedPreferences.setString("uid", fUser.uid);
    await EcommerceApp.sharedPreferences.setString(EcommerceApp.userEmail, fUser.email);
    await EcommerceApp.sharedPreferences.setString(EcommerceApp.userName, _nameTextEditingController.text);
    await EcommerceApp.sharedPreferences.setString(EcommerceApp.userAvatarUrl, userImageUrl);
    await EcommerceApp.sharedPreferences.setStringList(EcommerceApp.userCartList, ["garbageValue"]);
  }

  displayDialog(String msg)
  {
    showDialog(
      context: context,
      builder: (c) {
        return ErrorAlertDialog(message: msg,);
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width, _screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
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
                    hintText: "Name",
                    isObscure: false,
                  ),
                  CustomTextField(
                    controller: _emailTextEditingController,
                    data: Icons.email,
                    hintText: "Email",
                    isObscure: false,
                  ),
                  CustomTextField(
                    controller: _passwordTextEditingController,
                    data: Icons.lock_outlined,
                    hintText: "Password",
                    isObscure: true,
                  ),
                  CustomTextField(
                    controller: _cPasswordTextEditingController,
                    data: Icons.lock_outline,
                    hintText: "Confirm Password",
                    isObscure: true,
                  ),
                ],
              ),
            ),
            Container(
              height: 50.0,
              width: 120.0,
              child: RaisedButton(
                onPressed: () { uploadAndSaveImage(); },
                color: Colors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)
                ),
                child: Text("Register", style: GoogleFonts.fredokaOne(color: Colors.white, fontSize: 17.0),),
                elevation: 5.0,
              ),
            ),
            SizedBox(
              height: 30.0,
            ),
            Container(
              height: 4.0,
              width: _screenWidth * 0.8,
              color: Colors.blue,
            ),
            SizedBox(
              height: 15.0,
            ),
            Text("Want to sell your own products?"),
            SizedBox(height: 5.0,),
            FlatButton.icon(
                onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> AdminRegisterPage())),
                icon: Icon(Icons.admin_panel_settings_outlined, color: Colors.blue,),
                label: Text("Register as Admin", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),)
            )
          ],
        ),
      ),
    );
  }
}

