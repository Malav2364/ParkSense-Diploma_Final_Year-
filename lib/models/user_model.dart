import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String id = "", name = "", image = "", mobile = "", email = "", loginType = "";
  Timestamp? createdTime;

  UserModel();

  UserModel.fromMap(Map<String, dynamic> map) {
    id = map['id']?.toString() ?? "";
    name = map['name']?.toString() ?? "";
    image = map['image']?.toString() ?? "";
    mobile = map['mobile']?.toString() ?? "";
    email = map['email']?.toString() ?? "";
    loginType = map['loginType']?.toString() ?? "";
    createdTime = map['createdTime'];
  }

  void updateFromMap(Map<String, dynamic> map) {
    id = map['id']?.toString() ?? "";
    name = map['name']?.toString() ?? "";
    image = map['image']?.toString() ?? "";
    mobile = map['mobile']?.toString() ?? "";
    email = map['email']?.toString() ?? "";
    loginType = map['loginType']?.toString() ?? "";
    createdTime = map['createdTime'];
  }

  Map<String, dynamic> tomap() {
    return {
      "id" : id,
      "name" : name,
      "image" : image,
      "mobile" : mobile,
      "email" : email,
      "loginType" : loginType,
      "createdTime" : createdTime,
    };
  }

  @override
  String toString() {
    return "id:${id}, name:$name, image:$image, mobile:$mobile, email:$email, loginType:$loginType, createdTime:$createdTime";
  }
}