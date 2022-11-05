import 'package:boiler_time/constants/routes.dart';
import 'package:boiler_time/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

import '../../enums/menu_action.dart';

class PostPage extends StatefulWidget {
  final String documentID;
  final String collectionName;
  const PostPage({required this.documentID, required this.collectionName});

  @override
  State<PostPage> createState() => _postPageViewState();
}

class _postPageViewState extends State<PostPage> {
  String? documentID;
  String? collectionName;
  @override
  void initState() {
    documentID = widget.documentID;
    collectionName = widget.collectionName;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(documentID.toString() + " " + collectionName.toString()),
      ),
    );
  }
}
