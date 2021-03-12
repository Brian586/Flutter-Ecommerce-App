import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Admin/adminShiftOrders.dart';
import 'package:e_shop/DialogBox/errorDialog.dart';
import 'package:e_shop/Models/dropDown.dart';
import 'package:e_shop/Widgets/loadingWidget.dart';
import 'package:e_shop/main.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as ImD;


class UploadPage extends StatefulWidget
{

  final String name;
  final String phone;
  final String userID;

  UploadPage({this.name, this.phone, this.userID});

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> with AutomaticKeepAliveClientMixin<UploadPage>
{
  bool get wantKeepAlive => true;
  File file;
  TextEditingController _descriptionTextEditingController = TextEditingController();
  TextEditingController _priceTextEditingController = TextEditingController();
  TextEditingController _oldPriceTextEditingController = TextEditingController();
  TextEditingController _titleTextEditingController = TextEditingController();
  TextEditingController _shortInfoTextEditingController = TextEditingController();
  TextEditingController _categoryTextEditingController = TextEditingController();
  TextEditingController _conditionTextEditingController = TextEditingController();
  String productId = DateTime.now().millisecondsSinceEpoch.toString();
  bool uploading = false;
  String city;
  String country;


  @override
  void initState() {
    super.initState();

    _determinePosition();
  }

  _determinePosition() async {

    setState(() {
      uploading = true;
    });

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.deniedForever) {

        setState(() {
          uploading = false;
        });

        return Future.error(
            'Location permissions are permantly denied, we cannot request permissions.');
      }
      else if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {

          setState(() {
            uploading = false;
          });

          return Future.error(
              'Location permissions are denied (actual value: $permission).');
        }
      }
      else
      {
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

        List<Placemark> placeMarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        Placemark mPlaceMark = placeMarks[0];
        String completeAddressInfo = '${mPlaceMark.subThoroughfare} ${mPlaceMark.thoroughfare}, '
            '${mPlaceMark.subLocality} ${mPlaceMark.locality}, '
            '${mPlaceMark.subAdministrativeArea} ${mPlaceMark.administrativeArea}, '
            '${mPlaceMark.postalCode} ${mPlaceMark.country}';
        String specificAddress = '${mPlaceMark.locality}, ${mPlaceMark.country}';
        String cityAddress = '${mPlaceMark.locality}';
        String countryAddress = '${mPlaceMark.country}';

        print(specificAddress);
        setState(() {
          uploading = false;
          city = cityAddress;
          country = countryAddress;
        });
      }

      //return Future.error('Location services are disabled.');
    }
    else
    {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      List<Placemark> placeMarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark mPlaceMark = placeMarks[0];
      String completeAddressInfo = '${mPlaceMark.subThoroughfare} ${mPlaceMark.thoroughfare}, '
          '${mPlaceMark.subLocality} ${mPlaceMark.locality}, '
          '${mPlaceMark.subAdministrativeArea} ${mPlaceMark.administrativeArea}, '
          '${mPlaceMark.postalCode} ${mPlaceMark.country}';
      String specificAddress = '${mPlaceMark.locality}, ${mPlaceMark.country}';
      String cityAddress = '${mPlaceMark.locality}';
      String countryAddress = '${mPlaceMark.country}';

      print(specificAddress);
      setState(() {
        uploading = false;
        city = cityAddress;
        country = countryAddress;
      });
    }
  }


  displayAdminHomeScreen() {
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
        leading: IconButton(
          icon: Icon(Icons.border_color, color: Colors.white,),
          onPressed: () {
            Route route = MaterialPageRoute(builder: (context)=> AdminShiftOrders());
            Navigator.pushReplacement(context, route);
          },
        ),
        actions: [
          FlatButton(
            child: Text("Logout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.0),),
            onPressed: () {
              Route route = MaterialPageRoute(builder: (context)=> SplashScreen());
              Navigator.pushReplacement(context, route);
            },
          )
        ],
      ),
      body: getAdminHomeScreenBody(),
    );
  }

  getAdminHomeScreenBody() {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shop_two, color: Colors.grey[400], size: 150.0,),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: RaisedButton(
                color: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9.0)),
                child: Text(
                  "Add Items",
                  style: TextStyle(fontSize: 20.0, color: Colors.white),
                ),
                onPressed: ()=> takeImage(context),
              ),
            )
          ],
        ),
      ),
    );
  }

  takeImage(mContext) {
    return showDialog(
      context: mContext,
      builder: (c) {
        return SimpleDialog(
          title: Text("Item Image", textAlign: TextAlign.center, style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),),
          children: [
            SimpleDialogOption(
              child: Text("Capture with Camera", style: TextStyle(color: Colors.black),),
              onPressed: capturePhotoWithCamera,
            ),
            SimpleDialogOption(
              child: Text("Select from Gallery", style: TextStyle(color: Colors.black),),
              onPressed: pickPhotoFromGallery,
            ),
            SimpleDialogOption(
              child: Text("Cancel", style: TextStyle(color: Colors.black),),
              onPressed: () {Navigator.pop(context);},
            )
          ],
        );
      }
    );
  }

  pickPhotoFromGallery() async {
    Navigator.pop(context);

    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      file = imageFile;
    });
  }

  capturePhotoWithCamera() async {
    Navigator.pop(context);

    File imageFile = await ImagePicker.pickImage(source: ImageSource.camera, maxHeight: 680.0, maxWidth: 970.0);

    setState(() {
      file = imageFile;
    });
  }

  void typeAction(String choice) {
    if(choice == Type.mnew)
      {
        setState(() {
          _conditionTextEditingController.text = "New";
        });
      }
    else if(choice == Type.refurb)
      {
        setState(() {
          _conditionTextEditingController.text = "Refurbished";
        });
      }
  }

  void categoryAction(String choice) {
    if(choice == CategoryType.electronic)
      {
        setState(() {
          _categoryTextEditingController.text = "Electronic Appliances";
        });
      }
    else if(choice == CategoryType.kitchenWare)
    {
      setState(() {
        _categoryTextEditingController.text = "Kitchen Ware";
      });
    }
    else if(choice == CategoryType.phones)
    {
      setState(() {
        _categoryTextEditingController.text = "Phones";
      });
    }
    else if(choice == CategoryType.shoes)
    {
      setState(() {
        _categoryTextEditingController.text = "Shoes";
      });
    }
    else if(choice == CategoryType.food)
    {
      setState(() {
        _categoryTextEditingController.text = "Food";
      });
    }
    else if(choice == CategoryType.clothes)
    {
      setState(() {
        _categoryTextEditingController.text = "Clothes";
      });
    }
  }

  displayUploadFormScreen() {
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white,),
          onPressed: clearFormInfo,
        ),
        title: Text("New Product", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24.0),),
        centerTitle: true,
        actions: [
          FlatButton(
            child: Text("Add", style: TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold),),
            onPressed: uploading ? null : () => uploadImageAndSaveItemInfo()
          )
        ],
      ),
      body: uploading ? circularProgress() : ListView(
        physics: BouncingScrollPhysics(),
        children: [
          Container(
            height: 300.0,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16/9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(file),
                      fit: BoxFit.contain
                    )
                  ),
                ),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 12.0)),

          ListTile(
            leading: Icon(Icons.perm_device_info, color: Colors.grey[400],),
            title: Container(
              width: 250.0,
              child: TextField(
                cursorColor: Colors.blue,
                style: TextStyle(color: Colors.black),
                controller: _shortInfoTextEditingController,
                decoration: InputDecoration(
                  hintText: "Short Info",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          SizedBox(height: 20.0,),

          ListTile(
            leading: Icon(Icons.perm_device_info, color: Colors.grey[400],),
            title: Container(
              width: 250.0,
              child: TextField(
                cursorColor: Colors.blue,
                style: TextStyle(color: Colors.black),
                controller: _titleTextEditingController,
                decoration: InputDecoration(
                  hintText: "Title",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          SizedBox(height: 20.0,),

          ListTile(
            leading: Icon(Icons.edit, color: Colors.grey[400],),
            title: Container(
              width: 250.0,
              child: TextField(
                cursorColor: Colors.blue,
                maxLines: null,
                style: TextStyle(color: Colors.black),
                controller: _descriptionTextEditingController,
                decoration: InputDecoration(
                  hintText: "Description",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          SizedBox(height: 20.0,),

          ListTile(
            leading: Icon(Icons.money_off, color: Colors.grey[400],),
            title: Container(
              width: 250.0,
              child: TextField(
                cursorColor: Colors.blue,
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.black),
                controller: _oldPriceTextEditingController,
                decoration: InputDecoration(
                  hintText: "Old Price",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          SizedBox(height: 20.0,),

          ListTile(
            leading: Icon(Icons.attach_money_rounded, color: Colors.grey[400],),
            title: Container(
              width: 250.0,
              child: TextField(
                cursorColor: Colors.blue,
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.black),
                controller: _priceTextEditingController,
                decoration: InputDecoration(
                  hintText: "Price",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          SizedBox(height: 20.0,),

          ListTile(
            leading: Icon(Icons.new_releases_outlined, color: Colors.grey[400],),
            title: Container(
              width: 250.0,
              child: TextField(
                cursorColor: Colors.blue,
                keyboardType: TextInputType.text,
                style: TextStyle(color: Colors.black),
                controller: _conditionTextEditingController,
                decoration: InputDecoration(
                  hintText: "Condition",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
            trailing: PopupMenuButton<String>(
              icon: Icon(Icons.arrow_drop_down, size: 30.0,),
              offset: Offset(0.0, 50.0),
              onSelected: typeAction,
              itemBuilder: (BuildContext context){
                return Type.types.map((String choice){
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ),
          SizedBox(height: 20.0,),

          ListTile(
            leading: Icon(Icons.category_outlined, color: Colors.grey[400],),
            title: Container(
              width: 250.0,
              child: TextField(
                cursorColor: Colors.blue,
                keyboardType: TextInputType.text,
                style: TextStyle(color: Colors.black),
                controller: _categoryTextEditingController,
                decoration: InputDecoration(
                  hintText: "Category",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
            trailing: PopupMenuButton<String>(
              icon: Icon(Icons.arrow_drop_down, size: 30.0,),
              offset: Offset(0.0, 50.0),
              onSelected: categoryAction,
              itemBuilder: (BuildContext context){
                return CategoryType.categoryTypes.map((String choice){
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ),
          SizedBox(height: 20.0,),
        ],
      ),
    );
  }

  Future<String> uploadItemImage(mFileImage) async {
    final StorageReference storageReference = FirebaseStorage.instance.ref().child("Items");
    StorageUploadTask uploadTask = storageReference.child("product_$productId.jpg").putFile(mFileImage);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  uploadImageAndSaveItemInfo() async {
    setState(() {
      uploading = true;
    });

    String imageDownloadUrl = await uploadItemImage(file);

    if(_shortInfoTextEditingController.text.isNotEmpty
        && _descriptionTextEditingController.text.isNotEmpty
        && _oldPriceTextEditingController.text.isNotEmpty
        && _priceTextEditingController.text.isNotEmpty
        && _titleTextEditingController.text.isNotEmpty
        && _categoryTextEditingController.text.isNotEmpty
        && _conditionTextEditingController.text.isNotEmpty && city.isNotEmpty && country.isNotEmpty)
      {
        saveItemInfo(imageDownloadUrl);
      }
    else
      {
        setState(() {
          uploading = false;
        });

        showDialog(
            context: context,
            builder: (c) {
              return ErrorAlertDialog(message: "Missing information",);
            }
        );
      }

  }

  saveItemInfo(String downloadUrl)
  {
    final itemsRef = Firestore.instance.collection("items");
    itemsRef.document(productId).setData({
      "shortInfo": _shortInfoTextEditingController.text.trim(),
      "longDescription": _descriptionTextEditingController.text.trim(),
      "oldPrice": int.parse(_oldPriceTextEditingController.text.trim()),
      "price": int.parse(_priceTextEditingController.text.trim()),
      "publishedDate": DateTime.now().millisecondsSinceEpoch,
      "status": "available",
      "thumbnailUrl": downloadUrl,
      "title": _titleTextEditingController.text.trim(),
      "category": _categoryTextEditingController.text.trim(),
      "condition": _conditionTextEditingController.text,
      "publisher": widget.name,
      "publisherID": widget.userID,
      "phone": widget.phone,
      "city": city,
      "country": country,
    });

    setState(() {
      file = null;
      uploading = false;
      productId= DateTime.now().millisecondsSinceEpoch.toString();
      _descriptionTextEditingController.clear();
      _titleTextEditingController.clear();
      _shortInfoTextEditingController.clear();
      _priceTextEditingController.clear();
      _oldPriceTextEditingController.clear();
      _conditionTextEditingController.clear();
      _categoryTextEditingController.clear();
    });
  }

  clearFormInfo() {
    setState(() {
      file = null;
    });

    _descriptionTextEditingController.clear();
    _priceTextEditingController.clear();
    _oldPriceTextEditingController.clear();
    _titleTextEditingController.clear();
    _shortInfoTextEditingController.clear();
    _conditionTextEditingController.clear();
    _categoryTextEditingController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return file == null ? displayAdminHomeScreen() : displayUploadFormScreen();
  }
}
