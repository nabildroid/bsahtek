import 'package:flutter/material.dart';

class ViewMode extends StatelessWidget {
  final String rightLabel;
  final String leftLabel;
  final bool leftSelected;
  final void Function(bool isLeft) onClick;

  ViewMode({
    super.key,
    required this.rightLabel,
    required this.leftLabel,
    required this.leftSelected,
    required this.onClick,
  });

  final activeStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  final disabledStyle = TextStyle(
    color: Colors.grey.shade600,
    fontWeight: FontWeight.bold,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 38,
          decoration: BoxDecoration(
            color: Colors.grey.shade600.withOpacity(.25),
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                  alignment: leftSelected
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  duration: Duration(milliseconds: 450),
                  curve: Curves.easeInOutExpo,
                  child: FractionallySizedBox(
                    widthFactor: .5,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green.shade600.withOpacity(.8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  )),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onClick(true),
                      child: Container(
                          color: Colors.transparent,
                          child: Center(
                            child: Text(
                              leftLabel,
                              style:
                                  !leftSelected ? disabledStyle : activeStyle,
                            ),
                          )),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onClick(false),
                      child: Container(
                          color: Colors.transparent,
                          child: Center(
                            child: Text(
                              rightLabel,
                              style: leftSelected ? disabledStyle : activeStyle,
                            ),
                          )),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
