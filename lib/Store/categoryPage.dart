import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Models/category.dart';
import 'package:e_shop/Models/item.dart';
import 'package:e_shop/Store/storehome.dart';
import 'package:e_shop/Widgets/loadingWidget.dart';
import 'package:flutter/material.dart';


class CategoryPage extends StatefulWidget {

  final Category category;
  final String city;
  final String country;

  CategoryPage({this.category, this.country, this.city});

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {

  Future<QuerySnapshot> futureResults;
  bool loading = false;
  List<ItemModel> models;


  @override
  void initState() {
    super.initState();

    getPosts();
  }

  getPosts() async {
    setState(() {
      loading = true;
    });

    QuerySnapshot querySnapshot = await Firestore.instance.collection("items")
        .where("country", isEqualTo: widget.country).where("city", isEqualTo: widget.city).where("category", isEqualTo: widget.category.name)
        .limit(15).orderBy("publishedDate", descending: true).getDocuments();

    setState(() {
      //futureResults = querySnapshot;
      models = querySnapshot.documents.map((document) => ItemModel.fromJson(document.data)).toList();
      loading = false;
    });
  }

  displayList() {

    if(models.length == 0)
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
        return ListView.builder(
          shrinkWrap: true,
          itemCount: models.length,
          itemBuilder: (BuildContext context, int index) {
            ItemModel model = models[index];

            return sourceInfo(model, context);
          },
        );
      }
    // return FutureBuilder(
    //   future: futureResults,
    //   builder: (BuildContext context, snapshot) {
    //     if(!snapshot.hasData)
    //       {
    //         return circularProgress();
    //       }
    //     else
    //       {
    //         List<ItemModel> postList = snapshot.data;
    //
    //         if(postList.length == 0)
    //           {
    //             return Center(
    //               child: Column(
    //                 mainAxisAlignment: MainAxisAlignment.start,
    //                 crossAxisAlignment: CrossAxisAlignment.center,
    //                 children: [
    //                   Image(
    //                     image: AssetImage("images/nodata.png"),
    //                     height: 100.0,
    //                     width: 100.0,
    //                   ),
    //                   Text("No Data", style: TextStyle(color: Colors.grey, fontSize: 17.0),),
    //                 ],
    //               ),
    //             );
    //           }
    //         else
    //           {
    //             return ListView.builder(
    //               shrinkWrap: true,
    //               itemCount: postList.length,
    //               itemBuilder: (BuildContext context, int index) {
    //                 ItemModel model = postList[index];
    //
    //                 return sourceInfo(model, context);
    //               },
    //             );
    //           }
    //       }
    //   },
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.category.name),
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
      ),
      body: loading ? circularProgress() : displayList(),
    );
  }
}
