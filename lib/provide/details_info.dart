import 'package:flutter/material.dart';
import '../model/details_model.dart';
import '../service/service_method.dart';
import 'dart:convert';

class DetailsInfoProvide with ChangeNotifier {
  DetailsModel detailInfo = null;

  bool isLeft = true;
  bool isRight = false;

  //商品的详情请求
  getGoodsInfo(String id) async {
    var formData = {'goodId': id};
    await request('getGoodDetailById', formData: formData).then((val) {
      var requestData = json.decode(val.toString());
      print(requestData);
      detailInfo = DetailsModel.fromJson(requestData);
      notifyListeners();
    });
  }

  //改变tabBar的状态
  changeLeftAndRight(String changeState) {
    if (changeState == 'left') {
      isLeft = true;
      isRight = false;
    } else {
      isLeft = false;
      isRight = true;
    }
    //发送消息
    notifyListeners();
  }
}
