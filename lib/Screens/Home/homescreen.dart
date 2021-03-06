// Importing Flutter Packages
import 'package:flutter/material.dart';

// Importing External Packages
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Importing Dart Files
import './new_todo.dart';
import './todo_details.dart';

// Importing Dart Models
import '../../Models/loader.dart';
import '../../Models/routes.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Booleans
  bool _isLoading = false;

  // Variables
  FirebaseUser _user;

  // Function to fetch current user
  Future<void> fetchData() async {
    setState(() {
      _isLoading = true;
    });
    _user = await FirebaseAuth.instance.currentUser();
    setState(() {
      _isLoading = false;
    });
  }

  // Function to add new todo
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

  // Function to show details of a todo
  void showTodo(BuildContext ctx, dynamic tappedUser) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          behavior: HitTestBehavior.opaque,
          child: TodoDetail(tappedUser),
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
            icon: Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacementNamed(Routes.auth_screen);
            },
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
                    .orderBy('createdAt')
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
                      : Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                itemCount: myTODOS.length,
                                itemBuilder: (ctx, i) {
                                  return InkWell(
                                    onTap: () => showTodo(context, myTODOS[i]),
                                    child: Dismissible(
                                      key: ValueKey(_user.uid),
                                      background: Container(
                                        color: Theme.of(context).errorColor,
                                        child: Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                        alignment: Alignment.centerRight,
                                        padding: EdgeInsets.only(right: 20),
                                        margin: EdgeInsets.symmetric(
                                          vertical: 4,
                                          horizontal: 15,
                                        ),
                                      ),
                                      direction: DismissDirection.endToStart,
                                      confirmDismiss: (dir) {
                                        return showDialog(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: Text("Are you sure"),
                                            content: Text(
                                              "Do you really want to remove this todo?",
                                            ),
                                            actions: [
                                              FlatButton(
                                                child: Text("No"),
                                                onPressed: () =>
                                                    Navigator.of(ctx)
                                                        .pop(false),
                                              ),
                                              FlatButton(
                                                child: Text("Yes"),
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(true),
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                      onDismissed: (dir) {
                                        setState(() {
                                          Firestore.instance
                                              .collection('users')
                                              .document(_user.uid)
                                              .collection('todos')
                                              .document(myTODOS[i]['createdAt']
                                                  .toString())
                                              .delete();
                                        });
                                      },
                                      child: Card(
                                        elevation: 5,
                                        margin: EdgeInsets.symmetric(
                                          vertical: 8,
                                          horizontal: 5,
                                        ),
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            radius: 30,
                                            child: Padding(
                                              padding: EdgeInsets.all(6),
                                              child: FittedBox(
                                                child: Text("${i + 1}"),
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            myTODOS[i]['title'],
                                            style: Theme.of(context)
                                                .textTheme
                                                .title,
                                          ),
                                          subtitle: Text(
                                            myTODOS[i]['date'],
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
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
