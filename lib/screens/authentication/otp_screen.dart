import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:smart_parking/controllers/providers/connection_provider.dart';
import 'package:smart_parking/controllers/providers/user_provider.dart';
import 'package:smart_parking/controllers/user_controller.dart';
import 'package:smart_parking/screens/common/components/modal_progress_hud.dart';
import 'package:smart_parking/screens/common/components/pin_put.dart';
import 'package:smart_parking/utils/SizeConfig.dart';
import 'package:smart_parking/utils/my_print.dart';
import 'package:smart_parking/utils/snakbar.dart';
import 'package:smart_parking/utils/styles.dart';

import '../home_screen/location_selection_screen.dart';

class OtpScreen extends StatefulWidget {
  static const String routeName = "/OtpScreen";
  final String? mobile;

  const OtpScreen({Key? key, this.mobile}) : super(key: key);

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  TextEditingController? _otpController;
  FocusNode? _otpFocusNode;
  CountDownController? controller;

  bool isInVerification = false;
  String msg = "", otpErrorMsg = "";
  bool msgshow = false,
      isShowOtpErrorMsg = false,
      isOTPTimeout = false,
      isShowResendOtp = false,
      isLoading = false,
      isOTPSent = false,
      isOtpEnabled = false,
      isTimerOn = false,
      isOtpSending = false;
  String? verificationId = null;

  double otpDuration = 120.0;

  Future registerUser(String mobile) async {
    MyPrint.printOnConsole("Register User Called for mobile:" + mobile);

    try {} catch (e) {
      //_controller.restart();
    }

    changeMsg("Please wait ! \nOTP is on the way.");

    FirebaseAuth _auth = FirebaseAuth.instance;
    String otp = "";

    isOTPTimeout = false;
    isOTPSent = false;
    isOtpEnabled = false;
    isOtpSending = true;
    _otpController!.text = "";
    isTimerOn = true;
    if (mounted) setState(() {});

    _auth.verifyPhoneNumber(
      phoneNumber: mobile,
      timeout: Duration(seconds: otpDuration.toInt()),
      verificationCompleted: (AuthCredential _credential) {
        print("Automatic Verification Completed");

        verificationId = null;
        isOTPSent = false;
        isShowResendOtp = false;
        isOtpEnabled = false;
        otpErrorMsg = "";
        if (mounted) setState(() {});
        changeMsg("Now, OTP received.\nSystem is preparing to login.");
        _auth
            .signInWithCredential(_credential)
            .then((UserCredential credential) async {
          await onSuccess(credential.user!);
        }).catchError((e) {
          print(e);
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        print("Error in Automatic OTP Verification:" + e.message!);
        verificationId = null;
        changeMsg("Error in Automatic OTP Verification:" + e.code);
        isShowResendOtp = true;
        isOTPTimeout = true;
        isOtpEnabled = false;
        isOtpSending = false;
        otpErrorMsg = "";

        //_otpController?.text = "";
        if (mounted) setState(() {});
        Snakbar().show_error_snakbar(context, "Try Again");
        //_otpController?.text = "";
      },
      codeSent: (verificationId, [forceResendingToken]) {
        print("OTP Sent");
        Snakbar().show_success_snakbar(context, "Otp Sent");
        //MyToast.showSuccess("OTP sent to your mobile", context);
        this.verificationId = verificationId;
        // istimer = true;
        //_otpController?.text = "";
        otpErrorMsg = "";

        isOTPSent = true;
        isShowResendOtp = true;
        isOtpEnabled = true;
        isOtpSending = false;
        if (mounted) setState(() {});

        //startTimer();

        _otpFocusNode?.requestFocus();

        //_smsReceiver.startListening();

        changeMsg("OTP Sent!");
      },
      codeAutoRetrievalTimeout: (val) {
        print("Automatic Verification Timeout");
        verificationId = null;
        //_otpController?.text = "";
        isOTPTimeout = true;
        isShowResendOtp = true;
        msg = "Timeout";
        isOtpEnabled = false;
        otpErrorMsg = "";
        isTimerOn = false;
        if (mounted) setState(() {});
        Snakbar().show_success_snakbar(context, "Try Again");
      },
    );
  }

  //Here otp is the code recieved in text message
  //verificationId is code we get in codeSent method of _auth.verifyPhoneNumber()
  //Method prints String "Verification Successful" if otp verified successfully
  //Method prints String "Verification Failed" if otp verification fails
  Future<bool> verifyOTP({@required String? otp, @required String? verificationId}) async {
    print("Verify OTP Called");

    setState(() {
      isLoading = true;
    });

    try {
      print("OTP Entered To Verify:" + otp!);
      //print("VerificationId:"+verificationId);
      FirebaseAuth _auth = FirebaseAuth.instance;

      AuthCredential authCredential = PhoneAuthProvider.credential(
          verificationId: verificationId!, smsCode: otp);
      UserCredential userCredential =
      await _auth.signInWithCredential(authCredential);

      changeMsg("OTP Verified!\nTaking to homepage.");
      await onSuccess(userCredential.user!);

      setState(() {
        isShowOtpErrorMsg = false;
        isLoading = false;
      });

      return true;
    } on FirebaseAuthException catch (e) {
      print("Error in Verifying OTP in Auth_Service:" + e.code);

      if (e.code == "invalid-verification-code") {
        Snakbar().show_error_snakbar(context, "Wrong OTP");
      }

      setState(() {
        otpErrorMsg = e.message!;
        isShowOtpErrorMsg = true;
      });

      setState(() {
        isLoading = false;
      });

      return false;
    }
  }

  Future onSuccess(User user) async {
    MyPrint.printOnConsole("Login Screen OnSuccess called");

    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.userid = user.uid;
    userProvider.firebaseUser = user;
    UserController().firebaseUser = user;

    MyPrint.printOnConsole("Email:${user.email}");
    MyPrint.printOnConsole("Mobile:${user.phoneNumber}");

    bool isExist = await UserController().isUserExist(context, userProvider.userid);

    setState(() {
      isLoading = false;
    });

    print("User Exist");
    Navigator.pushNamedAndRemoveUntil(context, LocationSelectionScreen.routeName, (route) => false);
  }

  void changeMsg(String m) async {
    msg = m;
    msgshow = true;
    if (mounted) setState(() {});
    /*await Future.delayed(Duration(seconds: 5));
    setState(() {
      msgshow = false;
    });*/
  }

  bool checkEnabledVerifyButton() {
    if (_otpController?.text.length == 6) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
    _otpFocusNode = FocusNode();

    _otpFocusNode!.requestFocus();
    controller = CountDownController();
    registerUser(widget.mobile!);
  }

  @override
  void dispose() {
    super.dispose();
    try {
      _otpController!.dispose();
      _otpFocusNode!.dispose();
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Styles.background,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Styles.background,
          body: ModalProgressHUD(
            inAsyncCall: isLoading,
            color: Colors.black54,
            progressIndicator: SpinKitFadingCircle(
              color: Styles.primaryColor,
            ),
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: MySize.size16!,
                horizontal: MySize.size20!,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    getAppBar(),
                    SizedBox(
                      height: MySize.size40!,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        getOtpWidget(),
                        SizedBox(
                          height: MySize.size20!,
                        ),
                        getResendLinkWidget(),
                      ],
                    ),
                    /*SizedBox(
                      height: MySize.size40!,
                    ),
                    getMessageText(msg),*/
                    getTimer(),
                    SizedBox(
                      height: MySize.size40!,
                    ),
                    getSubmitButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getAppBar() {
    return Container(
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            splashColor: Colors.red,
            child: Container(
              padding: EdgeInsets.all(MySize.size10!),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(MySize.size20!),
              ),
              child: const Icon(
                Icons.arrow_back_ios,
                color: Styles.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getOtpWidget() {
    BoxDecoration _pinPutDecoration = BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Styles.primaryColor),
      borderRadius: BorderRadius.circular(MySize.size5!),
    );

    BoxDecoration _disabledPinPutDecoration = BoxDecoration(
      border: Border.all(color: Styles.primaryColor),
      borderRadius: BorderRadius.circular(MySize.size5!),
    );

    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      //color: Colors.red,
      child: PinPut(
        fieldsCount: 6,
        onSubmit: (String pin) {
          print("Submitted:${pin}");
          _otpFocusNode!.unfocus();
        },
        checkClipboard: true,
        onClipboardFound: (String? string) {
          _otpController!.text = string ?? "";
        },
        enabled: true,
        focusNode: _otpFocusNode,
        controller: _otpController,
        eachFieldWidth: MySize.size50!,
        eachFieldHeight: MySize.size50!,
        submittedFieldDecoration: _pinPutDecoration,
        selectedFieldDecoration: _pinPutDecoration,
        disabledDecoration: _pinPutDecoration,
        followingFieldDecoration: _pinPutDecoration.copyWith(
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(
            color: Colors.white,
          ),
        ),
        //disabledDecoration: _pinPutDecoration,
        textStyle: TextStyle(
          color: Styles.primaryColor,
          fontSize: MySize.size18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    /*return Container(
      child: Row(
        children: [
          getSingleOtpField(controller: _otp1Controller!, focusNode: _otp1FocusNode!),
          SizedBox(width: MySize.size20!,),
          getSingleOtpField(controller: _otp2Controller!, focusNode: _otp2FocusNode!),
          SizedBox(width: MySize.size20!,),
          getSingleOtpField(controller: _otp3Controller!, focusNode: _otp3FocusNode!),
          SizedBox(width: MySize.size20!,),
          getSingleOtpField(controller: _otp4Controller!, focusNode: _otp4FocusNode!),
        ],
      ),
    );*/
  }

  Widget getResendLinkWidget() {
    if (!isOTPTimeout) return SizedBox.shrink();

    return InkWell(
      onTap: () {
        registerUser(widget.mobile!);
      },
      child: Container(
        child: Text(
          "Resend",
          style: TextStyle(
            color: Styles.primaryColor,
            fontWeight: FontWeight.w800,
            fontSize: MySize.size18!,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Widget getSubmitButton() {
    return InkWell(
      onTap: () async {
        // Navigator.pushNamed(context, SignUpScreen1.routeName);
        FocusScope.of(context).requestFocus(new FocusNode());

        ConnectionProvider connectionProvider = Provider.of<ConnectionProvider>(context, listen: false);

        if (connectionProvider.isInternet) {
          if (isOTPSent) {
            if (!checkEnabledVerifyButton()) {
              MyPrint.printOnConsole("Invalid Otp");
              setState(() {
                isShowOtpErrorMsg = true;
                otpErrorMsg = "OTP should be of 6 digits";
              });
            }
            else {
              MyPrint.printOnConsole("Valid OTP");
              setState(() {
                isShowOtpErrorMsg = false;
                otpErrorMsg = "";
              });

              if (verificationId != null) {
                String? otp = _otpController?.text;

                bool result = await verifyOTP(otp: otp, verificationId: verificationId);
              }
              else Snakbar().show_error_snakbar(context, "OTP Expired, Plase Resend");
            }
          }
          else MyPrint.printOnConsole("Otp Not Sent");
        }
        else Snakbar().show_error_snakbar(context, "No Internet");
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: MySize.size16!),
        decoration: BoxDecoration(
            color: Styles.primaryColor,
            borderRadius: BorderRadius.all(Radius.circular(MySize.size10!))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Submit',
              style: TextStyle(
                color: Colors.white,
                fontSize: MySize.size18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              width: MySize.size12!,
            ),
            Icon(
              Icons.arrow_forward,
              color: Colors.white,
              size: MySize.size30!,
            ),
          ],
        ),
      ),
    );
  }

  Widget getMobileNumberText(String mobile) {
    return Text(
      "+91-$mobile",
      style: const TextStyle(
        fontWeight: FontWeight.w500,
        color: Styles.primaryColor,
      ),
    );
  }

  Widget getLoadingWidget(bool isLoading) {
    return Column(
      children: [
        Visibility(
          visible: isLoading,
          child: const CircularProgressIndicator(
            color: Styles.primaryColor,
            strokeWidth: 4,
          ),
        ),
        Visibility(
          visible: isLoading,
          child: SizedBox(
            height: 30,
          ),
        )
      ],
    );
  }

  Widget getMessageText(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Visibility(
        visible: msgshow,
        child: Text(
          text,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget getTimer() {
    if (!isTimerOn) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(top: MySize.size20!),
      child: CircularCountDownTimer(
        controller: controller,
        width: MySize.getScaledSizeWidth(100),
        height: MySize.getScaledSizeWidth(100),
        duration: otpDuration.toInt(),
        initialDuration: 0,
        ringColor: isTimerOn ? Styles.primaryColor.withAlpha(100) : Colors.white,
        fillColor: Styles.primaryColor,
        isReverse: true,
        isReverseAnimation: true,
        textStyle: TextStyle(
          color: Styles.primaryColor,
          fontSize: MySize.size20,
          fontWeight: FontWeight.w700,
        ),
        strokeWidth: MySize.size5!,
        textFormat: "mm:ss",
        strokeCap: StrokeCap.round,
        onComplete: () {
          /*isTimerOn = false;
          if (mounted) setState(() {});*/
        },
      ),
    );
  }
}
