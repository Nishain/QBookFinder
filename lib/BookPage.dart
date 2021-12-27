import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:q_book_finder/compoenents/MaterialTextField.dart';
import 'package:q_book_finder/compoenents/RedButton.dart';

class BookPage extends StatefulWidget {
  BookPage({Key? key}) : super(key: key);

  @override
  State<BookPage> createState() => BookPageState();
}

class BookPageState extends State<BookPage> {
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
                    "Create a Book",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  )),
              MaterialTextField("ISBN"),
              MaterialTextField("Author"),
              Expanded(child: MaterialTextField("Name")),
              ButtonBar(
                alignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(onPressed: ()=>{},child: const Text("Create",textAlign: TextAlign.center,)),
                  ElevatedButton(onPressed: ()=>{},child: const Text("Update",textAlign: TextAlign.center,)),
                  RedButton("Delete",()=>{})
                ],
              ),
            ],
          )),
    );
  }
}
