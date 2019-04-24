import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../provide/details_info.dart';
import '../../provide/cart.dart';
import 'package:provide/provide.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../provide/current_index.dart';

class DetailsBottom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //添加到购物车需要准备的数据
    var goodsInfo =
        Provide.value<DetailsInfoProvide>(context).detailInfo.data.goodInfo;
    var goodsId = goodsInfo.goodsId;
    var goodsName = goodsInfo.goodsName;
    var count = 1;
    var price = goodsInfo.presentPrice;
    var images = goodsInfo.image1;

    return Container(
      width: ScreenUtil().setWidth(750),
      color: Colors.white,
      height: ScreenUtil().setHeight(80),
      child: Row(
        children: <Widget>[
          Stack(children: <Widget>[
            //购物车按钮
            InkWell(
              onTap: () {
                Provide.value<CurrentIndexProvide>(context).changeIndex(2);
                Navigator.pop(context);
              },
              child: Container(
                width: ScreenUtil().setWidth(110),
                alignment: Alignment.center,
                child: Icon(Icons.shopping_cart, size: 35, color: Colors.red),
              ),
            ),
            Provide<CartProvide>(
              builder: (context, child, val) {
                int goodsCount = Provide.value<CartProvide>(context).allGoodsCount;
                return Positioned(
                  top: 0,
                  right: 10,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(6, 3, 6, 3),
                    decoration: BoxDecoration(
                      color: Colors.pink,
                      border: Border.all(
                        width: 1.0,
                        color: Colors.white
                      ),
                      borderRadius: BorderRadius.circular(12.0)
                    ),
                    child: Text(
                      '${goodsCount}',
                      style:TextStyle(
                        color: Colors.white,
                        fontSize: ScreenUtil().setSp(22)
                      )
                    ),
                  ),
                );
              },
            )
          ]),
          //加入购物车
          InkWell(
            onTap: () async {
              //持久化到本地
              await Provide.value<CartProvide>(context)
                  .save(goodsId, goodsName, count, price, images);
              Fluttertoast.showToast(
                msg: '添加到购物车成功',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                backgroundColor: Colors.pink,
                textColor: Colors.white,
                fontSize: 16.0,
              );
              // await Provide.value<CartProvide>(context).remove();
            },
            child: Container(
              alignment: Alignment.center,
              width: ScreenUtil().setWidth(320),
              height: ScreenUtil().setHeight(80),
              color: Colors.green,
              child: Text('加入购物车',
                  style: TextStyle(
                      color: Colors.white, fontSize: ScreenUtil().setSp(28))),
            ),
          ),
          //立即购买
          InkWell(
            onTap: () {},
            child: Container(
              alignment: Alignment.center,
              width: ScreenUtil().setWidth(320),
              height: ScreenUtil().setHeight(80),
              color: Colors.red,
              child: Text('立即购买',
                  style: TextStyle(
                      color: Colors.white, fontSize: ScreenUtil().setSp(28))),
            ),
          ),
        ],
      ),
    );
  }
}
