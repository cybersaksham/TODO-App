// Imporitng Flutter Packages
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Importing External Packages
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Importing Dart Models
import '../../Models/loader.dart';

class NewTodo extends StatefulWidget {
  @override
  _NewTodoState createState() => _NewTodoState();
}

class _NewTodoState extends State<NewTodo> {
  // Global Keys
  final _formKey = GlobalKey<FormState>();

  // Booleans
  bool _isDateSelected = false;
  bool _isLoading = false;
  DateTime _pickedDate;

  // Form Variables
  String _title = "";
  String _content = "";
  String _date = "";

  // Title & Content Validator
  String _validateTitle(String val) {
    if (val.isEmpty) return "This field is required.";
    return null;
  }

  // Date Validator
  String _validateDate(String val) {
    if (!_isDateSelected) return "This field is required.";
    return null;
  }

  // Showing Date Picker
  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(3000),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _isDateSelected = true;
        _pickedDate = pickedDate;
        _date = DateFormat('MMM dd, yyyy').format(pickedDate);
      });
    });
  }

  // Submitting Data
  Future<void> _submitForm() async {
    SystemChannels.textInput.invokeMethod("TextInput.hide"); // Hiding Keyboard
    // Validating Form
    if (_formKey.currentState.validate()) {
      // Saving Form
      _formKey.currentState.save();

      // Showing loading spinner
      setState(() {
        _isLoading = true;
      });

      // Getting Data
      final FirebaseUser user = await FirebaseAuth.instance.currentUser();
      String year = (_date.trim()).substring(8);
      int month = _pickedDate.month;
      String day = (_date.trim()).substring(4, 6);
      String time = "$year $month $day ${Timestamp.now()}";

      // Sendign to database
      await Firestore.instance
          .collection('users')
          .document(user.uid)
          .collection('todos')
          .document(time)
          .setData({
        'title': _title.trim(),
        'content': _content.trim(),
        'date': _date.trim(),
        'createdAt': time,
      });

      // Hiding loading spinner
      setState(() {
        _isLoading = true;
      });

      // Popping out modal sheet
      Navigator.of(context).pop();
    }
  }

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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: "Title"),
                onSaved: (val) => _title = val,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                validator: (val) => _validateTitle(val),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Content"),
                onSaved: (val) => _content = val,
                textCapitalization: TextCapitalization.sentences,
                validator: (val) => _validateTitle(val),
              ),
              SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: _isDateSelected ? _date : "Select Date",
                      ),
                      validator: (val) => _validateDate(val),
                      readOnly: true,
                      onTap: () => _presentDatePicker(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    color: Theme.of(context).primaryColor,
                    onPressed: () => _presentDatePicker(),
                  )
                ],
              ),
              SizedBox(height: 30),
              if (_isLoading) Loader(),
              if (!_isLoading)
                RaisedButton(
                  child: Text("Add Todo"),
                  onPressed: () => _submitForm(),
                )
            ],
          ),
        ),
      ),
    );
  }
}
