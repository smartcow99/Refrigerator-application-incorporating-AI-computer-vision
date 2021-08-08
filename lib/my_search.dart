import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:refrigerator/searchbar_screen.dart';

import 'banner_screen.dart';

class MySearch extends StatefulWidget {
  const MySearch({Key? key}) : super(key: key);

  @override
  _MySearchState createState() => _MySearchState();
}

class _MySearchState extends State<MySearch> {
  String searchbarText = "";
  @override
  Widget build(BuildContext context) {
    return  Column(
      children:[
        Container(
          child: SearchBar(function: returnDataFunction,),
        ),

        Container(
          height: 500,
          margin: EdgeInsets.only(left: 10,right: 10,top: 10),
          padding: EdgeInsets.only(left: 10,right: 10),
          alignment: Alignment.center,
          child: BannerPage(textdata: searchbarText,),
          color: Colors.black12,

        )
      ],
    );

  }

  void returnDataFunction(String rtData){
    setState(() {
      searchbarText = rtData;
    });
  }
}
