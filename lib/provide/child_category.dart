import 'package:flutter/material.dart';
import '../model/category_model.dart';

//ChangeNotifier的混入是不用管理听众
class ChildCategory with ChangeNotifier {
  
  List<BxMallSubDto> childCategoryList = [];//商品列表
  int childIndex = 0;//子类索引值
  String categoryId = '4';//大类ID
  String subId = '';//小类id

  int page = 1;//默认加载第一页
  String noMoreText = '';//没有数据显示

  //点击大类时索引
  getChildCategory(List<BxMallSubDto> list,String id) {

    page = 1;
    noMoreText = '';
    categoryId = id;
    childIndex = 0;

    BxMallSubDto all = BxMallSubDto();
    all.mallSubId = '';
    all.mallCategoryId = '';
    all.mallSubName = '全部';
    all.comments = 'null';
    childCategoryList = [all];
    childCategoryList.addAll(list);
    notifyListeners();
  }

  //改变子类索引
  changeChildIndex(int index,String id) {

    page = 1;
    noMoreText = '';

    subId = id;
    childIndex = index;
    notifyListeners();
  }
  //增加page
  addPage(){
    page++;
  }

  //改变noMoreText文字
  changeNoMoreText(String text) {
    noMoreText = text;
    notifyListeners();
  }


}
