import 'package:e_shop/Address/address.dart';
import 'package:e_shop/Authentication/authenication.dart';
import 'package:e_shop/Config/config.dart';
import 'package:e_shop/Address/addAddress.dart';
import 'package:e_shop/Store/Search.dart';
import 'package:e_shop/Store/cart.dart';
import 'package:e_shop/Orders/myOrders.dart';
import 'package:e_shop/Store/storehome.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          Container(
            padding: EdgeInsets.only(top: 25.0, bottom: 10.0),
            child: Column(
              children: [
                Material(
                  borderRadius: BorderRadius.circular(80.0),
                  elevation: 8.0,
                  child: Container(
                    height: 160.0,
                    width: 160.0,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(EcommerceApp.sharedPreferences.getString(EcommerceApp.userAvatarUrl)),
                    ),
                  ),
                ),
                SizedBox(height: 10.0,),
                Text(
                  EcommerceApp.sharedPreferences.getString(EcommerceApp.userName),
                  style: TextStyle(color: Colors.black, fontSize: 35.0, fontFamily: "Signatra"),
                )
              ],
            ),
          ),
          SizedBox(height: 12.0,),
          Container(
            padding: EdgeInsets.only(top: 1.0),
            child: Column(
              children: [

                ListTile(
                  leading: Icon(Icons.home, color: Colors.grey[400],),
                  title: Text("Home", style: TextStyle(color: Colors.black),),
                  onTap: () {
                    Route route = MaterialPageRoute(builder: (context)=> StoreHome());
                    Navigator.pushReplacement(context, route);
                  },
                ),
                Divider(height: 10.0,),

                ListTile(
                  leading: Icon(Icons.shopping_bag_outlined, color: Colors.grey[400],),
                  title: Text("My Orders", style: TextStyle(color: Colors.black),),
                  onTap: () {
                    Route route = MaterialPageRoute(builder: (context)=> MyOrders());
                    Navigator.pushReplacement(context, route);
                  },
                ),
                Divider(height: 10.0,),

                ListTile(
                  leading: Icon(Icons.shopping_cart, color: Colors.grey[400],),
                  title: Text("My Cart", style: TextStyle(color: Colors.black),),
                  onTap: () {
                    Route route = MaterialPageRoute(builder: (context)=> CartPage());
                    Navigator.pushReplacement(context, route);
                  },
                ),
                Divider(height: 10.0,),

                ListTile(
                  leading: Icon(Icons.search, color: Colors.grey[400],),
                  title: Text("Search", style: TextStyle(color: Colors.black),),
                  onTap: () {
                    Route route = MaterialPageRoute(builder: (context)=> SearchProduct());
                    Navigator.pushReplacement(context, route);
                  },
                ),
                Divider(height: 10.0,),

                ListTile(
                  leading: Icon(Icons.my_library_add_outlined, color: Colors.grey[400],),
                  title: Text("Add new Address", style: TextStyle(color: Colors.black),),
                  onTap: () {
                    Route route = MaterialPageRoute(builder: (context)=> Address());
                    Navigator.pushReplacement(context, route);
                  },
                ),
                Divider(height: 10.0,),

                ListTile(
                  leading: Icon(Icons.logout, color: Colors.grey[400],),
                  title: Text("Logout", style: TextStyle(color: Colors.black),),
                  onTap: () {
                    EcommerceApp.auth.signOut().then((c) {
                      Route route = MaterialPageRoute(builder: (context)=> AuthenticScreen());
                      Navigator.pushReplacement(context, route);
                    });
                  },
                ),
                Divider(height: 10.0,),
              ],
            ),
          )
        ],
      ),
    );
  }
}
