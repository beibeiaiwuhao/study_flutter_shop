import 'package:flutter/material.dart';
import '../service/service_method.dart';
import 'dart:convert';
import '../model/category_model.dart';
import '../model/category_goods_list_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provide/provide.dart';
import '../provide/child_category.dart';
import '../provide/category_goods_list.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CategoryPage extends StatefulWidget {
  final Widget child;

  CategoryPage({this.child});

  @override
  _CategoryPageState createState() => new _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('商品分类'),
      ),
      body: Container(
          child: Row(children: <Widget>[
        LeftCategoryNav(),
        Column(
          children: <Widget>[RightCategoryNav(), CategoryGoodsList()],
        ) //
      ])),
    );
  }
}

/**
 * 创建左侧动态菜单
 */
class LeftCategoryNav extends StatefulWidget {
  _LeftCategoryNavState createState() => new _LeftCategoryNavState();
}

class _LeftCategoryNavState extends State<LeftCategoryNav> {
  List list = [];
  var listIndex = 0;

  void initState() {
    super.initState();
    _getCategoryData(); //得到左侧数据
    _getMallGoods(); //得到右侧第一栏数据
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil().setWidth(180),
      decoration: BoxDecoration(
          border: Border(right: BorderSide(width: 1, color: Colors.black12))),
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          return _leftInWel(index);
        },
      ),
    );
  }

  /**
   * 获取分类数据
   */
  void _getCategoryData() async {
    await request(
      'getCategory',
    ).then((val) {
      var data = json.decode(val.toString());
      CategoryModel categoy = CategoryModel.fromJson(data);
      setState(() {
        list = categoy.data;
      });
      //给第一次请求数据的时候，默认给第一个分类下的数据
      Provide.value<ChildCategory>(context)
          .getChildCategory(list[0].bxMallSubDto, list[0].mallCategoryId);
    });
  }

// 请求右侧数据
  void _getMallGoods({String categoryId}) {
    var data = {
      'categoryId': categoryId == null ? '4' : categoryId,
      'categorySubId': '',
      'page': 1
    };

    request('getMallGoods', formData: data).then((val) {
      var data = json.decode(val.toString());
      CategoryGoodsListModel goodsList = CategoryGoodsListModel.fromJson(data);
      Provide.value<CategoryGoodsListProvide>(context)
          .getGoodsList(goodsList.data);
    });
  }

  //创建列表单元格
  Widget _leftInWel(int index) {
    bool isClick = false;
    isClick = listIndex == index ? true : false;
    return InkWell(
      onTap: () {
        setState(() {
          listIndex = index;
        });

        //大类下面的小类
        var childList = list[index].bxMallSubDto;
        //大类的id
        var categoryId = list[index].mallCategoryId;

        Provide.value<ChildCategory>(context)
            .getChildCategory(childList, categoryId);
        // 发送右侧商品请求
        _getMallGoods(categoryId: categoryId);
      },
      child: Container(
        height: ScreenUtil().setHeight(100),
        padding: EdgeInsets.only(left: 10, top: 20),
        decoration: BoxDecoration(
            color: isClick ? Color.fromRGBO(236, 238, 239, 1.0) : Colors.white,
            border:
                Border(bottom: BorderSide(width: 1, color: Colors.black12))),
        child: Text(
          list[index].mallCategoryName,
          style: TextStyle(fontSize: ScreenUtil().setSp(28)),
        ),
      ),
    );
  }
}

//右侧动态小类列表
class RightCategoryNav extends StatefulWidget {
  @override
  _RightCategoryNavState createState() => new _RightCategoryNavState();
}

class _RightCategoryNavState extends State<RightCategoryNav> {
  //获取商品列表的数据
  void _getGoodsList({String categorySubId}) async {
    var formData = {
      'categoryId': Provide.value<ChildCategory>(context).categoryId,
      'categorySubId': categorySubId,
      'page': 1
    };
    await request('getMallGoods', formData: formData).then((val) {
      var data = json.decode(val.toString());
      CategoryGoodsListModel goodsList = CategoryGoodsListModel.fromJson(data);
      //非空判断
      print(goodsList.data);
      if (goodsList.data == null) {
        Provide.value<CategoryGoodsListProvide>(context).getGoodsList([]);
      } else {
        Provide.value<CategoryGoodsListProvide>(context)
            .getGoodsList(goodsList.data);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Provide<ChildCategory>(
      builder: (context, child, childCategory) {
        return Container(
          child: Container(
            height: ScreenUtil().setHeight(80),
            width: ScreenUtil().setWidth(570),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                    bottom: BorderSide(width: 1, color: Colors.black12))),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: childCategory.childCategoryList.length,
              itemBuilder: (context, index) {
                return _rightInkWell(
                    index, childCategory.childCategoryList[index]);
              },
            ),
          ),
        );
      },
    );
  }

  //右边listView的单元格
  Widget _rightInkWell(int index, BxMallSubDto item) {
    bool isCheck = false;
    isCheck = (index == Provide.value<ChildCategory>(context).childIndex)
        ? true
        : false;

    return InkWell(
      onTap: () {
        Provide.value<ChildCategory>(context)
            .changeChildIndex(index, item.mallSubId);
        _getGoodsList(categorySubId: item.mallSubId);
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
        child: Text(item.mallSubName,
            style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
                color: isCheck ? Colors.pink : Colors.black)),
      ),
    );
  }
}

/**
 * 商品列表 可以上拉加载
 */
class CategoryGoodsList extends StatefulWidget {
  @override
  _CategoryGoodsListState createState() => new _CategoryGoodsListState();
}

class _CategoryGoodsListState extends State<CategoryGoodsList> {
  //上拉加载更多
  void _getMoreList() {
    //page + 1
    Provide.value<ChildCategory>(context).addPage();
    var formData = {
      'categoryId': Provide.value<ChildCategory>(context).categoryId,
      'categorySubId': Provide.value<ChildCategory>(context).subId,
      'page': Provide.value<ChildCategory>(context).page
    };
    request('getMallGoods', formData: formData).then((val) {
      var data = json.decode(val.toString());
      CategoryGoodsListModel goodsList = CategoryGoodsListModel.fromJson(data);
      if (goodsList.data == null) {
        Provide.value<ChildCategory>(context).changeNoMoreText('没有更多了');
        Fluttertoast.showToast(
          msg: '已经到底了',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.pink,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        Provide.value<CategoryGoodsListProvide>(context)
            .addGoodsList(goodsList.data);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //列表的上拉加载的数�� (初始化必须放在build 方法中)
    GlobalKey<RefreshFooterState> _footerKey =
        new GlobalKey<RefreshFooterState>();

    var scrollController = new ScrollController();

    return Provide<CategoryGoodsListProvide>(
      builder: (contex, child, data) {
        try {
          if (Provide.value<ChildCategory>(context).page == 1) {
            scrollController.jumpTo(0.0);
          }
        } catch (e) {
          print('进入页面第一次初始化:${e}');
        }

        if (data.goodsList.length > 0) {
          return Expanded(
            child: Container(
                width: ScreenUtil().setWidth(570),
                child: Container(
                  width: ScreenUtil().setWidth(570),
                  child: EasyRefresh(
                    refreshFooter: ClassicsFooter(
                      key: _footerKey,
                      bgColor: Colors.white,
                      textColor: Colors.pink,
                      moreInfoColor: Colors.pink,
                      showMore: true,
                      noMoreText:
                          Provide.value<ChildCategory>(context).noMoreText,
                      moreInfo: '加载中',
                      loadReadyText: '上拉加载',
                    ),
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: data.goodsList.length,
                      itemBuilder: (context, index) {
                        return _listWidget(data.goodsList, index);
                      },
                    ),
                    loadMore: () async {
                      _getMoreList();
                    },
                  ),
                )),
          );
        } else {
          return Text('暂时没有数据');
        }
      },
    );
  }

  //商品列表单元格 组件封装
  //图片
  Widget _goodsImage(List newList, int index) {
    return Container(
      width: ScreenUtil().setWidth(200),
      child: Image.network(newList[index].image),
    );
  }

  //商品名字
  Widget _goodsName(List newList, int index) {
    return Container(
      padding: EdgeInsets.all(5.0),
      width: ScreenUtil().setWidth(370),
      child: Text(newList[index].goodsName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: ScreenUtil().setSp(28))),
    );
  }

  //商品价钱
  Widget _goodsPrice(List newList, int index) {
    return Container(
      margin: EdgeInsets.only(top: 20.0),
      width: ScreenUtil().setWidth(370),
      child: Row(
        children: <Widget>[
          Text(
            '价格:¥${newList[index].presentPrice}',
            style:
                TextStyle(color: Colors.pink, fontSize: ScreenUtil().setSp(30)),
          ),
          Text(
            '¥${newList[index].oriPrice}',
            style: TextStyle(
                color: Colors.grey, decoration: TextDecoration.lineThrough),
          ),
        ],
      ),
    );
  }

  //
  Widget _listWidget(List newList, int index) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
        decoration: BoxDecoration(
            color: Colors.white,
            border:
                Border(bottom: BorderSide(width: 1.0, color: Colors.black12))),
        child: Row(
          children: <Widget>[
            _goodsImage(newList, index),
            Column(
              children: <Widget>[
                _goodsName(newList, index),
                _goodsPrice(newList, index)
              ],
            )
          ],
        ),
      ),
    );
  }
}
