import 'package:e_shop/Models/category.dart';
import 'package:e_shop/Store/categoryPage.dart';
import 'package:flutter/material.dart';


class CategoryDesign extends StatelessWidget {

  final Category category;
  final String city;
  final String country;

  CategoryDesign({this.category, this.country, this.city});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: InkWell(
        onTap: () {
          Route route = MaterialPageRoute(builder: (context)=> CategoryPage(
            category: category,
            city: city,
            country: country,
          ));
          Navigator.push(context, route);
        },
        child: Container(
          height: 180.0,
          width: 180.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 150.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  image: DecorationImage(
                    image: AssetImage(category.imageUrl),
                    fit: BoxFit.cover
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black38, offset: Offset(2.0, 2.0), blurRadius: 6.0)
                  ]
                ),
              ),
              SizedBox(height: 5.0,),
              Text(category.name, style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),)
            ],
          ),
        ),
      ),
    );
  }
}
