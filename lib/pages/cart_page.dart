import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provide/provide.dart';
import '../provide/cart.dart';
import './cart_page/cart_item.dart';
import './cart_page/cart_bottom.dart';

List<String> showList = [];

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('购物车'),
        ),
        body: FutureBuilder(
          future: _getCartInfo(context),
          builder: (context, snapshot) {
            var cartList = Provide.value<CartProvide>(context).cartList;
            if (snapshot.hasData && cartList != null) {
              return Stack(
                children: <Widget>[
                  Provide<CartProvide>(
                    builder: (context, child, childCategory) {
                      var cartList1 =
                          Provide.value<CartProvide>(context).cartList;
                      return ListView.builder(
                        itemCount: cartList1.length,
                        itemBuilder: (context, index) {
                          return CartItem(cartList1[index]);
                        },
                      );
                    },
                  ),
                  Provide<CartProvide>(
                    builder: (context, child, childCategory) {
                      var cartList1 =
                          Provide.value<CartProvide>(context).cartList;
                      return Positioned(
                        bottom: 0,
                        left: 0,
                        child: CartBottom(),
                      );
                    },
                  ),
                ],
              );
            } else {
              return Text('加载汇总....');
            }
          },
        ));
  }

  Future<String> _getCartInfo(BuildContext context) async {
    await Provide.value<CartProvide>(context).getCartInfo();
    return 'end';
  }
}
