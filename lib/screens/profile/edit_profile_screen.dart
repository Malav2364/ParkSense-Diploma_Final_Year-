import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smart_parking/configs/constants.dart';
import 'package:smart_parking/controllers/providers/user_provider.dart';
import 'package:smart_parking/models/user_model.dart';
import 'package:smart_parking/utils/styles.dart';

import '../../controllers/user_controller.dart';
import '../../utils/SizeConfig.dart';
import '../../utils/my_print.dart';
import '../common/components/app_bar.dart';
import '../common/components/modal_progress_hud.dart';

class EditProfileScreen extends StatefulWidget {
  static const String routeName = "/EditProfileScreen";
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController nameController, mobileController, emailController;
  bool isMobileFieldEnabled = true, isEmailFieldEnabled = true;

  final picker = ImagePicker();
  File? profileImageFile;
  String profileImageUrl = "";

  late UserProvider userProvider;

  void initializeProfileDetails() {
    UserModel? userModel = userProvider.userModel;

    if(userModel != null) {
      nameController.text = userModel.name;
      mobileController.text = userModel.mobile;
      emailController.text = userModel.email;
      profileImageUrl = userModel.image;

      isMobileFieldEnabled = userModel.loginType != LoginTypes.mobile;
      isEmailFieldEnabled = userModel.loginType != LoginTypes.google;
    }
  }

  Future getProfileImage() async {
    final XFile? result = await ImagePicker().pickImage(source: ImageSource.gallery,);

    if(result?.path.isNotEmpty ?? false) {
      File? newImage = await ImageCropper().cropImage(
        compressFormat: ImageCompressFormat.png,
        sourcePath: result!.path,
        cropStyle: CropStyle.rectangle,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        androidUiSettings: const AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Styles.primaryColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        iosUiSettings: const IOSUiSettings(
          aspectRatioLockEnabled: false,
        ),
      );

      if(newImage == null) {
        print("image file null");
      }
      else {
        print("image file not null");
        MyPrint.printOnConsole("Cropped Image Path:${newImage.path}");

        profileImageFile = newImage;
        setState(() {});
      }
    }
  }

  Future<List<String>> uploadImages({required List<File> images}) async {
    List<String> downloadUrls = [];

    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    String userid = userProvider.userid;
    if(userid.isEmpty) {
      userid = "user";
    }

    await Future.wait(images.map((File file) async {
      Uint8List bytes = file.readAsBytesSync();

      String fileName = "${DateTime.now().millisecondsSinceEpoch}${file.path.substring(file.path.lastIndexOf("."))}";
      Reference reference = FirebaseStorage.instance.ref().child("users").child(userid).child(fileName);
      UploadTask uploadTask = reference.putData(bytes);

      TaskSnapshot snapshot = await uploadTask.then((snapshot) => snapshot);
      if (snapshot.state == TaskState.success) {
        final String downloadUrl = await snapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);

        /*final String downloadUrl = "https://storage.googleapis.com/${Firebase.app().options.storageBucket}/users/$userid/$fileName";
        downloadUrls.add(downloadUrl);*/

        print('$fileName Upload success');
      }
      else {
        print('Error from image repo uploading $fileName: ${snapshot.toString()}');
        //throw ('This file is not an image');
      }
    }),
    eagerError: true, cleanUp: (_) {
      print('eager cleaned up');
    });

    return downloadUrls;
  }

  void editProfile() async {
    isLoading = true;
    setState(() {});

    String imageUrl = "";

    if(profileImageUrl.isNotEmpty) {
      imageUrl = profileImageUrl;
    }
    else {
      if(profileImageFile != null) {
        imageUrl = (await uploadImages(images: [profileImageFile!])).first;
      }
      else {
        imageUrl = "";
      }
    }

    bool isEdited = await UserController().editProfile(
      context: context,
      name: nameController.text,
      email: emailController.text,
      mobile: mobileController.text,
      profileImageUrl: imageUrl,
    );
    MyPrint.printOnConsole("isEdited:$isEdited");

    isLoading = false;
    setState(() {});

    if(isEdited) {
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    MyPrint.printOnConsole("Edit Profile Screen Init Called");

    nameController = TextEditingController();
    mobileController = TextEditingController();
    emailController = TextEditingController();

    userProvider = Provider.of<UserProvider>(context, listen: false);

    initializeProfileDetails();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              MyAppBar(title: "Edit Profile", color: Colors.white, backbtnVisible: false,),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: MySize.size10!),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          getImageWidget(),
                          getNameTextField(),
                          getMobileTextField(),
                          getEmailTextField(),
                          getEditProfileButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getImageWidget() {
    if(profileImageFile == null && profileImageUrl.isEmpty) {
      return Column(
        children: [
          InkWell(
            onTap: () {
              getProfileImage();
            },
            focusColor: Colors.transparent,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            child: Container(
              width: MySize.size100,
              height: MySize.size100,
              margin: EdgeInsets.symmetric(vertical: MySize.size10!),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(MySize.size100!),
                border: Border.all(color: Colors.white)
              ),
              child: Icon(Icons.cloud_upload, size: MySize.size40,),
            ),
          ),
          const Text(
            "Add Your Logo",
            style: TextStyle(
              fontSize: 13,
            ),
          ),
          SizedBox(height: MySize.size20,),
        ],
      );
    }
    else {
      if(profileImageFile != null) {
        return Container(
          width: MySize.size100,
          margin: EdgeInsets.symmetric(vertical: MySize.size20!),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(MySize.size100!),
          ),
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.only(top: MySize.size10!, right: MySize.size10!),
                child: ClipRRect(
                  //borderRadius: BorderRadius.all(Radius.circular(MySize.size16)),
                  child: Image.file(profileImageFile!),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: InkWell(
                  onTap: () {
                    profileImageFile = null;
                    setState(() {});
                  },
                  focusColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Styles.primaryColor,
                    ),
                    child: const Icon(Icons.close, size: 13,),
                  ),
                ),
              ),
            ],
          ),
        );
      }
      else {
        return Container(
          width: MySize.size100,
          margin: EdgeInsets.symmetric(vertical: MySize.size20!),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(MySize.size100!),
          ),
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.only(top: MySize.size10!, right: MySize.size10!),
                child: ClipRRect(
                  //borderRadius: BorderRadius.all(Radius.circular(MySize.size16)),
                  child: CachedNetworkImage(
                    imageUrl: profileImageUrl,
                    placeholder: (context, url) => const SpinKitCircle(color: Styles.primaryColor,),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: InkWell(
                  onTap: () {
                    profileImageUrl = "";
                    setState(() {});
                  },
                  focusColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Styles.primaryColor,
                    ),
                    child: const Icon(Icons.close, size: 13,),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }
  }

  Widget getNameTextField()  {
    return Container(
      margin: EdgeInsets.symmetric(vertical: MySize.size10!, horizontal: MySize.size16!),
      child: TextFormField(
        controller: nameController,
        validator: (val) {
          if(val?.isEmpty ?? true) {
            return "Name Cannot be empty";
          }
          else{
            return null;
          }
        },
        decoration: getTextFieldInputDecoration(hintText: "Name", fillColor: Colors.white),
        inputFormatters: [
          LengthLimitingTextInputFormatter(50),
        ],
      ),
    );
  }

  Widget getMobileTextField() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: MySize.size10!, horizontal: MySize.size16!),
      child: TextFormField(
        enabled: isMobileFieldEnabled,
        controller: mobileController,
        validator: (val) {
          if(val?.isEmpty ?? true) {
            return "Mobile Cannot be empty";
          }
          else{
            return null;
          }
        },
        style: TextStyle(
          color: isMobileFieldEnabled ? null : Colors.grey,
        ),
        decoration: getTextFieldInputDecoration(hintText: "Mobile", fillColor: Colors.white),
        keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.deny('.'),
          LengthLimitingTextInputFormatter(10),
        ],
      ),
    );
  }

  Widget getEmailTextField() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: MySize.size10!, horizontal: MySize.size16!),
      child: TextField(
        enabled: isEmailFieldEnabled,
        controller: emailController,
        style: TextStyle(
          color: isEmailFieldEnabled ? null : Colors.grey,
        ),
        decoration: getTextFieldInputDecoration(hintText: "Email", fillColor: Colors.white),
        inputFormatters: [
          LengthLimitingTextInputFormatter(55),
        ],
      ),
    );
  }

  Widget getEditProfileButton() {
    return ElevatedButton(
      onPressed: () {
        editProfile();
      },
      child: const Text("Edit Profile"),
    );
  }

  InputDecoration getTextFieldInputDecoration({required String hintText, required Color fillColor}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        fontSize: 14,
        letterSpacing: 0.1,
        // color: themeData.colorScheme.onBackground,
        fontWeight: FontWeight.w500,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: fillColor,
      isDense: true,
      contentPadding: const EdgeInsets.all(15),
    );
  }
}
