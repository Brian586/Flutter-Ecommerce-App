import 'package:e_shop/Config/config.dart';
import 'package:e_shop/Store/cart.dart';
import 'package:e_shop/Counters/cartitemcounter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class MyAppBar extends StatelessWidget with PreferredSizeWidget
{
  final PreferredSizeWidget bottom;
  MyAppBar({this.bottom});


  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
      elevation: 3.0,
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
        style: TextStyle(
            color: Colors.white,
            fontSize: 40.0,
            fontFamily: "Signatra"
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
    );
  }


  Size get preferredSize => bottom==null?Size(56,AppBar().preferredSize.height):Size(56, 80+AppBar().preferredSize.height);
}
