import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_parking/configs/constants.dart';
import 'package:smart_parking/controllers/firestore_controller.dart';
import 'package:smart_parking/controllers/providers/user_provider.dart';
import 'package:smart_parking/models/user_model.dart';
import 'package:smart_parking/utils/my_print.dart';
import 'package:provider/provider.dart';

class UserController {
  static UserController? _instance;

  factory UserController() {
    _instance ??= UserController._();
    return _instance!;
  }

  UserController._();

  User? firebaseUser;

  bool isFirstProject = true;

  Future<bool> isUserExist(BuildContext context, String uid) async {
    if(uid.isEmpty) return false;

    MyPrint.printOnConsole("Uid:${uid}");
    if(uid.isEmpty) return false;

    bool isUserExist = false;

    try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await FirestoreController().firestore.collection('users').doc(uid).get();
      MyPrint.printOnConsole("documentSnapshot:${documentSnapshot.data()}");

      UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
      if(documentSnapshot.exists && (documentSnapshot.data()?.isNotEmpty ?? false)) {
        UserModel userModel = UserModel.fromMap(documentSnapshot.data()!);
        userProvider.userModel = userModel;
        MyPrint.printOnConsole("User Model:${userProvider.userModel}");
        isUserExist = true;
      }
      else {
        UserModel userModel = UserModel();
        userModel.id = uid;
        userModel.name = userProvider.firebaseUser?.displayName ?? "";
        userModel.mobile = userProvider.firebaseUser?.phoneNumber ?? "";
        userModel.email = userProvider.firebaseUser?.email ?? "";
        userModel.image = userProvider.firebaseUser?.photoURL ?? "";

        userModel.loginType = userModel.email.isNotEmpty ? LoginTypes.google : LoginTypes.mobile;

        userModel.createdTime = Timestamp.now();
        bool isSuccess = await UserController().createUser(context, userModel);
        MyPrint.printOnConsole("Insert Client Success:${isSuccess}");
      }
    }
    catch(e) {
      MyPrint.printOnConsole("Error in ClientController.isClientExist:${e}");
    }

    return isUserExist;
  }

  Future<bool> createUser(BuildContext context,UserModel userModel) async {
    try {
      /*Map<String, dynamic> data = {
        "ClientId" : clientModel.ClientId,
      };*/
      //if(clientModel.ClientPhoneNo.isNotEmpty) data['ClientPhoneNo'] = clientModel.ClientPhoneNo;
      //if(clientModel.ClientEmailId.isNotEmpty) data['ClientEmailId'] = clientModel.ClientEmailId;
      //data.remove("ClientId");
      Map<String, dynamic> data = userModel.tomap();

      await FirestoreController().firestore.collection("users").doc(userModel.id).set(data);

      UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.userModel = userModel;

      return true;
    }
    catch(e) {
      MyPrint.printOnConsole("Error in ClientController.insertClient:${e}");
    }

    return false;
  }
  
  Future<bool> editProfile({required BuildContext context, required String name, required String mobile, required String email, required String profileImageUrl}) async {
    MyPrint.printOnConsole("UserController().editProfile() called with name:$name, mobile:$mobile, email:$email, profileImageUrl:$profileImageUrl");

    bool isEdited = false;

    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);

    String userId = userProvider.userid;
    MyPrint.printOnConsole("userId:$userId");
    if(userId.isEmpty) {
      return isEdited;
    }

    isEdited = await FirestoreController().firestore.collection("users").doc(userId).update({
      "name": name,
      "image": profileImageUrl,
      "mobile"  : mobile,
      "email"  : email,
    }).then((value) => true).catchError((e) => false);
    MyPrint.printOnConsole("isEdited:$isEdited");

    if(isEdited) {
      await isUserExist(context, userId);
    }
    userProvider.notifyListeners();

    return isEdited;
  }
}