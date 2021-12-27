import 'dart:developer';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:q_book_finder/BookStoreScreen.dart';
import 'package:q_book_finder/BookPage.dart';
import 'package:q_book_finder/LocationUpdateCallback.dart';
import 'dart:async';
import 'MapScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  State<StatefulWidget> createState() => myAppState();
}

class myAppState extends State<MyApp> {
  int pageIndex = 0;
  onBottomItemTaped(int index) {
    setState(() {
      pageIndex = index;
    });
  }
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  var pages =  <Widget>[
    MapSample(_kGooglePlex),
    BookStoreScreen(_kGooglePlex),
    BookPage()
  ];
  LatLng? currentLocation;
  @override
  void initState() {
  const indexes = <int>[0,1];
      for(var index in indexes){
        LocationUpdateCallback instance = (pages[index] as LocationUpdateCallback);
        instance.getLocation = (Function? unlocknotifier) async=> (currentLocation ?? await loadLocation(unlocknotifier));
      }
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primaryColor: Colors.brown,
        primarySwatch: Colors.orange,
      ),
      home: Scaffold(
        body: IndexedStack(children: pages,index:pageIndex),
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: pageIndex,
            onTap: onBottomItemTaped,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Book Store'),
              BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Books'),
            ]),
      ),
    );
  }
  
  bool loadLocationLocked = false;
  Function? unlockNotifier;
   loadLocation(Function? unlockNotifier) async {
   if(loadLocationLocked){
      this.unlockNotifier = unlockNotifier;
      return "locked";
   }
   loadLocationLocked = true;
    Location locationService = Location();
    var hasPermission = await locationService.hasPermission();
    if (hasPermission != PermissionStatus.granted) {
      hasPermission = await locationService.requestPermission();
      if (hasPermission != PermissionStatus.granted) {
        return null;
      }
    }
    var isRequestEnabled = await locationService.serviceEnabled();
    if (!isRequestEnabled) {
      isRequestEnabled = await locationService.requestService();
      if (!isRequestEnabled) {
        return null;
      }
    }
    var location = await locationService.getLocation();
    currentLocation = LatLng(location.latitude!,location.longitude!);
    loadLocationLocked = false;
    if(this.unlockNotifier!=null){
      this.unlockNotifier!();
    }
    return currentLocation;
  }
}
