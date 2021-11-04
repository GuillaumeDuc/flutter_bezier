import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SavePoints extends StatefulWidget {
  List<Offset> _points = [];

  SavePoints(List<Offset> points) {
    _points = points;
  }
  @override
  State<SavePoints> createState() => _SavePointsState();
}

class _SavePointsState extends State<SavePoints> {
  String _snackText = 'Saved';

  addPoints() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    Map<String, dynamic> points = {};
    for (int i = 0; i < widget._points.length; i++) {
      points[i.toString()] = {
        'x': widget._points[i].dx,
        'y': widget._points[i].dy
      };
    }
    if (uid != null) {
      CollectionReference user =
          FirebaseFirestore.instance.collection('users/');
      // Call the user's CollectionReference to add a new user
      await user
          .doc(uid)
          .set(
            {'points': points},
            SetOptions(merge: true),
          )
          .then((value) => setState(() {
                _snackText = 'Saved';
              }))
          .catchError((error) {
            setState(() {
              _snackText = 'Error';
            });
          });
    } else {
      // User not logged
      setState(() {
        _snackText = 'Not logged';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
        onPressed: () async => {
              await addPoints(),
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(_snackText),
                backgroundColor: Colors.lightBlue,
              )),
            },
        tooltip: 'Save',
        child: const Icon(Icons.save));
  }
}
