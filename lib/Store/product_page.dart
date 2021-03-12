import 'package:e_shop/Widgets/customAppBar.dart';
import 'package:e_shop/Widgets/myDrawer.dart';
import 'package:e_shop/Models/item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:e_shop/Store/storehome.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';


class ProductPage extends StatefulWidget {

  final ItemModel itemModel;

  ProductPage({this.itemModel});

  @override
  _ProductPageState createState() => _ProductPageState();
}



class _ProductPageState extends State<ProductPage> {
  int quantityOfItems = 1;

  @override
  Widget build(BuildContext context)
  {
    Size screenSize = MediaQuery.of(context).size;
    double percentage = ((widget.itemModel.oldPrice - widget.itemModel.price)/widget.itemModel.oldPrice) * 100;

    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(),
        drawer: MyDrawer(),
        body: ListView(
          children: [
            Container(
              //padding: EdgeInsets.all(8.0),
              width: screenSize.width,
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Center(
                        child: Image.network(widget.itemModel.thumbnailUrl),
                      ),
                      SizedBox(
                        height: 1.0,
                        width: double.infinity,
                      )
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.all(20.0),
                     child: Center(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Align(
                             alignment: Alignment.centerRight,
                             child: Row(
                               mainAxisAlignment: MainAxisAlignment.end,
                               children: [
                                 Text("Discount: ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17.0),),
                                 Text("${percentage.round().toString()} %", style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: 17.0),),
                               ],
                             ),
                           ),
                           Text(
                             widget.itemModel.title,
                             style: boldTextStyle,
                           ),
                           SizedBox(
                             height: 10.0,
                           ),
                           Text(
                             widget.itemModel.longDescription,
                             style: TextStyle(fontSize: 17.0),
                           ),
                           SizedBox(
                             height: 10.0,
                           ),
                           Text(
                             "Ksh " + widget.itemModel.price.toString(),
                             style: boldTextStyle,
                           ),
                           SizedBox(
                             height: 10.0,
                           )
                         ],
                       ),
                     ),
                  ),
                  Center(
                    child: Text("Published by ${widget.itemModel.publisher}"),
                  )
                ],
              ),
            )
          ],
        ),
        bottomNavigationBar: Container(
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
                child: Container(
                  height: 50,
                  //width: 180,
                  child: RaisedButton.icon(
                    onPressed: ()=> checkItemInCart(widget.itemModel.shortInfo, context),
                    color: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)
                    ),
                    icon: Icon(Icons.add_shopping_cart_outlined, color: Colors.white,),
                    label: Text("Add to Cart", style: GoogleFonts.fredokaOne(color: Colors.white, fontSize: 17.0),),
                    elevation: 5.0,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
                child: Container(
                  height: 50,
                  //width: 180,
                  child: RaisedButton.icon(
                    onPressed: () => launch("tel:${widget.itemModel.phone}"),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)
                    ),
                    label: Text("Call", style: GoogleFonts.fredokaOne(color: Colors.black, fontSize: 17.0),),
                    icon: Icon(Icons.phone, color: Colors.blue,),
                    elevation: 5.0,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
                child: Container(
                  height: 50,
                  //width: 180,
                  child: RaisedButton.icon(
                    onPressed: () => launch("sms:${widget.itemModel.phone}"),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)
                    ),
                    icon: Icon(Icons.message_outlined, color: Colors.blue,),
                    label: Text("Chat", style: GoogleFonts.fredokaOne(color: Colors.black, fontSize: 17.0),),
                    elevation: 5.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

const boldTextStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 20);
const largeTextStyle = TextStyle(fontWeight: FontWeight.normal, fontSize: 20);
