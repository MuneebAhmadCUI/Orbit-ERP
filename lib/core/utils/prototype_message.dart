import 'package:flutter/material.dart';

void showPrototypeMessage(BuildContext context, String feature) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('$feature will be added in a later development step.')),
  );
}
