import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../model/cart_info.dart';

final String CART_KEY = 'cartInfo';

class CartProvide with ChangeNotifier {
  String cartString = '[]';

  List<CartInfoModel> cartList = [];

  double allPrice = 0;//总价格
  int allGoodsCount = 0;//商品纵数量

  bool isAllCheck = true;//是否全选

  //加入购物车
  save(goodsId, goodsName, count, price, images) async {
    //初始化 SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //获取持久化存储的值
    cartString = prefs.getString(CART_KEY);
    //判断cartString 是否为空，为空说明是第一次添加，或者被key被清除了
    //如果有值进行decode操作
    var temp = cartString == null ? [] : json.decode(cartString.toString());

    //把获得值转变成List
    List<Map> tempList = (temp as List).cast();

    //先将tempList中的map转换城model
    cartList = [];
    tempList.forEach((item) {
      cartList.add(new CartInfoModel.fromJson(item));
    });

    //声明变量，用于判断购物车中是否已经存在此商品ID
    var isHave = false;
    int ival = 0; //用于进行循环的索引使用

    tempList.forEach((item) {
      //如果存在，数量进行+1操作
      if (item['goodsId'] == goodsId) {
        tempList[ival]['count'] = item['count'] + 1;
        cartList[ival].count++;
        isHave = true;
      }
      ival++;
    });

    //如果没有，进行增加
    if (!isHave) {
      Map<String, dynamic> newGoods = {
        'goodsId': goodsId,
        'goodsName': goodsName,
        'count': count,
        'price': price,
        'isCheck': true,
        'images': images
      };
      tempList.add(newGoods);
      cartList.add(new CartInfoModel.fromJson(newGoods));
    }

    //把字符串进行encode操作
    cartString = json.encode(tempList).toString();
    print(cartString);
    //进行持久化
    prefs.setString(CART_KEY, cartString);
  }

  //得到购物车中的商品
  getCartInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //获得购物车中的商品，这时候是一个字符串
    cartString = prefs.getString(CART_KEY);
    //把cartList进行初始化，防止数据混乱
    cartList = [];
    //判断得到的字符串是否有值，如果不判断会报错
    if (cartString == null) {
      cartList = [];
    } else {
      List<Map> tempList = (json.decode(cartString.toString()) as List).cast();
      allPrice = 0;
      allGoodsCount = 0;
      isAllCheck = true;

      tempList.forEach((item) {
        cartList.add(new CartInfoModel.fromJson(item));
        if (item['isCheck']) {
          allPrice += (item['count']*item['price']);
          allGoodsCount += item['count'];
        }else {
          isAllCheck = false;
        }
      });
    }
    notifyListeners();
  }

  //清空购物车 (测试使用)
  remove() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(CART_KEY);
    print('清空完成');
    notifyListeners();
  }

  //删除单个购物车商品
  deleteOneGoods(String goodsId) async {
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    cartString = prefs.getString(CART_KEY);
    List<Map> tempList = (json.decode(cartString.toString()) as List).cast();

    int tempIndex = 0;
    int delIndex = 0;
    tempList.forEach((item) {
      if (item['goodsId'] == goodsId) {
        delIndex = tempIndex;
      }
      tempIndex++;
    });
    tempList.removeAt(delIndex);
    cartString = json.encode(tempList).toString();
    prefs.setString(CART_KEY, cartString);
    await getCartInfo();
  }

  //改变商品的修改状态
  changeCheckState(CartInfoModel cartItem) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    cartString = prefs.getString(CART_KEY);
    List<Map> tempList = (json.decode(cartString) as List).cast();

    int tempIndex = 0;//循环使用索引
    int changeIndex = 0;//需要修改的索引

    tempList.forEach(
      (item){
        if (item['goodsId'] == cartItem.goodsId) {
          changeIndex = tempIndex;
        }
        tempIndex ++;
      }
    );

    tempList[changeIndex] = cartItem.toJson();//把对象变成Map值
    cartString = json.encode(tempList).toString();
    prefs.setString(CART_KEY, cartString);
    //重新获取购物车的商品
    await getCartInfo();
  }


//购物车商品的全选
changeAllCheckBtnState(bool isCheck) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  cartString = prefs.getString(CART_KEY);
  List<Map> tempList = (json.decode(cartString) as List).cast();
  List<Map> newList = [];
  for (var item in tempList) {
    var newItem = item;
    newItem['isCheck'] = isCheck;
    newList.add(newItem);
    
  }
  cartString = json.encode(newList).toString();
  prefs.setString(CART_KEY, cartString);
  await getCartInfo();

}

//购物车数量的加减
addOrReduceAction(var cartItem,String todo) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  cartString = prefs.getString(CART_KEY);
  List<Map> tempList = (json.decode(cartString.toString()) as List).cast();

  int tempIndex = 0;
  int changeIndex = 0;
  tempList.forEach(
      (item) {
        if (item['goodsId'] == cartItem.goodsId) {
          changeIndex = tempIndex;
        }
        tempIndex ++;
      }
  );
  //加
  if (todo == 'add') {
    cartItem.count ++;
  }else if (cartItem.count > 1) {  //减
  cartItem.count --;
  }

tempList[changeIndex] = cartItem.toJson();
cartString = json.encode(tempList).toString();
prefs.setString(CART_KEY, cartString);
await getCartInfo();
}





}
