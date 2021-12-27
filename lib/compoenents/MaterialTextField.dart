import 'dart:developer';

import 'package:flutter/material.dart';


class MaterialTextField extends StatelessWidget{
  final String label;
  final bool readOnly;
  final TextEditingController controller =  TextEditingController();
  final String? initialValue;
  MaterialTextField(this.label,{Key? key,this.readOnly = false,this.initialValue}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    controller.text = initialValue ?? "";
    return 
    Padding(padding: const EdgeInsets.only(bottom: 10),child: TextFormField(controller: controller,readOnly: readOnly ,decoration: InputDecoration(border: const OutlineInputBorder(),labelText: label)));
  }
  
}
