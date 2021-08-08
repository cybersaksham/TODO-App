import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import './new_todo.dart';

import '../../Models/loader.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Booleans
  bool _isLoading = false;

  // Variables
  FirebaseUser _user;

  Future<void> fetchData() async {
    setState(() {
      _isLoading = true;
    });
    _user = await FirebaseAuth.instance.currentUser();
    setState(() {
      _isLoading = false;
    });
  }

  void addTodo(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          behavior: HitTestBehavior.opaque,
          child: NewTodo(),
        );
      },
    );
  }

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Todos"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => addTodo(context),
          )
        ],
      ),
      body: _isLoading
          ? Loader()
          : Container(
              child: StreamBuilder(
                stream: Firestore.instance
                    .collection('users')
                    .document(_user.uid)
                    .collection('todos')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Loader();
                  }
                  List<dynamic> myTODOS = snapshot.data.documents;
                  return myTODOS.length == 0
                      ? Center(
                          child: Text(
                            "No todos",
                            style: Theme.of(context).textTheme.title,
                          ),
                        )
                      : Container();
                },
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => addTodo(context),
      ),
    );
  }
}
