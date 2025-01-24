import 'package:flutter/material.dart';
import 'package:smart_parking/utils/SizeConfig.dart';
import 'package:smart_parking/utils/styles.dart';

class MyAppBar extends StatefulWidget {

  Function? backbtncallback;
  bool backbtnVisible;
  String title;
  Widget? rightrow;
  Widget? center;
  Color? color;

  MyAppBar({required this.title,this.rightrow,this.backbtncallback,this.backbtnVisible=true,this.center, this.color,});


  @override
  _AppBarState createState() => _AppBarState();
}

class _AppBarState extends State<MyAppBar> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: widget.color == null ? Styles.primaryColor: widget.color,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Visibility(
              visible: widget.backbtnVisible,
              child:InkWell(
                onTap: (){
                  if(widget.backbtncallback==null)
                    {
                   Navigator.pop(context);
                    }
                  else {
                    widget.backbtncallback!();
                  }
                },
                child: Container(
                  height: MySize.size24!,
                  width: MySize.size50!,
                  child: Icon(
                    Icons.arrow_back_ios_sharp,
                    color: Styles.onBackground,
                    size: MySize.size20,
                  ),
                ),
              ),
            ),

            Visibility(visible:widget.center!=null,child: Spacer()),
            Visibility(visible:widget.center!=null,child: widget.center != null ? widget.center! : Container()),

            Visibility(visible:widget.center!=null,child: Spacer()),
            Expanded(
              child: Visibility(
                visible: widget.title!=null,
                child: Container(
                  margin: EdgeInsets.only(left: widget.backbtnVisible ? 0 : 20),
                  child: Text(
                    widget.title!=null?widget.title:'',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Styles.onBackground,
                      fontSize: MySize.size18!,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10,),
            Visibility(
              visible: widget.rightrow!=null,
              child: widget.rightrow != null ? widget.rightrow! : Container(),
            ),
            SizedBox(width: 15,)
          ],
        ),
      ),
    );
  }
}
