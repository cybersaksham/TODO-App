// Imporitng Flutter Packages
import 'package:flutter/material.dart';

class TodoDetail extends StatelessWidget {
  // Class Variables
  final tappedUser;

  // Constructor
  TodoDetail(this.tappedUser);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          top: 10,
          left: 10,
          right: 10,
          bottom: 70,
        ),
        child: Column(
          children: <Widget>[
            Text(
              tappedUser['title'],
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            tappedUser['content'] == ""
                ? Container()
                : Text(
                    tappedUser['content'],
                    style: TextStyle(fontSize: 15),
                  ),
            SizedBox(height: 20),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          "Date",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        tappedUser['date'],
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
