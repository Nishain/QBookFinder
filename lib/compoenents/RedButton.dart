import 'package:flutter/material.dart';

class RedButton extends StatelessWidget{
  final Function action;
  final String label;
  const RedButton(this.label,this.action,{Key? key}):super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(style: ElevatedButton.styleFrom(primary:Colors.red),onPressed: () => {action()}, child: Text(label,textAlign: TextAlign.center,style: const TextStyle(color: Colors.white)));
  }


}