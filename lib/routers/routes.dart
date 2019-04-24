//路由的总体配置
import 'package:flutter/material.dart';
import './router_handler.dart';
import 'package:fluro/fluro.dart';

class Routes {
  static String root = '/';
  static String detailPage = '/detail';
  static void configureRoutes(Router router) {
    router.notFoundHandler = new Handler(
      //找不到路由
      handlerFunc: (BuildContext context,Map<String,List<String>> params) {
        print('error ====> route was not found!!!');
      });
    
      //router.define作用相当于注册页面，
      //商品详情界面
      router.define(detailPage,handler: detailHandler);
    

  }
}