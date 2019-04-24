import 'package:flutter/material.dart';
import 'pages/index_page.dart';
// 状态管理
import 'package:provide/provide.dart';
import './provide/child_category.dart';
import './provide/category_goods_list.dart';
import './provide/details_info.dart';
import './provide/cart.dart';
import './provide/current_index.dart';
//路由管理
import 'package:fluro/fluro.dart';
import './routers/routes.dart';
import './routers/application.dart';


void main() {
  var childCategory = ChildCategory();
  var goodsList = CategoryGoodsListProvide();
  var detailInfo = DetailsInfoProvide();
  var cart = CartProvide();
  var currentIndex = CurrentIndexProvide();

  var providers = Providers();
  providers
    ..provide(Provider<ChildCategory>.value(childCategory))
    ..provide(Provider<CategoryGoodsListProvide>.value(goodsList))
    ..provide(Provider<DetailsInfoProvide>.value(detailInfo))
    ..provide(Provider<CartProvide>.value(cart))
    ..provide(Provider<CurrentIndexProvide>.value(currentIndex));

  runApp(ProviderNode(
    child: MyApp(),
    providers: providers,
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    final router = Router();
    Routes.configureRoutes(router);
    Application.router = router;

    return Container(
      child: MaterialApp(
          title: '百姓生活+',
          //去除右上角的debug标签
          debugShowCheckedModeBanner: false,
          onGenerateRoute: Application.router.generator,
          theme: ThemeData(primarySwatch: Colors.blue),
          home: IndexPage()),
    );
  }
}
