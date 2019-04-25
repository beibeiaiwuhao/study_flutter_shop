import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import '../pages/member_detail_page/map.dart';

Handler mapHandler = Handler(
  handlerFunc: (BuildContext context,Map<String,List<String>> param) {
    return GDMap();
  }
);


