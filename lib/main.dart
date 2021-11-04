import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_init.dart';
import 'custom_canvas.dart';
import 'signup.dart';
import 'save_points.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Bezier Line',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
        brightness: Brightness.dark,
      ),
      home: const MyHomePage(title: 'Flutter Bezier Line'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Offset> _points = [];
  User? _user;

  fetchData() async {
    List<Offset> off = await getPoints();
    setPoints(off);
  }

  setUser(User? user) {
    setState(() {
      _user = user;
    });
  }

  setPoints(List<Offset> points) {
    setState(() {
      _points = points;
    });
  }

  Future<List<Offset>> getPoints() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    List<Offset> offsets = [];
    if (uid != null) {
      final document =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
      if (data['points'] != null) {
        for (int i = 0; i < data['points'].length; i++) {
          num x = data['points']['$i']['x'];
          num y = data['points']['$i']['y'];
          offsets.add(Offset(x.toDouble(), y.toDouble()));
        }
      }
    }
    return offsets;
  }

  void listenForAuth() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        fetchData();
        _user = user;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    listenForAuth();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.title),
          actions: <Widget>[Signup(fetchData, setUser, _user)]),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const FirebaseInit(),
            Flexible(child: CustomCanvas(setPoints, _points)),
          ],
        ),
      ),
      floatingActionButton: SavePoints(_points),
    );
  }
}
