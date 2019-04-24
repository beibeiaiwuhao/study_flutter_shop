import 'package:flutter/material.dart';
import '../service/service_method.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

import '../model/home_page_model.dart';

import '../routers/application.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String showText = '还没有开始请求数据';
  //火爆商品数据
  int page = 1;
  List<Map> hotGoodsList = [];
  HomePageModel homeModel = new HomePageModel();

  @override
  Widget build(BuildContext context) {
//列表的上拉加载的数据
    GlobalKey<RefreshFooterState> _footerKey =
        new GlobalKey<RefreshFooterState>();
    GlobalKey<RefreshHeaderState> _headerKey =
        new GlobalKey<RefreshHeaderState>();

    var formData = {"lon": '115.02932', "lat": "35.76189"};
    return Scaffold(
      appBar: AppBar(
        title: Text("百姓生活+"),
      ),
      body: FutureBuilder(
        future: request('homePageContent', formData: formData),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            var data = json.decode(snapshot.data.toString());
            homeModel = HomePageModel.fromJson(data);
            //顶部轮播组件数
            List<Slides> swiperDataList =
                homeModel.data != null ? homeModel.data.slides : [];
            //轮播图下面的导航图
            //类别表
            List<Category> navigatorList = homeModel.data.category;
            if (navigatorList.length > 10) {
              navigatorList.removeRange(10, navigatorList.length);
            }
            //推荐商品
            // List<Map> recommendList = homeModel.data.recommend;
            // recommendList.add(recommendList[0]);
            //楼层商品
            String floor1Title = homeModel.data.floor1Pic.pICTUREADDRESS;
            String floor2Title = homeModel.data.floor2Pic.pICTUREADDRESS;
            String floor3Title = homeModel.data.floor3Pic.pICTUREADDRESS;

            return EasyRefresh(
              refreshHeader: ClassicsHeader(
                key: _headerKey,
                bgColor: Colors.white,
                textColor: Colors.cyan,
                showMore: true,
                moreInfo: '下拉刷新',
              ),
              refreshFooter: ClassicsFooter(
                key: _footerKey,
                bgColor: Colors.white,
                textColor: Colors.cyan,
                showMore: true,
                noMoreText: '没有更多数据了',
                moreInfo: '加载中...',
                loadReadyText: '上拉加载',
              ),
              child: ListView(
                children: <Widget>[
                  //轮播图
                  SwiperDiy(
                    swiperDataList: swiperDataList,
                  ),
                  //轮播图下的导航
                  TopNavigator(
                    navigatorList: navigatorList,
                  ),
                  //广告页面
                  AdBanner(
                      advertesPicture:
                          homeModel.data.advertesPicture.pICTUREADDRESS),
                  //经理电话
                  LeaderPhone(
                    leaderImage: homeModel.data.shopInfo
                        .leaderImage, // data['data']['shopInfo']['leaderImage'],
                    leaderPhone: homeModel.data.shopInfo
                        .leaderPhone, // data['data']['shopInfo']['leaderPhone'],
                  ),
                  //商品推荐
                  Recommend(
                    recommendList: homeModel.data.recommend,
                  ),
                  //楼层商品的展示
                  FloorTitle(picture_address: floor1Title),
                  FloorContent(floorGoodsList: homeModel.data.floor1),
                  FloorTitle(picture_address: floor2Title),
                  FloorContent(floorGoodsList: homeModel.data.floor2),
                  FloorTitle(picture_address: floor3Title),
                  FloorContent(floorGoodsList: homeModel.data.floor3),
                  //火爆商品
                  _hotGoods(),
                ],
              ),
              // onRefresh: () async {
              //   print("下拉开始刷新");
              // },
              loadMore: () async {
                print("开始加载更多....");
                var formData = {'page': page};
                await request('homePageBelowConten', formData: formData)
                    .then((val) {
                  var data = json.decode(val.toString());
                  List<Map> newGoodList = (data['data'] as List).cast();
                  setState(() {
                    hotGoodsList.addAll(newGoodList);
                    page++;
                  });
                });
              },
            );
          } else {
            return Center(
              child: Text('加载中'),
            );
          }
        },
      ),
    );
  }

/**
 * 火爆专区的商品
 *
 *  */
  @override
  Widget _hotGoods() {
    return Container(
      child: Column(
        children: <Widget>[hotTitle, _wrapList()],
      ),
    );
  }

//火爆专区标题
  Widget hotTitle = Container(
    margin: EdgeInsets.only(top: 10.0),
    padding: EdgeInsets.all(5.0),
    alignment: Alignment.center,
    decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(width: 0.5, color: Colors.black12))),
    child: Text("火爆专区"),
  );

  //火爆专区子项
  Widget _wrapList() {
    if (hotGoodsList.length != 0) {
      List<Widget> listWidget = hotGoodsList.map((val) {
        return InkWell(
          onTap: () {
            Application.router
                .navigateTo(context, "/detail?id=${val['goodsId']}");
          },
          child: Container(
            width: ScreenUtil().setWidth(372),
            color: Colors.white,
            padding: EdgeInsets.all(5.0),
            margin: EdgeInsets.only(bottom: 3.0),
            child: Column(
              children: <Widget>[
                Image.network(
                  val['image'],
                  width: ScreenUtil().setWidth(375),
                ),
                Text(
                  val['name'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.pink, fontSize: ScreenUtil().setSp(26)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("¥${val['mallPrice']}"),
                    Text("¥${val['price']}",
                        style: TextStyle(
                            color: Colors.black26,
                            decoration: TextDecoration.lineThrough))
                  ],
                )
              ],
            ),
          ),
        );
      }).toList();
      return Wrap(
        spacing: 2,
        children: listWidget,
      );
    } else {
      return Text('');
    }
  }

//获取火爆专区数据
  void _getHotGoods() {
    var formData = {'page': page};
    request('homePageBelowConten', formData: formData).then((val) {
      var data = json.decode(val.toString());
      List<Map> newGoodsList = (data['data'] as List).cast();
      setState(() {
        hotGoodsList.addAll(newGoodsList);
        page++;
      });
      print(val);
    });
  }
}

/**
 * 首页轮播组件
 */
class SwiperDiy extends StatelessWidget {
  final List swiperDataList;
  SwiperDiy({this.swiperDataList});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(333),
      width: ScreenUtil().setWidth(750),
      child: Swiper(
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () {
              Application.router.navigateTo(
                  context, "/detail?id=${swiperDataList[index].goodsId}");
            },
            child: Image.network(
              "${swiperDataList[index].image}",
              fit: BoxFit.fill,
            ),
          );
        },
        itemCount: swiperDataList.length,
        pagination: new SwiperPagination(),
        autoplay: true,
      ),
    );
  }
}

/**
 * 首页导航区域
 */
class TopNavigator extends StatelessWidget {
  final List navigatorList;
  TopNavigator({Key key, this.navigatorList}) : super(key: key);

  Widget _gridViewItemUI(BuildContext context, item) {
    return InkWell(
      child: Column(
        children: <Widget>[
          Image.network(
            item.image,
            width: ScreenUtil().setWidth(95),
          ),
          Text(
            item.mallCategoryName,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(320),
      padding: EdgeInsets.all(3),
      child: GridView.count(
        crossAxisCount: 5,
        physics: new NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(4),
        children: navigatorList.map((item) {
          return _gridViewItemUI(context, item);
        }).toList(),
      ),
    );
  }
}

/**
 * 广告页面
 */
class AdBanner extends StatelessWidget {
  final String advertesPicture;

  AdBanner({Key key, this.advertesPicture}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image.network(advertesPicture),
    );
  }
}

/**
 * 编写店长电话模块
 */
class LeaderPhone extends StatelessWidget {
  final String leaderImage; //店长图片
  final String leaderPhone; //店长电话

  LeaderPhone({Key key, this.leaderPhone, this.leaderImage});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
        onTap: _launchURL, //拨打电话
        child: Image.network(leaderImage),
      ),
    );
  }

  void _launchURL() async {
    String url = 'tel:' + '18537840436';
    print(url);
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch';
    }
  }
}

/**
 * 商品推荐
 */
class Recommend extends StatelessWidget {
  final List recommendList;

  Recommend({Key key, this.recommendList}) : super(key: key);

  //推荐商品标题
  Widget _titleWidget() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.fromLTRB(10.0, 2.0, 0, 5.0),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
              bottom: BorderSide(width: 1, color: Colors.black12),
              top: BorderSide(width: 1, color: Colors.black12))),
      child: Text(
        "商品推荐",
        style: TextStyle(color: Colors.pink),
      ),
    );
  }

  //推荐商品单独便携
  Widget _item(BuildContext context, index) {
    return InkWell(
      onTap: () {
        Application.router
            .navigateTo(context, "/detail?id=${recommendList[index].goodsId}");
      },
      child: Container(
        height: ScreenUtil().setHeight(330),
        width: ScreenUtil().setWidth(250),
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(left: BorderSide(width: 1, color: Colors.black12))),
        child: Column(
          children: <Widget>[
            Image.network(recommendList[index].image),
            Text("¥${recommendList[index].mallPrice}"),
            Text(
              "¥${recommendList[index].price}",
              style: TextStyle(
                  decoration: TextDecoration.lineThrough, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  //横向列表组件
  Widget _recommedList() {
    return Container(
      height: ScreenUtil().setHeight(330),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recommendList.length,
        itemBuilder: (context, index) {
          return _item(context, index);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(400),
      margin: EdgeInsets.only(top: 10.0),
      child: Column(
        children: <Widget>[_titleWidget(), _recommedList()],
      ),
    );
  }
}

/**
 * 楼层区域的编写
 */
class FloorTitle extends StatelessWidget {
  final String picture_address; //图片地址

  FloorTitle({Key key, this.picture_address}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Image.network(picture_address),
    );
  }
}

class FloorContent extends StatelessWidget {
  final List floorGoodsList;

  FloorContent({Key key, this.floorGoodsList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[_firstRow(context), _otherGoods(context)],
      ),
    );
  }

/**
 * 上半部分布局
 * 一张大图片 ，两张小图片
 */
  Widget _firstRow(BuildContext context) {
    return Row(
      children: <Widget>[
        _goodsItem(context, floorGoodsList[0]),
        Column(
          children: <Widget>[
            _goodsItem(context, floorGoodsList[1]),
            _goodsItem(context, floorGoodsList[2]),
          ],
        )
      ],
    );
  }

/**
 * 下半部分布局
 * 两张小图片
 */
  Widget _otherGoods(BuildContext context) {
    return Row(
      children: <Widget>[
        _goodsItem(context, floorGoodsList[3]),
        _goodsItem(context, floorGoodsList[4])
      ],
    );
  }

  Widget _goodsItem(BuildContext context, Floor goods) {
    return Container(
      width: ScreenUtil().setWidth(375),
      child: InkWell(
        onTap: () {
          Application.router.navigateTo(context, "/detail?id=${goods.goodsId}");
        },
        child: Image.network(goods.image),
      ),
    );
  }
}
