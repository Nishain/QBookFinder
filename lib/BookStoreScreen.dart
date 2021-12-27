import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:q_book_finder/LocationUpdateCallback.dart';
import 'package:q_book_finder/compoenents/MaterialTextField.dart';

class BookStoreScreen extends StatefulWidget with LocationUpdateCallback {
  final CameraPosition initialPosition;
  BookStoreScreen(this.initialPosition, {Key? key}) : super(key: key);

  @override
  State<BookStoreScreen> createState() => BookStoreState();
}

class BookStoreState extends State<BookStoreScreen> {
  String? location;
  GoogleMapController? controller;

  @override
  void initState() {
    super.initState();
  }
  updateMapToCurrentLocation({Function? notifier}) async{
    if(notifier!=null){
    }
    dynamic result = (await widget.getLocation(notifier));
    if(result == 'locked'){
      return;
    }
    LatLng? position = result as LatLng?;
    if (position != null) {
      controller!.animateCamera(
          CameraUpdate.newCameraPosition(CameraPosition(
        target: position,
        zoom: 17.0,
      )));
      setState(() {
        markers.add(Marker(
            markerId: const MarkerId('Shop'),
            position: position));
      });
    }
  }
  Set<Marker> markers = {};
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: <Widget>[
              const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    "Create a Book Store",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  )),
              MaterialTextField("Name of the shop"),
              MaterialTextField("Shop Owner"),
              // Row(children: [
              //   Expanded(
              //       child: MaterialTextField("Location",
              //           readOnly: true, initialValue: location),
              //       flex: 2), //
              //   Expanded(
              //       child: Padding(
              //           padding: const EdgeInsets.only(left: 10),
              //           child: ElevatedButton(
              //               onPressed: () => {},
              //               child: const Padding(
              //                   padding: EdgeInsets.all(10),
              //                   child: Text("Choose Manually",
              //                       textAlign: TextAlign.center)))))
              // ]),
              ButtonBar(
                alignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(onPressed: () => {}, child: const Text("Create",textAlign: TextAlign.center,)),
                  ElevatedButton(onPressed: () => {}, child: const Text("Update",textAlign: TextAlign.center,))
                ],
              ),
              Expanded(
                child: Stack(children: [
                  GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: widget.initialPosition,
                    markers: markers,
                    onMapCreated: (GoogleMapController controller) async {
                      
                      this.controller = controller;
                      log("however called here");
                      updateMapToCurrentLocation(notifier: updateMapToCurrentLocation);
                    },
                  ),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: ElevatedButton(
                              onPressed: () => {},
                              child: const Text("Choose Here",
                                  textAlign: TextAlign.center))))
                ]),
              )
            ],
          )),
    );
  }
}
