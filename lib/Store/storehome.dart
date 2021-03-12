import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Models/category.dart';
import 'package:e_shop/Models/time.dart';
import 'package:e_shop/Store/Search.dart';
import 'package:e_shop/Store/cart.dart';
import 'package:e_shop/Store/product_page.dart';
import 'package:e_shop/Counters/cartitemcounter.dart';
import 'package:e_shop/Widgets/categoryDesign.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:e_shop/Config/config.dart';
import '../Widgets/loadingWidget.dart';
import '../Widgets/myDrawer.dart';
import '../Models/item.dart';

double width;

class StoreHome extends StatefulWidget {
  @override
  _StoreHomeState createState() => _StoreHomeState();
}

class _StoreHomeState extends State<StoreHome> {

  bool loading = false;
  Position position;
  String city;
  String country;
  List<String> url = [
    "images/1.jpg",
    //"images/2.jpg",
    "images/m1.jpeg",
    "images/w1.jpeg",
    "images/w3.jpeg",
    "images/w4.jpeg"
  ];


  @override
  void initState() {
    super.initState();

     _determinePosition();
  }

  _determinePosition() async {
    
    setState(() {
      loading = true;
    });
    
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.deniedForever) {

        setState(() {
          loading = false;
        });

        return Future.error(
            'Location permissions are permantly denied, we cannot request permissions.');
      }
      else if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {

          setState(() {
            loading = false;
          });

          return Future.error(
              'Location permissions are denied (actual value: $permission).');
        }
      }
      else
        {
          position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

          List<Placemark> placeMarks = await placemarkFromCoordinates(position.latitude, position.longitude);
          Placemark mPlaceMark = placeMarks[0];
          String completeAddressInfo = '${mPlaceMark.subThoroughfare} ${mPlaceMark.thoroughfare}, '
              '${mPlaceMark.subLocality} ${mPlaceMark.locality}, '
              '${mPlaceMark.subAdministrativeArea} ${mPlaceMark.administrativeArea}, '
              '${mPlaceMark.postalCode} ${mPlaceMark.country}';
          String specificAddress = '${mPlaceMark.subLocality}, ${mPlaceMark.locality}, ${mPlaceMark.country}';
          String cityAddress = '${mPlaceMark.locality}';
          String countryAddress = '${mPlaceMark.country}';

          print(specificAddress);
          setState(() {
            loading = false;
            city = cityAddress;
            country = countryAddress;
          });
        }

      //return Future.error('Location services are disabled.');
    }
    else
      {
        position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

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
          loading = false;
          city = cityAddress;
          country = countryAddress;
        });
      }
  }

  displayCategories() {
    return ListView(
      physics: BouncingScrollPhysics(),
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      children: List.generate(categories.length, (index) {
        Category category = categories[index];

        return CategoryDesign(category: category, city: city, country: country);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> images = List.generate(url.length, (index) {
      String image = url[index];

      return Container(
        height: MediaQuery.of(context).size.height * 0.25,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(image),
            fit: BoxFit.fill,
          )
        ),
      );
    });

    Widget carousel = CarouselSlider(
        items: images,
        options: CarouselOptions(
          height: MediaQuery.of(context).size.height * 0.25,
          autoPlay: true,
          reverse: false,
          viewportFraction: 1.0
        )
    );

    width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
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
          "Mimi Shop",
          style: GoogleFonts.fredokaOne(
              color: Colors.white,
              fontSize: 30.0,
              // fontFamily: "Signatra"
          ),
        ),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart, color: Colors.white,),
                onPressed: () {
                  Route route = MaterialPageRoute(builder: (context)=> CartPage());
                  Navigator.pushReplacement(context, route);
                },
              ),
              Positioned(
                child: Stack(
                  children: [
                    Icon(Icons.brightness_1, color: Colors.green[500], size: 20.0,),
                    Positioned(
                      top: 3.0,
                      bottom: 4.0,
                      left: 6.0,
                      child: Consumer<CartItemCounter>(
                        builder: (context, counter, _) {
                          return Text(
                            (EcommerceApp.sharedPreferences.getStringList(EcommerceApp.userCartList).length-1).toString(),
                            style: TextStyle(color: Colors.white, fontSize: 12.0, fontWeight: FontWeight.w500),
                          );
                        },
                      ),
                    )
                  ],
                ),
              )
            ],
          )
        ],
        bottom: PreferredSize(
          preferredSize: Size(width, 60.0),
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  Route route = MaterialPageRoute(builder: (context)=> SearchProduct());
                  Navigator.push(context, route);
                },
                child: Container(
                  height: 40.0,
                  width: width * 0.9,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    color: Colors.white70
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 10.0,),
                      Icon(Icons.search, color: Colors.black,),
                      SizedBox(width: 10.0,),
                      Text("Search here...")
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      drawer: MyDrawer(),
      body: loading ? circularProgress() : SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            carousel,
            SizedBox(height: 10.0,),
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Text("Categories", style: GoogleFonts.fredokaOne(fontSize: 20.0,),),
            ),
            Container(
              height: 220.0,
              child: displayCategories(),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Text("Discover Sellers \n Around You", style: GoogleFonts.fredokaOne(fontSize: 30.0,),),
            ),
            SizedBox(
              height: 10.0,
            ),
            position == null ?
            Center(
              child: Container(
                height: 50,
                width: 180,
                child: RaisedButton(
                  onPressed: () {
                    _determinePosition();
                  },
                  color: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)
                  ),
                  child: Text("Turn On Location", style: GoogleFonts.fredokaOne(color: Colors.white, fontSize: 17.0),),
                  elevation: 5.0,
                ),
              ),
            ) : StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection("items")
                  .where("country", isEqualTo: country).where("city", isEqualTo: city).limit(15).orderBy("publishedDate", descending: true).snapshots(),
              builder: (context, dataSnapshot) {
                if(!dataSnapshot.hasData)
                {
                  return Center(child: circularProgress(),);
                }
                else if(dataSnapshot.data.documents.length == 0)
                  {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image(
                            image: AssetImage("images/nodata.png"),
                            height: 100.0,
                            width: 100.0,
                          ),
                          Text("No Data", style: TextStyle(color: Colors.grey, fontSize: 17.0),),
                        ],
                      ),
                    );
                  }
                else
                  {
                    return Column(
                      children: List.generate(dataSnapshot.data.documents.length, (index) {
                        ItemModel model = ItemModel.fromJson(dataSnapshot.data.documents[index].data);

                        return sourceInfo(model, context);
                      }),
                    );
                  }

              },
            )
          ],
        ),
      ),
    );
  }
}



Widget sourceInfo(ItemModel model, BuildContext context,
    {Color background, removeCartFunction}) {

  double percentage = ((model.oldPrice - model.price)/model.oldPrice) * 100;

  return InkWell(
    onTap: () {
      Route route = MaterialPageRoute(builder: (context)=> ProductPage(itemModel: model));
      Navigator.pushReplacement(context, route);
    },
    splashColor: Colors.blue,
    child: Padding(
      padding: EdgeInsets.all(6.0),
      child: Container(
        height: 190.0,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(color: Colors.black38, offset: Offset(2.0, -2.0), blurRadius: 6.0)
          ]
        ),
        child: Row(
          children: [
            Container(
              height: 190,
              width: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), bottomLeft: Radius.circular(15.0)),
                image: DecorationImage(
                  image: NetworkImage(model.thumbnailUrl),
                  fit: BoxFit.cover
                )
              ),
            ),
            SizedBox(width: 4.0,),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5,),
                  Align(
                    alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: Text(Time.readTimestamp(model.publishedDate), style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),),
                      )),
                  SizedBox(height: 10.0,),
                  Container(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Text(model.title, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14.0),),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 5.0,),
                  Container(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Text(model.shortInfo, style: TextStyle(color: Colors.black54, fontSize: 12.0),),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 20.0,),
                  Row(
                    children: [
                      percentage.round() == 0 ? Text("") : Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Colors.blue
                        ),
                        alignment: Alignment.topLeft,
                        width: 40.0,
                        height: 43.0,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("${percentage.round().toString()} %", style: TextStyle(fontSize: 15.0, color: Colors.white, fontWeight: FontWeight.normal),),
                              Text("OFF", style: TextStyle(fontSize: 12.0, color: Colors.white, fontWeight: FontWeight.normal),),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 10.0,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Padding(
                          //   padding: EdgeInsets.only(top: 0.0),
                          //   child: Row(
                          //     children: [
                          //       Text(
                          //         "Original Price: Ksh ",
                          //         style: TextStyle(
                          //           fontSize: 14.0,
                          //           color: Colors.grey,
                          //           decoration: TextDecoration.lineThrough
                          //         ),
                          //       ),
                          //       Text(
                          //         (model.price + model.price).toString(),
                          //         style: TextStyle(
                          //             fontSize: 15.0,
                          //             color: Colors.grey,
                          //           decoration: TextDecoration.lineThrough
                          //         ),
                          //       )
                          //     ],
                          //   ),
                          // ),
                          Padding(
                            padding: EdgeInsets.only(top: 5.0),
                            child: Row(
                              children: [
                                Text(
                                  "New Price: ",
                                  style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.grey
                                  ),
                                ),
                                Text(
                                  "Ksh ",
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.red,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                                Text(
                                  (model.price).toString(),
                                  style: TextStyle(
                                      fontSize: 15.0,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),

                  Flexible(
                    child: Container(

                    ),
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: removeCartFunction == null
                    ? IconButton(
                      icon: Icon(Icons.add_shopping_cart, color: Colors.blue,),
                      onPressed: () {
                        checkItemInCart(model.shortInfo, context);
                      },
                    )
                    : IconButton(
                      icon: Icon(Icons.remove_shopping_cart, color: Colors.grey[400],),
                      onPressed: () {
                        removeCartFunction();
                        Route route = MaterialPageRoute(builder: (context)=> StoreHome());
                        Navigator.pushReplacement(context, route);
                      },
                    ) ,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    ),
  );
}



Widget card({Color primaryColor = Colors.deepOrange, String imgPath}) {
  return Container(
    height: 150.0,
    width: width * .34,
    margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
    decoration: BoxDecoration(
      color: primaryColor,
      borderRadius: BorderRadius.circular(20.0),
      boxShadow: [
        BoxShadow(
          offset: Offset(0, 5),
          blurRadius: 10.0,
          color: Colors.grey[200]
        )
      ]
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: Image.network(
        imgPath,
        height: 150.0,
        width: width * .34,
        fit: BoxFit.fill,
      ),
    ),
  );
}



void checkItemInCart(String shortInfoAsID, BuildContext context)
{
  EcommerceApp.sharedPreferences.getStringList(EcommerceApp.userCartList).contains(shortInfoAsID)
      ? Fluttertoast.showToast(
    msg: "Item already in Cart",
  )
      : addItemToCart(shortInfoAsID, context);
}

addItemToCart(String shortInfoAsID, BuildContext context) {
  List tempCartList = EcommerceApp.sharedPreferences.getStringList(EcommerceApp.userCartList);

  tempCartList.add(shortInfoAsID);

  EcommerceApp.firestore.collection(EcommerceApp.collectionUser)
      .document(EcommerceApp.sharedPreferences.getString(EcommerceApp.userUID))
      .updateData({EcommerceApp.userCartList: tempCartList}).then((v) {
        Fluttertoast.showToast(msg: "Item added to Cart successfully");

        EcommerceApp.sharedPreferences.setStringList(EcommerceApp.userCartList, tempCartList);

        Provider.of<CartItemCounter>(context, listen: false).displayResult();
  });
}
