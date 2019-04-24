import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../model/cart_info.dart';
import 'package:provide/provide.dart';
import '../../provide/cart.dart';

class CartCount extends StatelessWidget {

  final CartInfoModel cartItem;
  CartCount({this.cartItem});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil().setWidth(165),
      margin: EdgeInsets.only(top: 5.0),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Colors.black12
        )
      ),
      child: Row(
        children: <Widget>[
          _reduceBtn(context),
          _countArea(),
          _addBtn(context)
        ],
      ),
    );
  }


  //减少按钮
  Widget _reduceBtn(BuildContext context) {
    return InkWell(
      onTap: (){
        Provide.value<CartProvide>(context).addOrReduceAction(cartItem, 'reduce');

      },
      child: Container(
        width: ScreenUtil().setWidth(45),
        height: ScreenUtil().setHeight(45),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            right: BorderSide(width: 1,color: Colors.black12)
          )
        ),
        child: Text('-'),
      ),
    );
  }

 //增加按钮
  Widget _addBtn(context) {
    return InkWell(
      onTap: (){

        Provide.value<CartProvide>(context).addOrReduceAction(cartItem, 'add');
      },
      child: Container(
        width: ScreenUtil().setWidth(45),
        height: ScreenUtil().setHeight(45),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            right: BorderSide(width: 1,color: Colors.black12)
          )
        ),
        child: Text('+'),
      ),
    );
  }

  //数量区域
  Widget _countArea() {
    return Container(
      width: ScreenUtil().setWidth(70),
      height: ScreenUtil().setHeight(45),
      alignment: Alignment.center,
      color: Colors.white,
      child: Text('${cartItem.count}'),
    );
  }


}