import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:q_book_finder/LocationUpdateCallback.dart';

import 'searchbar.dart';

class MapSample extends StatefulWidget with LocationUpdateCallback{
  final CameraPosition initialPosition;
  MapSample(this.initialPosition,{Key? key}) :super(key: key);

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  GoogleMapController? _controller;
  Set<Marker> markers = {};
  @override
  void initState() {
    super.initState();
  }


  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: widget.initialPosition,
            markers: markers,
            onMapCreated: (GoogleMapController controller) async {
              _controller = controller;
              LatLng? position = (await widget.getLocation(null)) as LatLng?;
              if(position!=null){
                  _controller!.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
                    target: position,
                    zoom: 17.0,
                  )));
                  setState(() {
                    markers.add( Marker(markerId: const MarkerId('Home'),position: position));
                  });
              }
            },
          ),
          Align( alignment: Alignment.topCenter,child: buildFloatingSearchBar())
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: ()=>{},
        label: const Text('To the lake!'),
        icon: const Icon(Icons.directions_boat),
      ),
    );
  }
}