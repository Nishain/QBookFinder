import 'dart:developer';

import 'package:google_maps_flutter/google_maps_flutter.dart';

  class LocationUpdateCallback{
  Function(LatLng)? updateLocation;
   LatLng? currentLocation;
  passStateUpdater(Function(LatLng) setStateFunction, GoogleMapController? controller){
    if(currentLocation != null){
      setStateFunction(currentLocation!);
    }
    updateLocation = (LatLng position)=>{currentLocation = position,
    setStateFunction(position),
    if(controller!=null)
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: currentLocation!,
            zoom: 17.0,
          )))
    else
      log('controller is not intialized yet!')
          };
          
  }
  late Function(Function? unlockNotifier) getLocation;
}