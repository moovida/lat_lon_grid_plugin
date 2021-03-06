import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:lat_lon_grid_plugin/lat_lon_grid_plugin.dart';
import 'package:latlong/latlong.dart';

void main() => runApp(MyApp());

/// Sample application
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lat lon grid example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

/// HomePage which shows the use of the plugin
class HomePage extends StatefulWidget {
  /// constructor for the HomePage widget
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MapController _mapController;
  String _sLatLonZoom = '';
  double _rotation = 0.0;

  void _updateRotation(double valRotation) {
    setState(() {
      _rotation = valRotation;
      _updateLabel();
    });
    _mapController.rotate(valRotation);
  }

  void _updateLabel() {
    if (_mapController != null) {
      String lat = _mapController.center.latitude.toStringAsFixed(3);
      String lon = _mapController.center.longitude.toStringAsFixed(3);
      String zoom = _mapController.zoom.toStringAsFixed(2);
      String rotation = _rotation.toStringAsFixed(0);

      // don't trigger rebuild while building aka. when the first build didn't finish yet
      if (_sLatLonZoom == '') {
        _sLatLonZoom = 'lat: $lat lon: $lon\nzoom: $zoom rotation: $rotation';
      } else {
        setState(() {
          _sLatLonZoom = 'lat: $lat lon: $lon\nzoom: $zoom rotation: $rotation';
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    // hacked together
    // https://stackoverflow.com/questions/49466556/flutter-run-method-on-widget-build-complete
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateLabel());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Example'),
        actions: <Widget>[
          SizedBox(
            height: 50.0,
            width: 250.0,
            child: Container(
              height: 80.0,
              color: Colors.blue,
              child: Column(
                children: <Widget>[
                  Text(
                    _sLatLonZoom,
                    style: TextStyle(color: Colors.white, fontSize: 17.0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: LatLng(37.7, 13.5),
              zoom: 7.0,
              onPositionChanged: (position, hasGesture) => _updateLabel(),
              plugins: [
                MapPluginLatLonGrid(),
              ],
            ),
            layers: [
              TileLayerOptions(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              MapPluginLatLonGridOptions(
                lineColor: Colors.black,
                textColor: Colors.white,
                lineWidth: 0.5,
                textBackgroundColor: Colors.black,
                showCardinalDirections: true,
                showCardinalDirectionsAsPrefix: false,
                textSize: 12.0,
                showLabels: true,
                rotateLonLabels: true,
                placeLabelsOnLines: true,
                offsetLonTextBottom: 20.0,
                offsetLatTextLeft: 20.0,
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 5.0, right: 5.0),
            child: Align(
              alignment: Alignment.topRight,
              child: SizedBox(
                height: 50.0,
                width: 200.0,
                child: Container(
                  color: Colors.blue,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      valueIndicatorTextStyle: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    child: Slider(
                      activeColor: Colors.white,
                      inactiveColor: Colors.grey,
                      value: _rotation,
                      min: 0.0,
                      max: 360.0,
                      divisions: 360,
                      onChanged: _updateRotation,
                      label: _rotation.toStringAsFixed(0),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
