import 'package:flutter/material.dart';
import 'package:amap_base/amap_base.dart';

class GDMap extends StatelessWidget {
  GDMap();

  @override
  Widget build(BuildContext context) {
    AMapController _controller;
    return Scaffold(
        appBar: AppBar(
          title: Text('地图'),
        ),
        body: AMapView(
          onAMapViewCreated: (controller) {
            _controller = controller;
          },
          amapOptions: AMapOptions(
              compassEnabled: false,
              zoomControlsEnabled: true,
              logoPosition: LOGO_POSITION_BOTTOM_CENTER,
              camera: CameraPosition(
                  target: LatLng(41.851827, 112.801637), zoom: 4)),
        ));
  }
}
