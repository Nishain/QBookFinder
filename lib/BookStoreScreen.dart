import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:q_book_finder/LocationUpdateCallback.dart';
import 'package:q_book_finder/compoenents/MaterialTextField.dart';
import 'package:q_book_finder/compoenents/RedButton.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class BookStoreScreen extends StatefulWidget with LocationUpdateCallback {
  final CameraPosition initialPosition;
  BookStoreScreen(this.initialPosition, {Key? key}) : super(key: key);

  @override
  State<BookStoreScreen> createState() => BookStoreState();
}

class BookStoreState extends State<BookStoreScreen> {
  String? location;
  GoogleMapController? controller;

  late String endpoint;
  @override
  void initState(){
    dotenv.load(fileName : '.env')
    .then((value) => {
      endpoint = "${dotenv.env['localendpoint']!}:${dotenv.env['port']!}",
      log('LOCAL ENDPOINT $endpoint'),
      http.get(Uri.parse('http://$endpoint/bookStore/61c07eccb9dba854e2c4e24a')).then((result){
        dynamic data = jsonDecode(result.body);        
        setState(() {
          name = data['name'];
          ownerName = data['shopOwner'];
        });
        
      })
    });
    
    super.initState();
  }
  showDeleteConfirmationMessage(){
    showDialog(context: context, builder: (_)=> AlertDialog(
      title: const Text("Are you sure?"),
      content: const Text("Do you want to delete your shop? this action is unreversible. Continue?"),
      actions: [
        TextButton(onPressed: ()=>Navigator.of(context).pop(), child: const Text("Cancel",style: TextStyle(color: Colors.red))),
        ElevatedButton(onPressed: ()=>{},child: const Text("Delete",style: TextStyle(color: Colors.white)),style: ElevatedButton.styleFrom(primary: Colors.red))
      ],
    ));
  }
  resolveAction(action){
      setState(() {
        updateMode = (action == 'update');
      });
    
  }
  String? name,ownerName,isbn;
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
  bool updateMode = false;
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
              MaterialTextField("Name of the shop",initialValue:name),
              MaterialTextField("Shop Owner",initialValue:ownerName),
              if(updateMode)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                Expanded(child: MaterialTextField("ISBN"),flex: 2),
                Expanded(child:Padding(padding: const EdgeInsetsDirectional.only(start: 7,end: 7),child: ElevatedButton(onPressed: ()=>{},child: const Text("Add Book",textAlign: TextAlign.center,))) 
                )
                
              ]),
              ButtonBar(
                alignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(onPressed: ()=>resolveAction('create'), child: const Text("Create",textAlign: TextAlign.center,)),
                  ElevatedButton(onPressed: () => {resolveAction('update')}, child: const Text("Update",textAlign: TextAlign.center,)),
                  RedButton("Delete Shop",showDeleteConfirmationMessage)
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
