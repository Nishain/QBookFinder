import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:q_book_finder/LocationUpdateCallback.dart';
import 'package:q_book_finder/compoenents/MaterialTextField.dart';
import 'package:q_book_finder/compoenents/RedButton.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class BookStoreScreen extends StatefulWidget with LocationUpdateCallback {
  final CameraPosition initialPosition;
  BookStoreScreen(this.initialPosition, {Key? key}) : super(key: key);

  @override
  State<BookStoreScreen> createState() => BookStoreState();
}

enum fieldNames { shopName, shopOwner,isbnBookOne }

class BookStoreState extends State<BookStoreScreen> {
  GoogleMapController? controller;
  String? shopID;
  LatLng? currentLocation;
  late String endpoint;
  final String SHOP_ID_KEY = "shopID";
  late SharedPreferences sharedPreferences;
  @override
  void initState() {
    super.initState();
    dotenv.load(fileName: '.env').then((value) => {
          endpoint = "http://${dotenv.env['localendpoint']!}:${dotenv.env['port']!}",
          log('LOCAL ENDPOINT $endpoint'),
          SharedPreferences.getInstance().then((sharedPreference) {
            sharedPreferences = sharedPreference;
            shopID = sharedPreference.getString(SHOP_ID_KEY);
            if (shopID != null) {
              http.get(Uri.parse('$endpoint/bookStore/$shopID'))
                  .then((result) {
                dynamic data = jsonDecode(result.body);
                fieldInputs[fieldNames.shopName]!.controller.text =
                    data['name'] as String;
                fieldInputs[fieldNames.shopOwner]!.controller.text =
                    data['shopOwner'] as String;
                currentLocation = LatLng(data['location'][0], data['location'][1]);    
                if(controller!=null){
                  onGoogleMapTapped(currentLocation!);
                  controller!.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
                    target: currentLocation!,
                    zoom: 17.0,
                  )));
                }
              });
              
            }
          })
        });
  }

  showDeleteConfirmationMessage() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text("Are you sure?"),
              content: const Text(
                  "Do you want to delete your shop? this action is unreversible. Continue?"),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Cancel",
                        style: TextStyle(color: Colors.red))),
                ElevatedButton(
                    onPressed: () => {resolveAction('delete'),Navigator.of(context).pop()},
                    child: const Text("Delete",
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(primary: Colors.red))
              ],
            ));
  }

  resolveAction(action)async {
    setState(() {
      updateMode = (action == 'update');
    });
    if (action == 'create') {
      Map<fieldNames, String> data = {};
      data.addAll(fieldInputs
          .map((key, value) => MapEntry(key, value.controller.text)));
      String postBody = jsonEncode({
        'name':fieldInputs[fieldNames.shopName]!.controller.text,
        'shopOwner':fieldInputs[fieldNames.shopOwner]!.controller.text,
        'location':[currentLocation!.latitude,currentLocation!.longitude]
      });
      http.Response response = await http.post(
        Uri.parse("$endpoint/BookStore/"),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body:postBody
      );    
      setState(() {
        shopID = jsonDecode(response.body)['_id'];
        if(shopID!=null){
          sharedPreferences.setString(SHOP_ID_KEY, shopID!);  
        }
      });
    }else if(action == 'commitUpdate'){
      String updateBody = jsonEncode({
        'name':fieldInputs[fieldNames.shopName]!.controller.text,
        'shopOwner':fieldInputs[fieldNames.shopOwner]!.controller.text,
        'location':[currentLocation!.latitude,currentLocation!.longitude]
      });
       http.Response response = await http.put(
        Uri.parse("$endpoint/BookStore/$shopID/nothing"),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body:updateBody
      );    
      if(jsonDecode(response.body)['updatedCount'] > 0){
        showToast("Have successfully updated");
      }
    }
    else if(action == 'add book'){
      String putBody = jsonEncode({'books':[fieldInputs[fieldNames.isbnBookOne]!.controller.text]});
      http.Response response = await http.put(
        Uri.parse("$endpoint/BookStore/$shopID/add"),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: putBody
      );
      showToast("Updated count ${jsonDecode(response.body)['updatedCount']}");
    }else if(action == 'delete'){
      http.Response response =  await http.delete(
        Uri.parse("$endpoint/BookStore/$shopID"),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: "{}"
      );
      log(jsonDecode(response.body).toString());
      if(jsonDecode(response.body)['deleteCount'] == 1){
        showToast("successfully deleted");
        setState(() {
          sharedPreferences.remove(SHOP_ID_KEY);
          shopID = null;
          for (var field in fieldInputs.values) {
            field.controller.clear();
           }
        });
        currentLocation = null;
        updateMapToCurrentLocation();
      }
    }
  }
  showToast(String message){
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Theme.of(context).primaryColor,
        textColor: Colors.black,
        fontSize: 16.0
    );
  }
  String? name, ownerName, isbn;
  updateMapToCurrentLocation({Function? notifier}) async {
    if(currentLocation!=null){
      onGoogleMapTapped(currentLocation!);
      return;
    }
    if (notifier != null) {}
    dynamic result = (await widget.getLocation(notifier));
    if (result == 'locked') {
      return;
    }
    LatLng? position = result as LatLng?;
    if (position != null) {
      controller!.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: position,
        zoom: 17.0,
      )));
      onGoogleMapTapped(position);
    }
  }

  Set<Marker> markers = {};
  bool updateMode = false;
  Map<fieldNames, MaterialTextField> fieldInputs = {
    fieldNames.shopName: MaterialTextField("Name of the shop"),
    fieldNames.shopOwner: MaterialTextField("Shop Owner"),
    fieldNames.isbnBookOne : MaterialTextField("ISBN")
  };
  onGoogleMapTapped(LatLng tappedPosition){
    currentLocation = tappedPosition;
    setState(() {
      if(markers.isNotEmpty){
      markers.remove(markers.first);
      }
      markers.add(Marker(markerId: const MarkerId('Shop'), position: tappedPosition));
    });
  }
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
              fieldInputs[fieldNames.shopName] as Widget,
              fieldInputs[fieldNames.shopOwner] as Widget,
              if (updateMode)
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Expanded(child:fieldInputs[fieldNames.isbnBookOne] as Widget, flex: 2),
                  Expanded(
                      child: Padding(
                          padding: const EdgeInsetsDirectional.only(
                              start: 7, end: 7),
                          child: ElevatedButton(
                              onPressed: () => {resolveAction('add book')},
                              child: const Text(
                                "Add Book",
                                textAlign: TextAlign.center,
                              ))))
                ]),
              ButtonBar(
                alignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () => resolveAction('create'),
                      child: const Text(
                        "Create",
                        textAlign: TextAlign.center,
                      )),
                  if(shopID != null)    
                    ElevatedButton(
                        onPressed: () => {resolveAction(updateMode ? 'commitUpdate' : 'update')},
                        child: Text(
                          updateMode ? "Save" : "Update",
                          textAlign: TextAlign.center,
                        )),
                    if(shopID != null)    
                      RedButton("Delete Shop", showDeleteConfirmationMessage)
                ],
              ),
              Expanded(
                child: Stack(children: [
                  GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: widget.initialPosition,
                    markers: markers,
                    onTap: onGoogleMapTapped,
                    onMapCreated: (GoogleMapController controller) async {
                      this.controller = controller;
                      updateMapToCurrentLocation(
                          notifier: updateMapToCurrentLocation);
                    },
                  ),
                   Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Chip(backgroundColor: Theme.of(context).primaryColor,

                          elevation: 2,
                          label: const Text("click on the map to relocate",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),))))
                ]),
              )
            ],
          )),
    );
  }
}
