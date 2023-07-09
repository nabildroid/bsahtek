import 'package:flutter/material.dart';

class Skelaton extends StatelessWidget {
  final Widget top;
  final Widget bottom;
  final bool isExpanded;

  const Skelaton({
    Key? key,
    required this.top,
    required this.bottom,
    required this.isExpanded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        FractionallySizedBox(
          alignment: Alignment.topCenter,
          heightFactor: 0.4,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.green,
              image: DecorationImage(
                image: AssetImage('assets/texture.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.2),
                  BlendMode.dstATop,
                ),
              ),
            ),
            padding: EdgeInsets.symmetric(vertical: 26, horizontal: 20),
            child: AnimatedToBack(
              isExpanded: isExpanded,
              child: top,
            ),
          ),
        ),
        AnimatedFractionallySizedBox(
          duration: Duration(milliseconds: 500),
          alignment: Alignment.bottomCenter,
          heightFactor: isExpanded ? 0.9 : 0.62,
          child: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20)
                  .copyWith(top: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: bottom),
        ),
      ],
    );
  }
}

class AnimatedToBack extends StatelessWidget {
  final bool isExpanded;
  final Widget child;

  const AnimatedToBack(
      {super.key, required this.isExpanded, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: Duration(milliseconds: 500),
      offset: isExpanded ? Offset(0, 0.2) : Offset(0, 0),
      curve: Curves.easeInExpo,
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 350),
        opacity: isExpanded ? 0.6 : 1,
        child: AnimatedScale(
          duration: Duration(milliseconds: 350),
          scale: isExpanded ? 0.9 : 1,
          child: child,
        ),
      ),
    );
  }
}
