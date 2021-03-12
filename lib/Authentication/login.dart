import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Admin/adminLogin.dart';
import 'package:e_shop/Widgets/customTextField.dart';
import 'package:e_shop/DialogBox/errorDialog.dart';
import 'package:e_shop/DialogBox/loadingDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Store/storehome.dart';
import 'package:e_shop/Config/config.dart';


class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}





class _LoginState extends State<Login>
{
  final TextEditingController _emailTextEditingController = TextEditingController();
  final TextEditingController _passwordTextEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FirebaseAuth _auth = FirebaseAuth.instance;

  void loginUser() async {
    showDialog(
      context: context,
      builder: (c) {
        return LoadingAlertDialog(message: "Authenticating. Please wait...",);
      }
    );
    FirebaseUser firebaseUser;

    await _auth.signInWithEmailAndPassword(
      email: _emailTextEditingController.text.trim(),
      password: _passwordTextEditingController.text.trim(),
    ).then((authUser) {
      firebaseUser = authUser.user;
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
        readData(firebaseUser).then((s) {
          Navigator.pop(context);
          Route route = MaterialPageRoute(builder: (context)=> StoreHome());
          Navigator.pushReplacement(context, route);
        });
      }
  }

  Future readData(FirebaseUser fUser) async {
    Firestore.instance.collection("users").document(fUser.uid).get().then((dataSnapshot) async {
      await EcommerceApp.sharedPreferences.setString("uid", dataSnapshot.data[EcommerceApp.userUID]);

      await EcommerceApp.sharedPreferences.setString(EcommerceApp.userEmail, dataSnapshot.data[EcommerceApp.userEmail]);

      await EcommerceApp.sharedPreferences.setString(EcommerceApp.userName, dataSnapshot.data[EcommerceApp.userName]);

      await EcommerceApp.sharedPreferences.setString(EcommerceApp.userAvatarUrl, dataSnapshot.data[EcommerceApp.userAvatarUrl]);

      List<String> cartList = dataSnapshot.data[EcommerceApp.userCartList].cast<String>();
      await EcommerceApp.sharedPreferences.setStringList(EcommerceApp.userCartList, cartList);
    });
  }

  @override
  Widget build(BuildContext context) {

    double _screenWidth = MediaQuery.of(context).size.width, _screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              alignment: Alignment.bottomCenter,
              child: Image.asset("images/login.png", height: 240.0, width: 240.0,),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Login to your Account", style: TextStyle(color: Colors.black),),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
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
                ],
              ),
            ),
            Container(
              height: 50.0,
              width: 120.0,
              child: RaisedButton(
                onPressed: () {
                  _emailTextEditingController.text.isNotEmpty && _passwordTextEditingController.text.isNotEmpty
                      ? loginUser()
                      : showDialog(
                    context: context,
                    builder: (c) {
                      return ErrorAlertDialog(message: "Please write email and password",);
                    }
                  );
                },
                color: Colors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)
                ),
                child: Text("Login", style: GoogleFonts.fredokaOne(color: Colors.white, fontSize: 17.0),),
                elevation: 5.0,
              ),
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
              height: 10.0,
            ),
            FlatButton.icon(
                onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> AdminSignInPage())),
                icon: Icon(Icons.admin_panel_settings_outlined, color: Colors.blue,),
                label: Text("Admin Login", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),)
            )
          ],
        ),
      ),
    );
  }
}
