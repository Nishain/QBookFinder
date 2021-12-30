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
    for (var field in inputFields.values) { 
      field.changableParams['errorMessage'] = null;
    }
    if (action == 'create') {
      _formKey.currentState!.validate();
      Map<String,MaterialTextField> mapping = {
        "name": inputFields[FieldName.bookName]!,
        "author": inputFields[FieldName.author]!,
        "ISBN": inputFields[FieldName.isbn]!
      };
      String createBody = jsonEncode(mapping.map((key, value) => MapEntry(key, value.controller.text)));
      http.Response response = await http.post(Uri.parse("$baseURL/books/"),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: createBody);
      dynamic resultData = jsonDecode(response.body);  
      if(resultData['duplicateError'] == true){
          showToast("Book already exists with given ISBN");
      }    
      if(resultData['validateError'] == true){
        for(var field in resultData['errorFields']){
          mapping[field]!.changableParams['errorMessage'] = 'field is empty';
        }
      }
      _formKey.currentState!.validate();
      if(resultData["_id"]!=null){
        showToast('Book created successfully');
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
      Map resData = jsonDecode(response.body);
       if(resData['duplicateError'] == true){
          showToast("ISBN conflicted with another book");   
       }else if(resData['notFound'] == true){
         showToast('no book found with given ISBN');
       }else{
         showToast("successfully updated");
       }

    } else if (action == 'delete') {
      String isbn = inputFields[FieldName.isbn]!.controller.text;
      http.Response result = await http.delete(Uri.parse("$baseURL/books/$isbn"),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: "{}");
      if(jsonDecode(result.body)['notFound'] == true){
        showToast("No book with given ISBN exist");
      }else if((jsonDecode(result.body)['deleteCount'] ?? 0) > 0){
        showToast('successfully deleted');
        for(var field in inputFields.values){
          field.controller.clear();
        }
      }
    }
  }
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          padding: const EdgeInsets.all(15),
          child: 
          Form(key: _formKey,child: Column(
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
          ))
          ),
    );
  }
}
