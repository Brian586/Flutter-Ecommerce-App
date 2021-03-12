import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  String title;
  String shortInfo;
  int publishedDate;
  String thumbnailUrl;
  String longDescription;
  String status;
  int price;
  String condition;
  int oldPrice;
  String category;
  String publisher;
  String phone;
  String city;
  String country;

  ItemModel(
      {this.title,
        this.shortInfo,
        this.publishedDate,
        this.thumbnailUrl,
        this.longDescription,
        this.status,
        this.condition,
        this.price,
        this.oldPrice,
        this.category,
        this.publisher,
        this.phone,
        this.country,
        this.city
        });

  ItemModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    shortInfo = json['shortInfo'];
    publishedDate = json['publishedDate'];
    thumbnailUrl = json['thumbnailUrl'];
    longDescription = json['longDescription'];
    status = json['status'];
    condition = json['condition'];
    price = json['price'];
    oldPrice = json['oldPrice'];
    category = json['category'];
    publisher = json['publisher'];
    phone = json['phone'];
    country = json['country'];
    city = json['city'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['shortInfo'] = this.shortInfo;
    data['price'] = this.price;
    if (this.publishedDate != null) {
      data['publishedDate'] = this.publishedDate;
    }
    data['thumbnailUrl'] = this.thumbnailUrl;
    data['longDescription'] = this.longDescription;
    data['status'] = this.status;
    data['oldPrice'] = this.oldPrice;
    data['condition'] = this.condition;
    data['category'] = this.category;
    data['publisher'] = this.publisher;
    data['phone'] = this.phone;
    data['country'] = this.country;
    data['city'] = this.city;
    return data;
  }
}

class PublishedDate {
  String date;

  PublishedDate({this.date});

  PublishedDate.fromJson(Map<String, dynamic> json) {
    date = json['$date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['$date'] = this.date;
    return data;
  }
}
