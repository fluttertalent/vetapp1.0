import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class LocationScreen extends StatefulWidget {
  @override
  _LocationChooserState createState() => _LocationChooserState();
}

class _LocationChooserState extends State<LocationScreen> {
  Completer<GoogleMapController> _controller = Completer();
  static const LatLng _center = LatLng(45.343434, -122.545454);
  final Set<Marker> _markers = {};
  LatLng _lastMapPosition = _center;
  MapType _currentMapType = MapType.normal;
  String _title = "";
  String _detail = "";
  var _userLocation;
  bool _userLocCatched = false;
  late LatLng pickedPoint;
  bool _isPicked = false;
  late TextEditingController _lane1;
  Uint8List? imageBytes;

  Future<bool> _initLocationService() async {
    var location = Location();

    if (!await location.serviceEnabled()) {
      if (!await location.requestService()) {
        return  false;
      }
    }
    var permission = await location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await location.requestPermission();
      if (permission != PermissionStatus.granted) {
        return false;
      }
    }
    _userLocation = await location.getLocation();

    setLoc();
    return true;
  }
  void setLoc(){
    setState(() {
      _userLocCatched = true;
      _markers.add(Marker(
          markerId: MarkerId(_userLocation.toString()),
          position: LatLng(_userLocation.latitude,_userLocation.longitude),
          infoWindow: InfoWindow(title: _title, snippet: _detail),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)));
    });
  }
  @override
  void initState() {
    super.initState();
    _lane1 = TextEditingController();
    _initLocationService();
  }

  void takeSnapShot() async {
    GoogleMapController controller = await _controller.future;
    Future<void>.delayed(const Duration(milliseconds: 1000), () async {
      imageBytes = await controller.takeSnapshot();
      setState(() {});
    });
  }
  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;

    return
      Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            _userLocCatched?
            GoogleMap(
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
              onMapCreated: _onMapCreated,
              initialCameraPosition:
              CameraPosition(target: LatLng(_userLocation!.latitude, _userLocation!.longitude), zoom: 16),
              markers: _markers,
              mapType: _currentMapType,
              onCameraMove: _onCameraMove,
              onTap: _handleTap,
            ):Container(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.topRight,
                child: Column(
                  children: <Widget>[
                    FloatingActionButton(
                      heroTag: FontAwesomeIcons.map,
                      onPressed:  _onMapTypeButtonPressed,
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      backgroundColor: Colors.white,
                      child: const Icon(
                        FontAwesomeIcons.map,
                        size: 16,
                        color: Colors.brown,
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    FloatingActionButton(
                      heroTag: FontAwesomeIcons.mapMarker,
                      onPressed:  _onAddMarkerButtonPressed,
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      backgroundColor: Colors.white,
                      child: const Icon(
                        FontAwesomeIcons.mapMarker,
                        size: 16,
                        color: Colors.brown,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    FloatingActionButton(
                      heroTag: FontAwesomeIcons.mapPin,
                      onPressed:  _getUserLocation,
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      backgroundColor: Colors.white,
                      child: const Icon(
                        FontAwesomeIcons.mapPin,
                        size: 16,
                        color: Colors.brown,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child:Align(
               alignment: Alignment.bottomCenter,
               child:
               Container(
                  width:MediaQuery.of(context).size.width*0.5,
                  height: MediaQuery.of(context).size.height*0.06,
                  margin: const EdgeInsets.only(top:10,bottom: 20),
                  child:ElevatedButton(
                    style:ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(244,115,32,1),
                      textStyle: const TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                        side: const BorderSide(color: Color.fromRGBO(244,115,32,1)),
                      ),
                    ),
                    onPressed: () async {
                      if(_isPicked) {
                        takeSnapShot();
                        Navigator.pop(
                        context,
                        pickedPoint
                      );
                      } else{
                        Fluttertoast.showToast(
                          msg: "You must select the location.",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.TOP_LEFT,
                          timeInSecForIosWeb: 1,
                          backgroundColor: const Color.fromRGBO(50, 50, 50, 1),
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      }
                    },
                child: const Text('OK', style: TextStyle(fontSize: 16.0, fontFamily: 'Montserrat-Bold', fontWeight: FontWeight.w700)),
              ),
            ),
            ),
            ),
          ],
        ),
        //      floatingActionButton: FloatingActionButton.extended(
        //        onPressed: _goToTheLake,
        //        label: Text('To the lake!'),
        //        icon: Icon(Icons.directions_boat),
        //      ),
      );

  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  _onAddMarkerButtonPressed() {
    _markers.clear();
    setState(() {
      _markers.add(Marker(
          markerId: MarkerId(_userLocation.toString()),
          position: LatLng(_userLocation.latitude,_userLocation.longitude),
          infoWindow: InfoWindow(title: _title, snippet: _detail),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)));

      _markers.add(Marker(
          markerId: MarkerId(_lastMapPosition.toString()),
          position: _lastMapPosition,
          infoWindow: InfoWindow(title: _title, snippet: _detail),
          icon: BitmapDescriptor.defaultMarker));
    });
  }

  _handleTap(LatLng point) {
    _markers.clear();
    setState(() async {
      pickedPoint = point;
      _isPicked = true;
      Future<BitmapDescriptor> _buildMarkerIcon(String pathImage) async {
        // Fetch the PNG
        Image _image = await Image.network(pathImage);

        // Encode the image as a list of ints
        List<int> list = utf8.encode(_image.toString());

        // Convert the int list into an unsigned 8-bit bytelist
        Uint8List bytes = Uint8List.fromList(list);

        // And construct the BitmapDescriptor from the bytelist
        BitmapDescriptor _bitmapDescriptor = BitmapDescriptor.fromBytes(bytes);

        // And return the product
        return _bitmapDescriptor;
      }

      _markers.add(Marker(
          markerId: MarkerId(_userLocation.toString()),
          position: LatLng(_userLocation.latitude,_userLocation.longitude),
          infoWindow: InfoWindow(title: _title, snippet: _detail),
          icon: await _buildMarkerIcon('https://firebasestorage.googleapis.com/v0/b/incident-responder-e51aa.appspot.com/o/users%2FIG6dWdFDwnaDLygd5K0flZFKoRt2%2Fuploads%2F1672848874212796.jpg?alt=media&token=bfca3d75-46a5-416d-ac8b-4029c4713d68')));

      _markers.add(Marker(
        markerId: MarkerId(point.toString()),
        position: point,
        infoWindow: InfoWindow(title: _title, snippet: _detail),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));
    });
  }

  _getUserLocation() async {
    // Position position = await Geolocator
    //     .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    var location = Location();

    if (!await location.serviceEnabled()) {
      if (!await location.requestService()) {
        return  false;
      }
    }
    var permission = await location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await location.requestPermission();
      if (permission != PermissionStatus.granted) {
        return false;
      }
    }
    var _userLocation = await location.getLocation();

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(_userLocation.latitude!, _userLocation.longitude!), zoom: 16),
      ),
    );
    setState(() {
      _lane1.text = "$_title   $_detail";
    });
  }
}