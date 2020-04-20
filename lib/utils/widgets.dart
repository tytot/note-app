import 'package:flutter/material.dart';

class PriorityPicker extends StatefulWidget {
  final Function(int) onTap;
  final int selectedIndex;
  PriorityPicker({this.onTap, this.selectedIndex});
  @override
  _PriorityPickerState createState() => _PriorityPickerState();
}

class _PriorityPickerState extends State<PriorityPicker> {
  int selectedIndex;
  List<String> priorityText = ['Low', 'Medium', 'High'];
  List<Color> priorityColorBkg = [Colors.greenAccent[400], Colors.yellow[800], Colors.redAccent[400]];
  List<Color> priorityColor = [Colors.greenAccent, Colors.yellow[700], Colors.redAccent];
  @override
  Widget build(BuildContext context) {
    if (selectedIndex == null) {
      selectedIndex = widget.selectedIndex;
    }
    double width = MediaQuery.of(context).size.width;
    return SizedBox(
      width: width,
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
              widget.onTap(index);
            },
            child: Container(
              padding: EdgeInsets.all(8.0),
              width: width / 3,
              height: 70,
              child: Shadow(
                child: Container(
                  child: Center(
                    child: Text(priorityText[index],
                        style: TextStyle(
                            color: selectedIndex == index && selectedIndex != 0
                                ? Theme.of(context).scaffoldBackgroundColor
                                : Colors.black,
                            fontWeight: FontWeight.bold)),
                  ),
                  decoration: BoxDecoration(
                      color: selectedIndex == index
                          ? priorityColor[index]
                          : Colors.transparent,
                  ),
                ),
                behind: Container(
                  decoration: BoxDecoration(
                      color: selectedIndex == index
                          ? priorityColorBkg[index]
                          : Colors.transparent,
                  ),
                ),
              )
            ),
          );
        },
      ),
    );
  }
}

class Shadow extends StatelessWidget{

  final Widget child;
  final Widget behind;
  final Offset offset;

  Shadow({
    @required this.child,
    this.behind,
    this.offset,
  }): assert(child != null);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[ 
        Transform.translate(
          offset: offset ?? Offset(-4, 4),
          child: behind,
        ),
        child,
      ],
    );
  }
}
