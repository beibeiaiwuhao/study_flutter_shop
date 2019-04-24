import 'package:flutter/material.dart';
import 'package:provide/provide.dart';
import '../../provide/details_info.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

//详细页面的顶部区域
class DetailsTopArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provide<DetailsInfoProvide>(
      builder: (context, child, val) {
        if (Provide.value<DetailsInfoProvide>(context).detailInfo != null) {
          var goodsInfo = Provide.value<DetailsInfoProvide>(context)
              .detailInfo
              .data
              .goodInfo;
          if (goodsInfo != null) {
            return Container(
              color: Colors.white,
              padding: EdgeInsets.all(2.0),
              child: Column(
                children: <Widget>[
                  _goodsImageUrl(goodsInfo.image1),
                  _goodsName(goodsInfo.goodsName),
                  _goodsNum(goodsInfo.goodsSerialNumber),
                  _goodsPrice(goodsInfo.presentPrice, goodsInfo.oriPrice)
                ],
              ),
            );
          }
        }else {
          return Text('加载中。。。。');
        }
      },
    );
  }
}

//商品图片
Widget _goodsImageUrl(String url) {
  return Image.network(
    url,
    width: ScreenUtil().setWidth(740),
  );
}

//商品名称
Widget _goodsName(name) {
  return Container(
    width: ScreenUtil().setWidth(730),
    padding: EdgeInsets.only(left: 15.0),
    child: Text(name,
        maxLines: 1, style: TextStyle(fontSize: ScreenUtil().setSp(30))),
  );
}

//编号方法
Widget _goodsNum(num) {
  return Container(
    width: ScreenUtil().setWidth(730),
    padding: EdgeInsets.only(left: 15.0),
    margin: EdgeInsets.only(top: 8.0),
    child: Text('编号：${num}', style: TextStyle(color: Colors.black26)),
  );
}

//商品价格的方法
Widget _goodsPrice(presentPrice, oriPrice) {
  return Container(
    width: ScreenUtil().setWidth(730),
    padding: EdgeInsets.only(left: 15.0),
    margin: EdgeInsets.only(top: 8.0),
    child: Row(
      children: <Widget>[
        Text('¥${presentPrice}',
            style: TextStyle(
                color: Colors.pinkAccent, fontSize: ScreenUtil().setSp(40))),
        Text(
          '市场价:¥${oriPrice}',
          style: TextStyle(
              color: Colors.black26, decoration: TextDecoration.lineThrough),
        )
      ],
    ),
  );
}
