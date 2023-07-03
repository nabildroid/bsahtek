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

  final activeStyle = TextButton.styleFrom(
    backgroundColor: Colors.green.shade800,
    padding: EdgeInsets.symmetric(vertical: 16),
    textStyle: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  );

  final disabledStyle = TextButton.styleFrom(
    textStyle: TextStyle(
      color: Colors.green.shade800,
      fontWeight: FontWeight.bold,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade600.withOpacity(.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
              child: TextButton(
            onPressed: () => onClick(true),
            style: leftSelected ? activeStyle : disabledStyle,
            child: Text(leftLabel),
          )),
          Expanded(
            child: TextButton(
              style: !leftSelected ? activeStyle : disabledStyle,
              onPressed: () => onClick(false),
              child: Text(rightLabel),
            ),
          ),
        ],
      ),
    );
  }
}
