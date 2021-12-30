import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:q_book_finder/compoenents/MaterialTextField.dart';
import 'package:q_book_finder/compoenents/RedButton.dart';
import 'package:http/http.dart' as http;

class BookPage extends StatefulWidget {
  BookPage({Key? key}) : super(key: key);

  @override
  State<BookPage> createState() => BookPageState();
}

enum FieldName { isbn, author, bookName }

class BookPageState extends State<BookPage> {
  Map<FieldName, MaterialTextField> inputFields = {
    FieldName.bookName: MaterialTextField("Name"),
    FieldName.isbn: MaterialTextField("ISBN"),
    FieldName.author: MaterialTextField("Author")
  };
  late String baseURL;
  @override
  void initState() {
    super.initState();
    dotenv.load(fileName: '.env').then((value) => {
          baseURL =
              "http://${dotenv.env['localendpoint']!}:${dotenv.env['port']!}"
        });
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
  ivokeAction(String action) async {
    if (action == 'create') {
      String createBody = jsonEncode({
        "name": inputFields[FieldName.bookName]!.controller.text,
        "author": inputFields[FieldName.author]!.controller.text,
        "ISBN": inputFields[FieldName.isbn]!.controller.text
      });
      http.Response response = await http.post(Uri.parse("$baseURL/books/"),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: createBody);
      if(jsonDecode(response.body)['duplicateError'] == true){
          showToast("Book already exists with given ISBN");
      }    
    } else if (action == 'update') {
      String isbn = inputFields[FieldName.isbn]!.controller.text;
      String updateBody = jsonEncode({
        "name": inputFields[FieldName.bookName]!.controller.text,
        "author": inputFields[FieldName.author]!.controller.text,
        "ISBN": isbn
      });
      http.Response response = await http.put(Uri.parse("$baseURL/books/$isbn"),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: updateBody);
       if(jsonDecode(response.body)['duplicateError'] == true){
          showToast("ISBN conflicted with another book");   
       }
    } else if (action == 'delete') {
      String isbn = inputFields[FieldName.isbn]!.controller.text;
      http.Response result = await http.delete(Uri.parse("$baseURL/books/$isbn"),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: "{}");
      if(jsonDecode(result.body)['notFound'] == true){
        showToast("such book was not found");
      }    
    }
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
                    "Create a Book",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  )),
              inputFields[FieldName.bookName] as Widget,
              inputFields[FieldName.author] as Widget,
              inputFields[FieldName.isbn] as Widget,
              ButtonBar(
                alignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () => {ivokeAction('create')},
                      child: const Text(
                        "Create",
                        textAlign: TextAlign.center,
                      )),
                  ElevatedButton(
                      onPressed: () => {ivokeAction('update')},
                      child: const Text(
                        "Update",
                        textAlign: TextAlign.center,
                      )),
                  RedButton("Delete", () => {ivokeAction('delete')})
                ],
              ),
            ],
          )),
    );
  }
}
